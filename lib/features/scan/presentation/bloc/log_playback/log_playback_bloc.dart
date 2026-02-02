import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/features/scan/domain/entities/log_record.dart';
import 'package:motus_lab/features/scan/domain/entities/log_session.dart';
import 'package:motus_lab/features/scan/domain/repositories/log_repository.dart';

// --- Events ---
abstract class LogPlaybackEvent extends Equatable {
  const LogPlaybackEvent();
  @override
  List<Object?> get props => [];
}

class LoadLogSession extends LogPlaybackEvent {
  final LogSession session;
  const LoadLogSession(this.session);
  @override
  List<Object?> get props => [session];
}

class PlayPlayback extends LogPlaybackEvent {}

class PausePlayback extends LogPlaybackEvent {}

class SeekPlayback extends LogPlaybackEvent {
  final double position; // 0.0 to 1.0
  const SeekPlayback(this.position);
  @override
  List<Object?> get props => [position];
}

class TickPlayback extends LogPlaybackEvent {}

// --- State ---
class LogPlaybackState extends Equatable {
  final LogSession? session;
  final List<LogRecord> allRecords;
  final Map<String, List<LogRecord>> recordsByPid;
  final bool isLoading;
  final bool isPlaying;
  final double playbackPosition; // 0.0 to 1.0
  final Map<String, double> currentValues;
  final DateTime? currentTimestamp;

  const LogPlaybackState({
    this.session,
    this.allRecords = const [],
    this.recordsByPid = const {},
    this.isLoading = false,
    this.isPlaying = false,
    this.playbackPosition = 0.0,
    this.currentValues = const {},
    this.currentTimestamp,
  });

  LogPlaybackState copyWith({
    LogSession? session,
    List<LogRecord>? allRecords,
    Map<String, List<LogRecord>>? recordsByPid,
    bool? isLoading,
    bool? isPlaying,
    double? playbackPosition,
    Map<String, double>? currentValues,
    DateTime? currentTimestamp,
  }) {
    return LogPlaybackState(
      session: session ?? this.session,
      allRecords: allRecords ?? this.allRecords,
      recordsByPid: recordsByPid ?? this.recordsByPid,
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      currentValues: currentValues ?? this.currentValues,
      currentTimestamp: currentTimestamp ?? this.currentTimestamp,
    );
  }

  @override
  List<Object?> get props => [
        session,
        allRecords,
        recordsByPid,
        isLoading,
        isPlaying,
        playbackPosition,
        currentValues,
        currentTimestamp,
      ];
}

// --- Bloc ---
class LogPlaybackBloc extends Bloc<LogPlaybackEvent, LogPlaybackState> {
  final LogRepository _repository;
  Timer? _playbackTimer;

  LogPlaybackBloc({required LogRepository repository})
      : _repository = repository,
        super(const LogPlaybackState()) {
    on<LoadLogSession>(_onLoadLogSession);
    on<PlayPlayback>(_onPlayPlayback);
    on<PausePlayback>(_onPausePlayback);
    on<SeekPlayback>(_onSeekPlayback);
    on<TickPlayback>(_onTickPlayback);
  }

  Future<void> _onLoadLogSession(
      LoadLogSession event, Emitter<LogPlaybackState> emit) async {
    emit(state.copyWith(isLoading: true, session: event.session));

    final records = await _repository.getRecords(event.session.id!);

    // Group records by PID for easier graphing
    final Map<String, List<LogRecord>> byPid = {};
    for (var record in records) {
      byPid.putIfAbsent(record.pidName, () => []).add(record);
    }

    emit(state.copyWith(
      isLoading: false,
      allRecords: records,
      recordsByPid: byPid,
      playbackPosition: 0.0,
      currentValues: _getValuesAtPosition(records, 0.0),
      currentTimestamp: records.isNotEmpty ? records.first.timestamp : null,
    ));
  }

  void _onPlayPlayback(PlayPlayback event, Emitter<LogPlaybackState> emit) {
    if (state.isPlaying) return;
    emit(state.copyWith(isPlaying: true));

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      add(TickPlayback());
    });
  }

  void _onPausePlayback(PausePlayback event, Emitter<LogPlaybackState> emit) {
    _playbackTimer?.cancel();
    emit(state.copyWith(isPlaying: false));
  }

  void _onTickPlayback(TickPlayback event, Emitter<LogPlaybackState> emit) {
    if (state.playbackPosition >= 1.0) {
      _playbackTimer?.cancel();
      emit(state.copyWith(isPlaying: false, playbackPosition: 1.0));
      return;
    }

    final newPosition = state.playbackPosition + 0.01; // Simulation speed
    final clampedPosition = newPosition.clamp(0.0, 1.0);

    emit(state.copyWith(
      playbackPosition: clampedPosition,
      currentValues: _getValuesAtPosition(state.allRecords, clampedPosition),
      currentTimestamp:
          _getTimestampAtPosition(state.allRecords, clampedPosition),
    ));
  }

  void _onSeekPlayback(SeekPlayback event, Emitter<LogPlaybackState> emit) {
    emit(state.copyWith(
      playbackPosition: event.position,
      currentValues: _getValuesAtPosition(state.allRecords, event.position),
      currentTimestamp:
          _getTimestampAtPosition(state.allRecords, event.position),
    ));
  }

  Map<String, double> _getValuesAtPosition(
      List<LogRecord> records, double position) {
    if (records.isEmpty) return {};

    final targetIndex =
        (records.length * position).floor().clamp(0, records.length - 1);
    final targetTimestamp = records[targetIndex].timestamp;

    final Map<String, double> values = {};
    // This is a simple implementation: find the last known value for each PID at this time
    for (var record in records) {
      if (record.timestamp.isAfter(targetTimestamp)) break;
      values[record.pidName] = record.value;
    }
    return values;
  }

  DateTime? _getTimestampAtPosition(List<LogRecord> records, double position) {
    if (records.isEmpty) return null;
    final index =
        (records.length * position).floor().clamp(0, records.length - 1);
    return records[index].timestamp;
  }

  @override
  Future<void> close() {
    _playbackTimer?.cancel();
    return super.close();
  }
}
