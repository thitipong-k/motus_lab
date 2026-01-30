import 'package:equatable/equatable.dart';

class LogSession extends Equatable {
  final int? id;
  final String vin;
  final DateTime startTime;
  final DateTime? endTime;
  final int recordCount;

  const LogSession({
    this.id,
    required this.vin,
    required this.startTime,
    this.endTime,
    this.recordCount = 0,
  });

  LogSession copyWith({
    int? id,
    String? vin,
    DateTime? startTime,
    DateTime? endTime,
    int? recordCount,
  }) {
    return LogSession(
      id: id ?? this.id,
      vin: vin ?? this.vin,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      recordCount: recordCount ?? this.recordCount,
    );
  }

  @override
  List<Object?> get props => [id, vin, startTime, endTime, recordCount];
}
