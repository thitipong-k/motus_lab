import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/protocol/uds/uds_engine.dart';

// --- Events ---
abstract class BasicSettingsEvent extends Equatable {
  const BasicSettingsEvent();
  @override
  List<Object?> get props => [];
}

class StartRoutineEvent extends BasicSettingsEvent {
  final int routineId;
  const StartRoutineEvent(this.routineId);
  @override
  List<Object?> get props => [routineId];
}

class ResetBasicSettingsEvent extends BasicSettingsEvent {}

// --- States ---
abstract class BasicSettingsState extends Equatable {
  const BasicSettingsState();
  @override
  List<Object?> get props => [];
}

class BasicSettingsIdle extends BasicSettingsState {}

class BasicSettingsInProgress extends BasicSettingsState {
  final int routineId;
  final String message;
  const BasicSettingsInProgress(this.routineId, this.message);
  @override
  List<Object?> get props => [routineId, message];
}

class BasicSettingsSuccess extends BasicSettingsState {
  final int routineId;
  final String message;
  const BasicSettingsSuccess(this.routineId, this.message);
  @override
  List<Object?> get props => [routineId, message];
}

class BasicSettingsError extends BasicSettingsState {
  final int routineId;
  final String message;

  const BasicSettingsError(this.routineId, this.message);

  @override
  List<Object> get props => [routineId, message];
}

class BasicSettingsSgwLocked extends BasicSettingsState {
  final int routineId;
  final String message;

  const BasicSettingsSgwLocked(this.routineId, this.message);

  @override
  List<Object> get props => [routineId, message];
}

// --- BLoC ---
class BasicSettingsBloc extends Bloc<BasicSettingsEvent, BasicSettingsState> {
  final UdsEngine udsEngine;

  BasicSettingsBloc(this.udsEngine) : super(BasicSettingsIdle()) {
    on<StartRoutineEvent>(_onStartRoutine);
    on<ResetBasicSettingsEvent>((event, emit) => emit(BasicSettingsIdle()));
  }

  Future<void> _onStartRoutine(StartRoutineEvent event, Emitter<BasicSettingsState> emit) async {
    emit(BasicSettingsInProgress(event.routineId, "Executing Routine..."));
    try {
      bool success = await udsEngine.startRoutine(event.routineId);
      
      if (success) {
        emit(BasicSettingsSuccess(event.routineId, "Routine completed successfully"));
      } else {
        emit(BasicSettingsError(event.routineId, "ECU rejected or failed the routine"));
      }
    } on UdsSecurityException catch (e) {
      emit(BasicSettingsSgwLocked(event.routineId, e.message));
    } catch (e) {
      emit(BasicSettingsError(event.routineId, e.toString()));
    }
  }
}
