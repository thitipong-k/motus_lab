import 'package:equatable/equatable.dart';

class LogRecord extends Equatable {
  final int? id;
  final int sessionId;
  final DateTime timestamp;
  final String pidName;
  final double value;
  final String unit;

  const LogRecord({
    this.id,
    required this.sessionId,
    required this.timestamp,
    required this.pidName,
    required this.value,
    required this.unit,
  });

  @override
  List<Object?> get props => [id, sessionId, timestamp, pidName, value, unit];
}
