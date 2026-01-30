import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/domain/entities/command.dart';
import 'package:motus_lab/features/scan/data/repositories/protocol_repository.dart';
import 'package:motus_lab/features/scan/data/repositories/vehicle_profile_repository.dart';
import 'package:motus_lab/features/scan/domain/usecases/get_supported_pids.dart';
import 'package:motus_lab/features/scan/domain/usecases/read_vin.dart';
import 'package:motus_lab/features/scan/domain/repositories/log_repository.dart';
import 'package:motus_lab/features/scan/domain/entities/log_record.dart';
import 'package:motus_lab/features/scan/domain/entities/log_session.dart';

part 'live_data_event.dart';
part 'live_data_state.dart';

/// Bloc สำหรับจัดการค่าสด (Live Data)
/// [WORKFLOW STEP 2] Live Data Loop: หัวใจหลักของระบบ (Pull PIDs > Adaptive Polling > Display)
/// ทำหน้าที่ส่งคำสั่งชุดเดิมวนซ้ำ (Round-robin) เพื่อให้ UI อัพเดตตลอดเวลา
class LiveDataBloc extends Bloc<LiveDataEvent, LiveDataState> {
  final ProtocolEngine _engine;
  final ConnectionInterface _connection;
  final ProtocolRepository _repository;
  final VehicleProfileRepository _profileRepository;
  final GetSupportedPidsUseCase _getSupportedPids;
  final ReadVinUseCase _readVin;
  final LogRepository _logRepository;
  Timer? _timer;
  List<Command> _activeCommands = [];

  LiveDataBloc({
    required ProtocolEngine engine,
    required ConnectionInterface connection,
    required ProtocolRepository repository,
    required VehicleProfileRepository profileRepository,
    required GetSupportedPidsUseCase getSupportedPids,
    required ReadVinUseCase readVin,
    LogRepository? logRepository, // Optional for backward compatibility/testing
  })  : _engine = engine,
        _connection = connection,
        _repository = repository,
        _profileRepository = profileRepository,
        _getSupportedPids = getSupportedPids,
        _readVin = readVin,
        _logRepository = logRepository ??
            _DebugLogRepository(), // Fallback if not injected (mostly test/debug)
        super(const LiveDataState()) {
    on<StartStreaming>(_onStartStreaming);
    on<StopStreaming>(_onStopStreaming);
    on<UpdateActiveCommands>(_onUpdateActiveCommands);
    on<NewDataReceived>(_onNewDataReceived);
    on<LoadProtocol>(_onLoadProtocol);
    on<StartLogging>(_onStartLogging);
    on<StopLogging>(_onStopLogging);
  }

  Future<void> _onStartStreaming(
      StartStreaming event, Emitter<LiveDataState> emit) async {
    List<Command> commandsToUse = event.commands;

    if (commandsToUse.isEmpty || commandsToUse.length <= 3) {
      emit(state.copyWith(isStreaming: true, isDiscovering: true));

      List<String> supportedKeyCodes = [];
      String? currentVin;

      try {
        currentVin = await _readVin(null);
      } catch (e) {
        print("Error reading VIN: $e");
      }

      // Update VIN in state as soon as we have it
      if (currentVin != null) {
        emit(state.copyWith(vin: currentVin));
      }

      bool cacheHit = false;
      if (currentVin != null) {
        final cachedPids = await _getSupportedPids(currentVin);
        if (cachedPids != null && cachedPids.isNotEmpty) {
          print("Cache HIT for VIN: $currentVin. Skipping discovery.");
          supportedKeyCodes = cachedPids;
          cacheHit = true;
        }
      }

      // [WORKFLOW STEP 1] Identity Flow: ตรวจสอบ VIN และค้นหา PIDs ที่รองรับ
      // หากพบ VIN ในฐานข้อมูล จะดึงค่าเดิมมาใช้ทันที (Fast Start)
      // หากเป็นรถใหม่ จะทำการ Full Discovery เพื่อหาว่ากล่อง ECU ตอบรับ PID ไหนบ้าง
      if (!cacheHit) {
        print("Cache MISS. Starting Full Discovery...");
        await _checkSupportedPids("0100", supportedKeyCodes);
        await _checkSupportedPids("0120", supportedKeyCodes);
        await _checkSupportedPids("0140", supportedKeyCodes);
        print("Discovered PIDs: $supportedKeyCodes");

        if (currentVin != null && supportedKeyCodes.isNotEmpty) {
          await _profileRepository.saveProfile(
            vin: currentVin,
            protocol: "AUTO",
            supportedPids: supportedKeyCodes,
          );
        }
      }

      final allAvailable = _repository.getAllAvailablePids();
      commandsToUse = allAvailable.where((cmd) {
        return supportedKeyCodes.contains(cmd.code);
      }).toList();

      if (commandsToUse.isEmpty) {
        commandsToUse = _repository.getStandardPids();
      }

      emit(state.copyWith(
          isDiscovering: false, supportedPidCodes: supportedKeyCodes));
    }

    _activeCommands = commandsToUse;
    emit(state.copyWith(isStreaming: true, activeCommands: _activeCommands));

    _timer?.cancel();

    int tick = 0;
    final Map<String, int> _consecutiveErrors = {};
    final List<Command> _quarantinedCommands = [];
    const int _maxErrorsBeforeQuarantine = 5;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (!_connection.isConnected) {
        add(StopStreaming());
        return;
      }

      tick++;
      Map<String, double> updatedValues = Map.from(state.currentValues);

      if (tick % 200 == 0 && _quarantinedCommands.isNotEmpty) {
        final probeCmd = _quarantinedCommands.first;
        try {
          final request = _engine.buildRequest(probeCmd);
          final response = await _connection.send(request);
          if (response.isNotEmpty) {
            _quarantinedCommands.remove(probeCmd);
            _activeCommands.add(probeCmd);
            _consecutiveErrors[probeCmd.code] = 0;
          }
        } catch (e) {
          _quarantinedCommands.remove(probeCmd);
          _quarantinedCommands.add(probeCmd);
        }
      }

      // [WORKFLOW STEP 2] Adaptive Polling: จัดลำดับการส่งคำสั่งตาม Priority
      // High (RPM/Speed) : ส่งทุกครั้งที่ Tick
      // Normal (Engine Load): ส่งทุก 10 Ticks
      // Low (Temp): ส่งทุก 40 Ticks
      // พร้อมระบบ Quarantine: หาก PID ไหนตอบช้าหรือ Error ติดกัน 5 ครั้ง จะถูกพักไว้ชั่วคราว
      final commandsToPoll = _activeCommands.where((cmd) {
        if (_quarantinedCommands.contains(cmd)) return false;
        switch (cmd.priority) {
          case CommandPriority.high:
            return true;
          case CommandPriority.normal:
            return tick % 10 == 0;
          case CommandPriority.low:
            return tick % 40 == 0;
        }
      }).toList();

      if (commandsToPoll.isEmpty) return;

      for (var cmd in commandsToPoll) {
        try {
          final request = _engine.buildRequest(cmd);
          final response = await _connection.send(request);
          if (response.isNotEmpty) {
            final value = _engine.parseResponse(response, cmd.formula);
            updatedValues[cmd.name] = value;
            if (_consecutiveErrors.containsKey(cmd.code)) {
              _consecutiveErrors[cmd.code] = 0;
            }
          }
        } catch (e) {
          int errors = (_consecutiveErrors[cmd.code] ?? 0) + 1;
          _consecutiveErrors[cmd.code] = errors;
          if (errors >= _maxErrorsBeforeQuarantine) {
            _activeCommands.remove(cmd);
            _quarantinedCommands.add(cmd);
          }
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
        int startPid = int.parse(pidCode.substring(2), radix: 16);
        final pids = _engine.decodeSupportedPids(response, startPid);
        resultList.addAll(pids);
      }
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      print("Discovery Error ($pidCode): $e");
    }
  }

  void _onUpdateActiveCommands(
      UpdateActiveCommands event, Emitter<LiveDataState> emit) {
    _activeCommands = event.newCommands;
    emit(state.copyWith(activeCommands: _activeCommands));
  }

  Future<void> _onStopStreaming(
      StopStreaming event, Emitter<LiveDataState> emit) async {
    _timer?.cancel();
    if (state.isLogging) {
      add(StopLogging());
    }
    emit(state.copyWith(isStreaming: false));
  }

  Future<void> _onStartLogging(
      StartLogging event, Emitter<LiveDataState> emit) async {
    try {
      final vin =
          state.vin ?? "UNKNOWN_VIN_${DateTime.now().millisecondsSinceEpoch}";
      final session = await _logRepository.startSession(vin);
      emit(state.copyWith(isLogging: true, currentSessionId: session.id));
    } catch (e) {
      print("Start Logging Failed: $e");
    }
  }

  Future<void> _onStopLogging(
      StopLogging event, Emitter<LiveDataState> emit) async {
    if (state.currentSessionId != null) {
      await _logRepository.stopSession(state.currentSessionId!);
    }
    emit(state.copyWith(
        isLogging: false,
        currentSessionId:
            null)); // Or keep session ID for review? Better null for next start.
  }

  // Handle data reception and logging
  void _onNewDataReceived(NewDataReceived event, Emitter<LiveDataState> emit) {
    emit(state.copyWith(currentValues: event.values));

    // Logging Logic
    if (state.isLogging &&
        state.currentSessionId != null &&
        event.values.isNotEmpty) {
      final now = DateTime.now();
      List<LogRecord> records = [];

      // Find command defs for values to get units
      // Optimization: Use a Map for O(1) lookup if activeCommands is large

      for (var entry in event.values.entries) {
        final cmd = _activeCommands.firstWhere((c) => c.name == entry.key,
            orElse: () => Command(
                name: entry.key,
                code: "",
                description: "Unknown",
                formula: "",
                unit: ""));

        // Log only if valid command (optional) or just log everything
        records.add(LogRecord(
            sessionId: state.currentSessionId!,
            timestamp: now,
            pidName: entry.key,
            value: entry.value,
            unit: cmd.unit));
      }

      // Fire and forget save to avoid blocking UI?
      // Or wait? LogRepository uses file append which is fast.
      _logRepository.saveRecords(records);
    }
  }

  Future<void> _onLoadProtocol(
      LoadProtocol event, Emitter<LiveDataState> emit) async {
    emit(state.copyWith(isStreaming: false));
    _timer?.cancel();
    await _repository.loadProtocolPackFromAsset(event.assetPath);
    add(const StartStreaming([]));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    // Ensure we stop logging if bloc closes?
    if (state.isLogging && state.currentSessionId != null) {
      _logRepository.stopSession(state.currentSessionId!);
    }
    return super.close();
  }
}

// Dummy repo for fallback/testing
class _DebugLogRepository implements LogRepository {
  @override
  Future<void> deleteSession(int sessionId) async {}

  @override
  Future<List<LogRecord>> getRecords(int sessionId) async => [];

  @override
  Future<List<LogSession>> getSessions() async => [];

  @override
  Future<void> saveRecords(List<LogRecord> records) async {
    print("DEBUG LOG: ${records.length} records");
  }

  @override
  Future<LogSession> startSession(String vin) async {
    print("DEBUG START LOGGING: $vin");
    return LogSession(id: 999, vin: vin, startTime: DateTime.now());
  }

  @override
  Future<void> stopSession(int sessionId) async {
    print("DEBUG STOP LOGGING: $sessionId");
  }
} // Temporary Helper Class
