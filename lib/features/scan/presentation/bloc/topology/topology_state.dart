part of 'topology_bloc.dart';

class TopologyState extends Equatable {
  final List<EcuNode> nodes;
  final bool isScanning;

  const TopologyState({
    this.nodes = const [],
    this.isScanning = false,
  });

  TopologyState copyWith({
    List<EcuNode>? nodes,
    bool? isScanning,
  }) {
    return TopologyState(
      nodes: nodes ?? this.nodes,
      isScanning: isScanning ?? this.isScanning,
    );
  }

  @override
  List<Object> get props => [nodes, isScanning];
}
