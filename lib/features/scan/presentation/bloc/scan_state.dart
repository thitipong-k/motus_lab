part of 'scan_bloc.dart';

enum ScanStatus { initial, scanning, connecting, connected, error }

class ScanState extends Equatable {
  final ScanStatus status;
  final List<ScanResult> results;
  final String? errorMessage;
  final String? connectedDeviceId;

  const ScanState({
    this.status = ScanStatus.initial,
    this.results = const [],
    this.errorMessage,
    this.connectedDeviceId,
  });

  ScanState copyWith({
    ScanStatus? status,
    List<ScanResult>? results,
    String? errorMessage,
    String? connectedDeviceId,
  }) {
    return ScanState(
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedDeviceId: connectedDeviceId ?? this.connectedDeviceId,
    );
  }

  @override
  List<Object?> get props => [status, results, errorMessage, connectedDeviceId];
}
