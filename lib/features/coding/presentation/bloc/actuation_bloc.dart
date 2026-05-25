import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/protocol/uds/uds_engine.dart';

// --- Events ---
abstract class ActuationEvent extends Equatable {
  const ActuationEvent();
  @override
  List<Object?> get props => [];
}

class StartActuationEvent extends ActuationEvent {
  final int did;
  final List<int> controlState; // e.g. [0x01] for ON
  
  const StartActuationEvent(this.did, this.controlState);
  @override
  List<Object?> get props => [did, controlState];
}

class StopActuationEvent extends ActuationEvent {
  final int did;
  const StopActuationEvent(this.did);
  @override
  List<Object?> get props => [did];
}

// --- States ---
abstract class ActuationState extends Equatable {
  const ActuationState();
  @override
  List<Object?> get props => [];
}

class ActuationIdle extends ActuationState {}

class ActuationInProgress extends ActuationState {
  final int did;
  final String message;
  const ActuationInProgress(this.did, this.message);
  @override
  List<Object?> get props => [did, message];
}

class ActuationSuccess extends ActuationState {
  final int did;
  final String message;
  const ActuationSuccess(this.did, this.message);
  @override
  List<Object?> get props => [did, message];
}

class ActuationError extends ActuationState {
  final int did;
  final String message;
  const ActuationError(this.did, this.message);
  @override
  List<Object?> get props => [did, message];
}

// --- BLoC ---
class ActuationBloc extends Bloc<ActuationEvent, ActuationState> {
  final UdsEngine udsEngine;

  ActuationBloc(this.udsEngine) : super(ActuationIdle()) {
    on<StartActuationEvent>(_onStartActuation);
    on<StopActuationEvent>(_onStopActuation);
  }

  Future<void> _onStartActuation(StartActuationEvent event, Emitter<ActuationState> emit) async {
    emit(ActuationInProgress(event.did, "Starting Actuation Test..."));
    try {
      // 0x03 = ShortTermAdjustment
      bool success = await udsEngine.inputOutputControlByIdentifier(
        event.did, 
        0x03, 
        controlState: event.controlState
      );
      
      if (success) {
        emit(ActuationSuccess(event.did, "Component is now ACTIVE"));
      } else {
        emit(ActuationError(event.did, "ECU rejected the actuation command"));
      }
    } catch (e) {
      emit(ActuationError(event.did, e.toString()));
    }
  }

  Future<void> _onStopActuation(StopActuationEvent event, Emitter<ActuationState> emit) async {
    emit(ActuationInProgress(event.did, "Stopping Actuation Test..."));
    try {
      // 0x00 = ReturnControlToECU
      bool success = await udsEngine.inputOutputControlByIdentifier(
        event.did, 
        0x00
      );
      
      if (success) {
        emit(ActuationSuccess(event.did, "Control returned to ECU"));
        // Revert to idle after a short delay
        await Future.delayed(const Duration(seconds: 2));
        if (!isClosed) {
          emit(ActuationIdle());
        }
      } else {
        emit(ActuationError(event.did, "Failed to return control to ECU"));
      }
    } catch (e) {
      emit(ActuationError(event.did, e.toString()));
    }
  }
}
