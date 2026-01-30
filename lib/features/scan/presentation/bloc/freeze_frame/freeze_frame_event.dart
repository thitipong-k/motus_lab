part of 'freeze_frame_bloc.dart';

abstract class FreezeFrameEvent extends Equatable {
  const FreezeFrameEvent();

  @override
  List<Object> get props => [];
}

class LoadFreezeFrameData extends FreezeFrameEvent {}
