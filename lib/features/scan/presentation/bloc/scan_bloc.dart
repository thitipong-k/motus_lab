import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:motus_lab/core/connection/bluetooth_service.dart' as motus;
import 'package:motus_lab/features/scan/domain/usecases/connect_to_device.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/connection/mock_connection.dart';
import 'package:motus_lab/features/settings/domain/repositories/settings_repository.dart';
import 'package:motus_lab/core/services/vehicle_integration/home_widget_service.dart';
import 'package:motus_lab/core/utils/logger.dart';

part 'scan_event.dart';
part 'scan_state.dart';

/// Bloc สำหรับจัดการหน้า Scan
/// ทำงานประสานกันระหว่าง BluetoothService (หน้าบ้าน) และ ConnectionInterface (หลังบ้าน)
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final motus.BluetoothService _bluetoothService;
  final ConnectToDeviceUseCase _connectToDevice;
  final SettingsRepository _settingsRepository;
  final ConnectionInterface _connection;
  final HomeWidgetService _homeWidgetService;
  StreamSubscription? _resultsSubscription;

  ScanBloc({
    required motus.BluetoothService bluetoothService,
    required ConnectToDeviceUseCase connectToDevice,
    required ConnectionInterface connection,
    required SettingsRepository settingsRepository,
    HomeWidgetService? homeWidgetService,
  })  : _bluetoothService = bluetoothService,
        _connectToDevice = connectToDevice,
        _connection = connection,
        _settingsRepository = settingsRepository,
        _homeWidgetService = homeWidgetService ?? HomeWidgetService(),
        super(const ScanState()) {
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<ScanResultsUpdated>(_onScanResultsUpdated);
    on<ConnectToDevice>(_onConnectToDevice);
  }

  // เมื่อเริ่มต้นการสแกนอุปกรณ์ (StartScan)
  Future<void> _onStartScan(StartScan event, Emitter<ScanState> emit) async {
    emit(state.copyWith(status: ScanStatus.scanning, results: []));

    // Refactor: Use manual subscription but with better management
    // emit.forEach is better for one-to-one stream-to-state mapping,
    // but here we have explicit Start/Stop scan logic.
    await _resultsSubscription?.cancel();
    _resultsSubscription = _bluetoothService.scanResults.listen((results) {
      add(ScanResultsUpdated(results));
    });

    if (_connection is MockConnection) {
      await Future.delayed(const Duration(seconds: 1));

      final mockDevice =
          BluetoothDevice(remoteId: const DeviceIdentifier("MOCK-001"));

      final mockResult = ScanResult(
        device: mockDevice,
        advertisementData: AdvertisementData(
            advName: "Simulated OBDII",
            txPowerLevel: 0,
            appearance: 0,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: []),
        rssi: -50,
        timeStamp: DateTime.now(),
      );

      emit(state.copyWith(status: ScanStatus.scanning, results: [mockResult]));
      return;
    }

    try {
      await _bluetoothService.startScan();
    } catch (e) {
      Logger.error("ScanBloc: Error starting scan", e);
      emit(
          state.copyWith(status: ScanStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onStopScan(StopScan event, Emitter<ScanState> emit) async {
    await _bluetoothService.stopScan();
    await _resultsSubscription?.cancel();
    emit(state.copyWith(status: ScanStatus.initial));
  }

  void _onScanResultsUpdated(
      ScanResultsUpdated event, Emitter<ScanState> emit) {
    emit(state.copyWith(results: event.results));
  }

  // เมื่อผู้ใช้เลือกเชื่อมต่อกับอุปกรณ์ (ConnectToDevice)
  Future<void> _onConnectToDevice(
      ConnectToDevice event, Emitter<ScanState> emit) async {
    Logger.info("ScanBloc: Connecting to ${event.deviceId}...");
    emit(state.copyWith(
        status: ScanStatus.connecting, connectedDeviceId: event.deviceId));

    try {
      if (_connection is! MockConnection) {
        await _bluetoothService.stopScan();
      }

      final settings = await _settingsRepository.getSettings();
      await _connectToDevice(event.deviceId)
          .timeout(Duration(seconds: settings.connectionTimeoutSeconds));

      Logger.info("ScanBloc: Connected to ${event.deviceId}!");
      _homeWidgetService.updateConnectionStatus(isConnected: true);

      emit(state.copyWith(
          status: ScanStatus.connected, connectedDeviceId: event.deviceId));
    } catch (e) {
      Logger.error("ScanBloc: Connection Failed", e);
      _homeWidgetService.updateConnectionStatus(isConnected: false);
      emit(
          state.copyWith(status: ScanStatus.error, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _resultsSubscription?.cancel();
    return super.close();
  }
}
