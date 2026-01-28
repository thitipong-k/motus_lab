import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:motus_lab/core/connection/bluetooth_service.dart' as motus;
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/connection/mock_connection.dart';

part 'scan_event.dart';
part 'scan_state.dart';

/// Bloc สำหรับจัดการหน้า Scan
/// ทำงานประสานกันระหว่าง BluetoothService (หน้าบ้าน) และ ConnectionInterface (หลังบ้าน)
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final motus.BluetoothService _bluetoothService;
  final ConnectionInterface _connection;
  StreamSubscription? _resultsSubscription;

  ScanBloc({
    required motus.BluetoothService bluetoothService,
    required ConnectionInterface connection,
  })  : _bluetoothService = bluetoothService,
        _connection = connection,
        super(const ScanState()) {
    // ลงทะเบียนจัดการ Event
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<ScanResultsUpdated>(_onScanResultsUpdated);
    on<ConnectToDevice>(_onConnectToDevice);
  }

  // เมื่อเริ่ม Scan
  Future<void> _onStartScan(StartScan event, Emitter<ScanState> emit) async {
    emit(state.copyWith(status: ScanStatus.scanning, results: []));

    // ดักฟังผลการ Scan
    await _resultsSubscription?.cancel();
    _resultsSubscription = _bluetoothService.scanResults.listen((results) {
      add(ScanResultsUpdated(results));
    });

    // เช็คว่าใช้ Mock Connection หรือไม่
    if (_connection is MockConnection) {
      await Future.delayed(
          const Duration(seconds: 1)); // Delay ให้ดูเหมือน Scan
      // สร้าง Fake Device เพื่อให้กด Connect ได้
      // หมายเหตุ: ต้องใช้ท่าลัดเพราะเราไม่ได้แก้ BluetoothService โดยตรง
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
      emit(
          state.copyWith(status: ScanStatus.error, errorMessage: e.toString()));
    }
  }

  // เมื่อหยุด Scan
  Future<void> _onStopScan(StopScan event, Emitter<ScanState> emit) async {
    await _bluetoothService.stopScan();
    emit(state.copyWith(status: ScanStatus.initial));
  }

  // เมื่อได้รายการอุปกรณ์ใหม่
  void _onScanResultsUpdated(
      ScanResultsUpdated event, Emitter<ScanState> emit) {
    emit(state.copyWith(results: event.results));
  }

  // เมื่อกดเชื่อมต่อ
  Future<void> _onConnectToDevice(
      ConnectToDevice event, Emitter<ScanState> emit) async {
    emit(state.copyWith(
        status: ScanStatus.connecting, connectedDeviceId: event.deviceId));

    try {
      await _bluetoothService.stopScan();
      await _connection.connect(event.deviceId);
      emit(state.copyWith(
          status: ScanStatus.connected, connectedDeviceId: event.deviceId));
    } catch (e) {
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
