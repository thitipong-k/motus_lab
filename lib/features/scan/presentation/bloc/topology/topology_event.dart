part of 'topology_bloc.dart';

abstract class TopologyEvent extends Equatable {
  const TopologyEvent();

  @override
  List<Object> get props => [];
}

class StartTopologyScan extends TopologyEvent {}

class ResetTopology extends TopologyEvent {}
