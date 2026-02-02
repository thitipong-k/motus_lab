part of 'scan_bloc.dart';

sealed class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object> get props => [];
}

/// อีเวนต์เริ่มการค้นหา
final class StartScan extends ScanEvent {}

/// อีเวนต์หยุดการค้นหา
final class StopScan extends ScanEvent {}

/// อีเวนต์เมื่อเจอรายการอุปกรณ์ใหม่
final class ScanResultsUpdated extends ScanEvent {
  final List<ScanResult> results;
  const ScanResultsUpdated(this.results);

  @override
  List<Object> get props => [results];
}

/// อีเวนต์การเชื่อมต่ออุปกรณ์
final class ConnectToDevice extends ScanEvent {
  final String deviceId;
  const ConnectToDevice(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}
