part of 'freeze_frame_bloc.dart';

abstract class FreezeFrameState extends Equatable {
  const FreezeFrameState();

  @override
  List<Object> get props => [];
}

class FreezeFrameInitial extends FreezeFrameState {}

class FreezeFrameLoading extends FreezeFrameState {}

class FreezeFrameLoaded extends FreezeFrameState {
  final Map<String, dynamic>
      data; // Key: PID Name, Value: Formatted String or raw value
  final String dtc; // The DTC that caused the freeze

  const FreezeFrameLoaded({required this.data, required this.dtc});

  @override
  List<Object> get props => [data, dtc];
}

class FreezeFrameError extends FreezeFrameState {
  final String message;

  const FreezeFrameError(this.message);

  @override
  List<Object> get props => [message];
}
