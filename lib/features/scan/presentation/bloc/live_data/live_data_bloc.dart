import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/domain/entities/command.dart';
import 'package:motus_lab/data/repositories/protocol_repository.dart';
import 'package:motus_lab/data/repositories/vehicle_profile_repository.dart';

part 'live_data_event.dart';
part 'live_data_state.dart';

/// Bloc สำหรับจัดการค่าสด (Live Data)
/// ทำหน้าที่ส่งคำสั่งชุดเดิมวนซ้ำ (Round-robin) เพื่อให้ UI อัพเดตตลอดเวลา
class LiveDataBloc extends Bloc<LiveDataEvent, LiveDataState> {
  final ProtocolEngine _engine;
  final ConnectionInterface _connection;
  final ProtocolRepository _repository;
  final VehicleProfileRepository _profileRepository;
  Timer? _timer;
  List<Command> _activeCommands = [];

  LiveDataBloc({
    required ProtocolEngine engine,
    required ConnectionInterface connection,
    required ProtocolRepository repository,
    required VehicleProfileRepository profileRepository,
  })  : _engine = engine,
        _connection = connection,
        _repository = repository,
        _profileRepository = profileRepository,
        super(const LiveDataState()) {
    on<StartStreaming>(_onStartStreaming);
    on<StopStreaming>(_onStopStreaming);
    on<UpdateActiveCommands>(_onUpdateActiveCommands);
    on<NewDataReceived>(_onNewDataReceived);
    on<LoadProtocol>(_onLoadProtocol);
  }

  Future<void> _onStartStreaming(
      StartStreaming event, Emitter<LiveDataState> emit) async {
    // Check if we need to discover PIDs (if event.commands is empty or explicitly requested)
    // For now, if event.commands is passed (e.g. from UI selection), use it.
    // If not, trigger discovery.

    List<Command> commandsToUse = event.commands;

    if (commandsToUse.isEmpty || commandsToUse.length <= 3) {
      // Simple heuristic: if default list is small/empty, try discover
      emit(state.copyWith(isStreaming: true, isDiscovering: true));

      // --- ระบบจดจำรถยนต์ (Vehicle Identity) และการทำ Caching ---
      List<String> supportedKeyCodes = [];
      String? currentVin;

      // 0. พยายามอ่านเลขตัวถัง (VIN) ก่อนเพื่อตรวจสอบว่ามีข้อมูลใน Cache หรือไม่
      try {
        // Mode 09 PID 02 (VIN)
        final vinCmd = _repository.getCommandByCode("0902");
        if (vinCmd != null) {
          final request = _engine.buildRequest(vinCmd);
          final response = await _connection.send(request);
          // TODO: แปลงค่า VIN จาก Hex เป็น Text จริงๆ
          // ในสถานการณ์จริง ใช้ _engine.parseVin(response)
          // สำหรับการจำลอง ใส่ค่า Mock ไปก่อน
          currentVin = "JHMGD38TEST"; // Mock ID
        }
      } catch (e) {
        print("Error reading VIN: $e");
      }

      bool cacheHit = false;
      if (currentVin != null) {
        // ตรวจสอบข้อมูลใน Database
        final cachedPids =
            await _profileRepository.getSupportedPids(currentVin);
        if (cachedPids != null && cachedPids.isNotEmpty) {
          print("Cache HIT for VIN: $currentVin. Skipping discovery.");
          supportedKeyCodes = cachedPids;
          cacheHit = true;
        }
      }

      if (!cacheHit) {
        // Cache MISS -> เริ่มกระบวนการค้นหาเต็มรูปแบบ (Full Discovery)
        print("Cache MISS. Starting Full Discovery...");

        // 1. Discovery Phase (ค้นหา PID ที่รถรองรับ)
        // ตรวจสอบ PID 0100, 0120, 0140 เพื่อดู Bitmask
        await _checkSupportedPids("0100", supportedKeyCodes);
        await _checkSupportedPids("0120", supportedKeyCodes);
        await _checkSupportedPids("0140", supportedKeyCodes);

        print("Discovered PIDs: $supportedKeyCodes");

        // บันทึกผลลัพธ์ลง Cache (Database)
        if (currentVin != null && supportedKeyCodes.isNotEmpty) {
          await _profileRepository.saveProfile(
            vin: currentVin,
            protocol: "AUTO", // TODO: Get real protocol
            supportedPids: supportedKeyCodes,
          );
        }
      }

      // 2. Matching Phase (จับคู่ PID ที่เจอ กับ Command ที่เรามี)
      final allAvailable = _repository.getAllAvailablePids();
      commandsToUse = allAvailable.where((cmd) {
        return supportedKeyCodes.contains(cmd.code);
      }).toList();

      // ถ้าไม่เจออะไรเลย (เช่น Mock หรือ Error) ให้ใช้ค่า Default ไปก่อน
      if (commandsToUse.isEmpty) {
        commandsToUse = _repository.getStandardPids();
      }

      // อัพเดต State
      emit(state.copyWith(
          isDiscovering: false, supportedPidCodes: supportedKeyCodes));
    }

    _activeCommands = commandsToUse;
    // Tell UI about the commands we are actually using
    // Note: We might need a new state field for 'activeCommands' to update UI list

    emit(state.copyWith(isStreaming: true));

    // หยุด Timer เก่าถ้ามี
    _timer?.cancel();

    int tick = 0;
    // ปรับ Base Loop ให้เร็วขึ้นเป็น 50ms เพื่อรองรับ High Priority
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (!_connection.isConnected) {
        add(StopStreaming());
        return;
      }

      tick++;
      Map<String, double> updatedValues = Map.from(state.currentValues);

      // กรองคำสั่งที่จะส่งในรอบนี้ (Weighted Polling)
      final commandsToPoll = _activeCommands.where((cmd) {
        switch (cmd.priority) {
          case CommandPriority.high:
            // 50ms interval (Every tick)
            return true;
          case CommandPriority.normal:
            // 500ms interval (Every 10 ticks)
            return tick % 10 == 0;
          case CommandPriority.low:
            // 2000ms interval (Every 40 ticks)
            return tick % 40 == 0;
        }
      }).toList();

      if (commandsToPoll.isEmpty) return;

      for (var cmd in commandsToPoll) {
        try {
          // 1. สร้าง Request
          final request = _engine.buildRequest(cmd);
          // 2. ส่งและรับ Response
          // Note: อาจต้องระวังเรื่อง Queue ถ้ารับส่งไม่ทัน 50ms
          final response = await _connection.send(request);
          // 3. แปลผล
          if (response.isNotEmpty) {
            final value = _engine.parseResponse(response, cmd.formula);
            updatedValues[cmd.name] = value;
          }
        } catch (e) {
          // ข้ามถ้าตัวใดตัวหนึ่งเสีย
        }
      }

      if (updatedValues.isNotEmpty) {
        add(NewDataReceived(updatedValues));
      }
    });
  }

  Future<void> _checkSupportedPids(
      String pidCode, List<String> resultList) async {
    try {
      final cmd = _repository.getCommandByCode(pidCode);
      if (cmd == null) return;

      final request = _engine.buildRequest(cmd);
      final response = await _connection.send(request);
      if (response.isNotEmpty) {
        // Assuming 0100 means start at 0x00
        int startPid = int.parse(pidCode.substring(2), radix: 16);
        final pids = _engine.decodeSupportedPids(response, startPid);
        resultList.addAll(pids);
      }
      // Small delay to prevent flooding
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      print("Discovery Error ($pidCode): $e");
    }
  }

  void _onUpdateActiveCommands(
      UpdateActiveCommands event, Emitter<LiveDataState> emit) {
    _activeCommands = event.newCommands;
    emit(state.copyWith(activeCommands: _activeCommands));
    // ไม่ต้องทำอะไรเพิ่ม Timer รอบถัดไปจะเก็ตค่าใหม่เอง
  }

  void _onStopStreaming(StopStreaming event, Emitter<LiveDataState> emit) {
    _timer?.cancel();
    emit(const LiveDataState(isStreaming: false));
  }

  void _onNewDataReceived(NewDataReceived event, Emitter<LiveDataState> emit) {
    emit(state.copyWith(currentValues: event.values));
  }

  Future<void> _onLoadProtocol(
      LoadProtocol event, Emitter<LiveDataState> emit) async {
    emit(state.copyWith(isStreaming: false)); // Stop temporarily
    _timer?.cancel();

    await _repository.loadProtocolPackFromAsset(event.assetPath);

    // Trigger re-discovery with empty list
    add(const StartStreaming([]));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
