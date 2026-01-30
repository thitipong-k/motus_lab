import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:motus_lab/features/scan/domain/entities/log_record.dart';
import 'package:motus_lab/features/scan/domain/entities/log_session.dart';
import 'package:motus_lab/features/scan/domain/repositories/log_repository.dart';

class LogRepositoryImpl implements LogRepository {
  static const String _logsDirName = 'logs';
  static const String _indexFileName = 'sessions_index.json';

  Future<Directory> get _directory async {
    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDir.path}/$_logsDirName');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    return logDir;
  }

  Future<File> get _indexFile async {
    final dir = await _directory;
    return File('${dir.path}/$_indexFileName');
  }

  @override
  Future<List<LogSession>> getSessions() async {
    try {
      final file = await _indexFile;
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);

      return jsonList.map((json) => _sessionFromJson(json)).toList();
    } catch (e) {
      print("Error reading log index: $e");
      return [];
    }
  }

  @override
  Future<LogSession> startSession(String vin) async {
    final sessions = await getSessions();
    final newId = sessions.isEmpty ? 1 : (sessions.last.id ?? 0) + 1;
    final now = DateTime.now();

    final newSession = LogSession(
      id: newId,
      vin: vin,
      startTime: now,
    );

    sessions.add(newSession);
    await _saveIndex(sessions);
    return newSession;
  }

  @override
  Future<void> stopSession(int sessionId) async {
    final sessions = await getSessions();
    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = sessions[index];
      final updatedSession = session.copyWith(endTime: DateTime.now());
      sessions[index] = updatedSession;
      await _saveIndex(sessions);
    }
  }

  @override
  Future<void> saveRecords(List<LogRecord> records) async {
    if (records.isEmpty) return;

    final sessionId = records.first.sessionId;
    final dir = await _directory;
    final file = File('${dir.path}/session_$sessionId.csv');

    // Append mode
    final sink = file.openWrite(mode: FileMode.append);

    // If file is new, write header
    if (!await file.exists() || await file.length() == 0) {
      sink.writeln('Timestamp,PID,Value,Unit');
    }

    for (var record in records) {
      sink.writeln(
          '${record.timestamp.toIso8601String()},${record.pidName},${record.value},${record.unit}');
    }

    await sink.flush();
    await sink.close();

    // Update record count in index
    await _updateRecordCount(sessionId, records.length);
  }

  Future<void> _updateRecordCount(int sessionId, int addedCount) async {
    final sessions = await getSessions();
    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = sessions[index];
      final updatedSession =
          session.copyWith(recordCount: session.recordCount + addedCount);
      sessions[index] = updatedSession;
      await _saveIndex(sessions);
    }
  }

  @override
  Future<List<LogRecord>> getRecords(int sessionId) async {
    try {
      final dir = await _directory;
      final file = File('${dir.path}/session_$sessionId.csv');
      if (!await file.exists()) return [];

      final lines = await file.readAsLines();
      if (lines.isEmpty) return [];

      // Skip header
      final records = <LogRecord>[];
      for (var i = 1; i < lines.length; i++) {
        final parts = lines[i].split(',');
        if (parts.length >= 4) {
          records.add(LogRecord(
            sessionId: sessionId,
            timestamp: DateTime.parse(parts[0]),
            pidName: parts[1],
            value: double.tryParse(parts[2]) ?? 0.0,
            unit: parts[3],
          ));
        }
      }
      return records;
    } catch (e) {
      print("Error loading records: $e");
      return [];
    }
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await _saveIndex(sessions);

    final dir = await _directory;
    final file = File('${dir.path}/session_$sessionId.csv');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _saveIndex(List<LogSession> sessions) async {
    final file = await _indexFile;
    final jsonList = sessions.map((s) => _sessionToJson(s)).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // --- JSON Serialization Helpers ---
  Map<String, dynamic> _sessionToJson(LogSession session) {
    return {
      'id': session.id,
      'vin': session.vin,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'recordCount': session.recordCount,
    };
  }

  LogSession _sessionFromJson(Map<String, dynamic> json) {
    return LogSession(
      id: json['id'],
      vin: json['vin'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      recordCount: json['recordCount'] ?? 0,
    );
  }
}
