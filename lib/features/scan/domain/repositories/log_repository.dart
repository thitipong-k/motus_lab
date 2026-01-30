import 'package:motus_lab/features/scan/domain/entities/log_record.dart';
import 'package:motus_lab/features/scan/domain/entities/log_session.dart';

abstract class LogRepository {
  /// Start a new logging session for the given VIN.
  Future<LogSession> startSession(String vin);

  /// Stop the current logging session (update end time).
  Future<void> stopSession(int sessionId);

  /// Save a batch of records to the database.
  Future<void> saveRecords(List<LogRecord> records);

  /// Get all logging sessions from history.
  Future<List<LogSession>> getSessions();

  /// Get all records for a specific session.
  Future<List<LogRecord>> getRecords(int sessionId);

  /// Delete a session and its records.
  Future<void> deleteSession(int sessionId);
}
