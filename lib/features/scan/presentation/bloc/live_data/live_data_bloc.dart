import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/domain/entities/command.dart';
import 'package:motus_lab/data/repositories/protocol_repository.dart';

part 'live_data_event.dart';
part 'live_data_state.dart';

/// Bloc สำหรับจัดการค่าสด (Live Data)
/// ทำหน้าที่ส่งคำสั่งชุดเดิมวนซ้ำ (Round-robin) เพื่อให้ UI อัพเดตตลอดเวลา
class LiveDataBloc extends Bloc<LiveDataEvent, LiveDataState> {
  final ProtocolEngine _engine;
  final ConnectionInterface _connection;
  final ProtocolRepository _repository;
  Timer? _timer;
  List<Command> _activeCommands = [];

  LiveDataBloc({
    required ProtocolEngine engine,
    required ConnectionInterface connection,
    required ProtocolRepository repository,
  })  : _engine = engine,
        _connection = connection,
        _repository = repository,
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

      // 1. Discovery Phase
      List<String> supportedKeyCodes = [];
      // Check 0100 (Supported 01-20)
      await _checkSupportedPids("0100", supportedKeyCodes);

      // If 0120 supported (bit 32 of 0100), check 0120.
      // Simplification: Check 0120, 0140 anyway if connection is good.
      await _checkSupportedPids("0120", supportedKeyCodes);
      await _checkSupportedPids("0140", supportedKeyCodes);

      print("Discovered PIDs: $supportedKeyCodes");

      // 2. Matching Phase
      final allAvailable = _repository.getAllAvailablePids();
      commandsToUse = allAvailable.where((cmd) {
        return supportedKeyCodes.contains(cmd.code);
      }).toList();

      // If nothing found (e.g. mock or error), fallback to Standard
      if (commandsToUse.isEmpty) {
        commandsToUse = _repository.getStandardPids();
      }

      // Update State with supported codes
      emit(state.copyWith(
          isDiscovering: false, supportedPidCodes: supportedKeyCodes));
    }

    _activeCommands = commandsToUse;
    // Tell UI about the commands we are actually using
    // Note: We might need a new state field for 'activeCommands' to update UI list

    emit(state.copyWith(isStreaming: true));

    // หยุด Timer เก่าถ้ามี
    _timer?.cancel();

    // เริ่ม Loop การส่งคำสั่งทุก 200ms
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!_connection.isConnected) {
        add(StopStreaming());
        return;
      }

      // ... (Rest of loop remains similar)

      Map<String, double> updatedValues = Map.from(state.currentValues);

      // ใช้ _activeCommands จาก class field เพื่อให้เปลี่ยนค่าได้กลางอากาศ
      for (var cmd in _activeCommands) {
        try {
          // 1. สร้าง Request
          final request = _engine.buildRequest(cmd);
          // 2. ส่งและรับ Response
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

      add(NewDataReceived(updatedValues));
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
