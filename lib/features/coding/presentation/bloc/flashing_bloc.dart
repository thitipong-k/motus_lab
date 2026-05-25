import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/protocol/uds/uds_engine.dart';
import 'package:motus_lab/core/protocol/security/security_access_handler.dart';

// --- Events ---
abstract class FlashingEvent extends Equatable {
  const FlashingEvent();
  @override
  List<Object?> get props => [];
}

class StartFlashingEvent extends FlashingEvent {
  final Uint8List binaryFile;
  final SecurityAccessHandler securityHandler;
  
  const StartFlashingEvent(this.binaryFile, this.securityHandler);
}

class CancelFlashingEvent extends FlashingEvent {}

// --- States ---
abstract class FlashingState extends Equatable {
  const FlashingState();
  @override
  List<Object?> get props => [];
}

class FlashingIdle extends FlashingState {}
class FlashingUnlocking extends FlashingState {}
class FlashingErasing extends FlashingState {}
class FlashingTransferring extends FlashingState {
  final double progress; // 0.0 to 1.0
  const FlashingTransferring(this.progress);
  @override
  List<Object?> get props => [progress];
}
class FlashingValidating extends FlashingState {}
class FlashingSuccess extends FlashingState {}
class FlashingError extends FlashingState {
  final String message;
  const FlashingError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
/// FlashingBloc manages the critical state machine for ECU Module Flashing (Coding)
/// It utilizes the UDSEngine to securely write binary files to vehicle ECUs.
class FlashingBloc extends Bloc<FlashingEvent, FlashingState> {
  final UdsEngine udsEngine;

  FlashingBloc(this.udsEngine) : super(FlashingIdle()) {
    on<StartFlashingEvent>(_onStartFlashing);
    on<CancelFlashingEvent>(_onCancelFlashing);
  }

  Future<void> _onStartFlashing(StartFlashingEvent event, Emitter<FlashingState> emit) async {
    try {
      // 1. Programming Session
      emit(FlashingUnlocking());
      bool sessionOk = await udsEngine.startSession(0x02); // 0x02 Programming Session
      if (!sessionOk) throw Exception("Failed to enter Programming Session (0x10 0x02)");

      // 2. Security Access
      bool unlocked = await udsEngine.unlockSecurity(event.securityHandler);
      if (!unlocked) throw Exception("Security Access Denied (Seed/Key mismatch)");

      // 3. Erase Memory (using UDS Routine Control)
      emit(FlashingErasing());
      bool erased = await udsEngine.startRoutine(0xFF00); // 0xFF00 is an example erase routine ID
      if (!erased) throw Exception("Failed to erase flash memory");

      // 4. Transfer Data
      emit(const FlashingTransferring(0.0));
      // Note: In a real implementation, we split the binary into chunks according to maxPayloadSize
      // and loop through UDS 0x34 RequestDownload and 0x36 TransferData. 
      // This is a simplified simulation of the transfer loop.
      await Future.delayed(const Duration(seconds: 2)); 
      emit(const FlashingTransferring(1.0));

      // 5. Validation / Checksum
      emit(FlashingValidating());
      bool validated = await udsEngine.startRoutine(0xFF01); // 0xFF01 is an example validation routine ID
      if (!validated) throw Exception("Flash validation failed (Checksum error)");

      emit(FlashingSuccess());

    } catch (e) {
      emit(FlashingError(e.toString()));
    }
  }

  void _onCancelFlashing(CancelFlashingEvent event, Emitter<FlashingState> emit) {
    emit(const FlashingError("Flashing cancelled by user. Warning: ECU may be in an unstable state."));
  }
}
