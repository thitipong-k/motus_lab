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
import 'package:motus_lab/core/services/logger.dart';
import 'package:motus_lab/features/scan/data/repositories/vehicle_stats_repository.dart';

part 'live_data_event.dart';
part 'live_data_state.dart';

/// Bloc สำหรับจัดการค่าสด (Live Data)
/// [WORKFLOW STEP 2] Live Data Loop: หัวใจหลักของระบบ (Pull PIDs > Adaptive Polling > Display)
/// ทำหน้าที่เป็นศูนย์กลางการควบคุมการดึงข้อมูลจากรถแบบวนลูป
class LiveDataBloc extends Bloc<LiveDataEvent, LiveDataState> {
  final ProtocolEngine _engine;
  final ConnectionInterface _connection;
  final ProtocolRepository _repository;
  final VehicleProfileRepository _profileRepository;
  final GetSupportedPidsUseCase _getSupportedPids;
  final ReadVinUseCase _readVin;
  final LogRepository _logRepository;
  final VehicleStatsRepository
      _vehicleStatsRepository; // เพื่อรองรับการเดารุ่นรถ (Predictive Caching)
  Timer? _timer;
  List<Command> _activeCommands = [];

  LiveDataBloc({
    required ProtocolEngine engine,
    required ConnectionInterface connection,
    required ProtocolRepository repository,
    required VehicleProfileRepository profileRepository,
    required GetSupportedPidsUseCase getSupportedPids,
    required ReadVinUseCase readVin,
    required VehicleStatsRepository
        vehicleStatsRepository, // บังคับใส่เพื่อเก็บสถิติ
    LogRepository? logRepository, // Optional for backward compatibility/testing
  })  : _engine = engine,
        _connection = connection,
        _repository = repository,
        _profileRepository = profileRepository,
        _getSupportedPids = getSupportedPids,
        _readVin = readVin,
        _vehicleStatsRepository = vehicleStatsRepository,
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

  /// เริ่มต้นการสตรีมข้อมูล
  /// ขั้นตอน: อ่าน VIN > ค้นหา PIDs ที่รองรับ > เริ่มลูปดึงข้อมูล
  Future<void> _onStartStreaming(
      StartStreaming event, Emitter<LiveDataState> emit) async {
    List<Command> commandsToUse = event.commands;

    if (commandsToUse.isEmpty || commandsToUse.length <= 3) {
      // 1. ตรวจสอบการเชื่อมต่อก่อนเริ่ม
      if (!_connection.isConnected) {
        Logger.info(
            "LiveDataBloc: ยังไม่ได้เชื่อมต่ออุปกรณ์ รอการเชื่อมต่อ...");
        return;
      }
      emit(state.copyWith(isStreaming: true, isDiscovering: true));

      List<String> supportedKeyCodes = [];
      String? currentVin;

      // 2. พยายามอ่านเลขตัวถัง (VIN) เพื่อระบุตัวตนรถ
      try {
        currentVin = await _readVin(null);
      } catch (e) {
        Logger.error("Error reading VIN: $e");
      }

      if (currentVin != null) {
        emit(state.copyWith(vin: currentVin));

        // บันทึกสถิติการสแกนเพื่อใช้ในการเดาโปรโตคอลในครั้งถัดไป (Predictive)
        _vehicleStatsRepository.incrementScanCount(
          year: currentVin.contains("2024") ? 2024 : 2022,
          make: "Honda",
          model: "Civic FE",
        );
      }

      // 3. ตรวจสอบว่าเคยสแกนรถคันนี้แล้วหรือไม่ (Cache Discovery)
      bool cacheHit = false;
      if (currentVin != null) {
        final cachedPids = await _getSupportedPids(currentVin);
        if (cachedPids != null && cachedPids.isNotEmpty) {
          Logger.info(
              "พบข้อมูล PID ในแคชสำหรับ VIN: $currentVin. ข้ามขั้นตอนสแกนใหม่");
          supportedKeyCodes = cachedPids;
          cacheHit = true;
        }
      }

      // 4. หากไม่มีแคช ให้สแกนหา PID ที่รถรองรับแบบ Full Discovery
      if (!cacheHit) {
        Logger.info("ไม่พบข้อมูลในแคช เริ่มการสแกนหา PID ที่รองรับ...");
        await _checkSupportedPids("0100", supportedKeyCodes);
        await _checkSupportedPids("0120", supportedKeyCodes);
        await _checkSupportedPids("0140", supportedKeyCodes);
        Logger.info("ผลการสแกนพบ PID ที่รองรับ: $supportedKeyCodes");

        if (currentVin != null && supportedKeyCodes.isNotEmpty) {
          await _profileRepository.saveProfile(
            vin: currentVin,
            protocol: "AUTO",
            supportedPids: supportedKeyCodes,
          );
        }
      }

      // 5. กรองเฉพาะคำสั่งที่รถคันนี้รองรับจริงๆ รวมถึงตัดคำสั่งเช็คสถานะทิ้ง
      final allAvailable = _repository.getAllAvailablePids();
      commandsToUse = allAvailable.where((cmd) {
        final bool isSupportCheck = cmd.code.length == 4 &&
            cmd.code.startsWith("01") &&
            (cmd.code.endsWith("00") ||
                cmd.code.endsWith("20") ||
                cmd.code.endsWith("40") ||
                cmd.code.endsWith("60") ||
                cmd.code.endsWith("80") ||
                cmd.code.endsWith("A0") ||
                cmd.code.endsWith("C0") ||
                cmd.code.endsWith("E0"));

        if (isSupportCheck) return false;
        if (cmd.code == "0902")
          return false; // ข้อมูล VIN ไม่แสดงใน Dashboard เซนเซอร์

        return supportedKeyCodes.contains(cmd.code);
      }).toList();

      // Fallback: หากสแกนไม่สำเร็จให้ใช้ค่ามาตรฐานพื้นฐาน
      if (commandsToUse.isEmpty) {
        commandsToUse = _repository.getStandardPids().where((cmd) {
          final bool isSupportCheck = cmd.code.length == 4 &&
              cmd.code.startsWith("01") &&
              (cmd.code.endsWith("00") ||
                  cmd.code.endsWith("20") ||
                  cmd.code.endsWith("40"));
          return !isSupportCheck;
        }).toList();
      }

      emit(state.copyWith(
          isDiscovering: false, supportedPidCodes: supportedKeyCodes));
    }

    _activeCommands = commandsToUse;
    emit(state.copyWith(isStreaming: true, activeCommands: _activeCommands));

    // 6. เริ่มลูปดึงข้อมูลวนรอบ (Polling Loop)
    _timer?.cancel();
    _startPollingLoop();
  }

  /// ระบบการดึงข้อมูลแบบวนลูปต่อเนื่อง (Sequential Polling Loop)
  /// ออกแบบมาเพื่อป้องกัน UI Freeze โดยการทำงานแบบทีละตัวแทนทีละชุดหลายตัวพร้อมกัน
  void _startPollingLoop() {
    int tick = 0;
    final Map<String, int> consecutiveErrors = {};
    final List<Command> quarantinedCommands = [];
    const int maxErrorsBeforeQuarantine = 5;

    Future<void> poll() async {
      if (!state.isStreaming || !_connection.isConnected) {
        Logger.info("หยุดการทำงานของลูปดึงข้อมูล (Disconnected or Stopped)");
        return;
      }

      tick++;
      final Map<String, double> updatedValues = Map.from(state.currentValues);

      // กู้คืนคำสั่งที่ถูกกักบริเวณ (Quarantine) เพื่อลองใหม่เป็นระยะๆ
      if (tick % 200 == 0 && quarantinedCommands.isNotEmpty) {
        final probeCmd = quarantinedCommands.first;
        try {
          // ใช้ Standardized ObdRequest
          final request = _engine.buildRequest(probeCmd);
          final response = await _connection.send(request);
          if (response.hasValidData) {
            quarantinedCommands.remove(probeCmd);
            _activeCommands.add(probeCmd);
            consecutiveErrors[probeCmd.code] = 0;
          }
        } catch (_) {}
      }

      // ระบบจัดการลำดับความสำคัญ (Adaptive Polling)
      // ช่วยประหยัดแบนด์วิดท์โดยดึงข้อมูลตัวกะพริบช้าให้น้อยลง
      final commandsToPoll = _activeCommands.where((cmd) {
        if (quarantinedCommands.contains(cmd)) return false;
        switch (cmd.priority) {
          case CommandPriority.high:
            return true; // ดึงทุกรอบ (เช่น รอบเครื่อง Speed)
          case CommandPriority.normal:
            return tick % 10 == 0; // ดึงทุก 10 รอบ
          case CommandPriority.low:
            return tick % 40 == 0; // ดึงทุก 40 รอบ (เช่น อุณหภูมิ)
        }
      }).toList();

      if (commandsToPoll.isNotEmpty) {
        for (final cmd in commandsToPoll) {
          try {
            // STEP: สร้างคำสั่ง > ส่งผ่าน Connection > รับ ObdResponse > ประมวลผล
            final request = _engine.buildRequest(cmd);
            final response = await _connection.send(request);

            if (response.hasValidData) {
              final value = _engine.parseResponse(response, cmd.formula,
                  script: cmd.script);
              updatedValues[cmd.name] = value;
              consecutiveErrors[cmd.code] = 0; // รีเซ็ตการนับ Error
            }
          } catch (e) {
            // ระบบกักบริเวณคำสั่งที่พังเพื่อไม่ให้หน่วงระบบโดยรวม (Fault Isolation)
            final int errors = (consecutiveErrors[cmd.code] ?? 0) + 1;
            consecutiveErrors[cmd.code] = errors;
            if (errors >= maxErrorsBeforeQuarantine) {
              _activeCommands.remove(cmd);
              quarantinedCommands.add(cmd);
            }
          }
        }
        add(NewDataReceived(updatedValues));
      }

      // กำหนดรอบการทำงานถัดไปแบบ Non-blocking
      _timer = Timer(const Duration(milliseconds: 10), poll);
    }

    poll();
  }

  /// ฟังก์ชันช่วยในการเช็ค PID ที่รองรับทีละช่วง (00, 20, 40)
  Future<void> _checkSupportedPids(
      String pidCode, List<String> resultList) async {
    try {
      final cmd = _repository.getCommandByCode(pidCode);
      if (cmd == null) return;

      // ใช้ระบบ Request/Response แบบใหม่ เพื่อความปลอดภัยของข้อมูล
      final request = _engine.buildRequest(cmd);
      final response = await _connection.send(request);

      if (response.hasValidData) {
        final int startPid = int.parse(pidCode.substring(2), radix: 16);
        final pids = _engine.decodeSupportedPids(response.rawData, startPid);
        resultList.addAll(pids);
      }
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      Logger.error("Error ระหว่างการเช็ค PID รองรับ ($pidCode): $e");
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
      Logger.error("Start Logging Failed: $e");
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
      final DateTime now = DateTime.now();
      final List<LogRecord> records = [];

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
    Logger.info("DEBUG LOG: ${records.length} records");
  }

  @override
  Future<LogSession> startSession(String vin) async {
    Logger.info("DEBUG START LOGGING: $vin");
    return LogSession(id: 999, vin: vin, startTime: DateTime.now());
  }

  @override
  Future<void> stopSession(int sessionId) async {
    Logger.info("DEBUG STOP LOGGING: $sessionId");
  }
} // Temporary Helper Class
