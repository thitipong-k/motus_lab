part of 'scan_bloc.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object> get props => [];
}

/// อีเวนต์เริ่มการค้นหา
class StartScan extends ScanEvent {}

/// อีเวนต์หยุดการค้นหา
class StopScan extends ScanEvent {}

/// อีเวนต์เมื่อเจอรายการอุปกรณ์ใหม่
class ScanResultsUpdated extends ScanEvent {
  final List<ScanResult> results;
  const ScanResultsUpdated(this.results);

  @override
  List<Object> get props => [results];
}

/// อีเวนต์การเชื่อมต่ออุปกรณ์
class ConnectToDevice extends ScanEvent {
  final String deviceId;
  const ConnectToDevice(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}
