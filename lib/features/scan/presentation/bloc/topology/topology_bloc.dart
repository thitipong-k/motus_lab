import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';
import 'package:motus_lab/features/scan/domain/repositories/topology_repository.dart';

part 'topology_event.dart';
part 'topology_state.dart';

class TopologyBloc extends Bloc<TopologyEvent, TopologyState> {
  final TopologyRepository _repository;

  TopologyBloc({required TopologyRepository repository})
      : _repository = repository,
        super(const TopologyState()) {
    on<StartTopologyScan>(_onStartTopologyScan);
    on<ResetTopology>(_onResetTopology);
  }

  Future<void> _onStartTopologyScan(
      StartTopologyScan event, Emitter<TopologyState> emit) async {
    // เริ่มต้นการแสกน: ตั้งค่า isScanning = true และเคลียร์ node เก่า
    emit(state.copyWith(isScanning: true, nodes: []));

    // Listen to the stream and update state incrementally
    // รับข้อมูลจาก Stream ของ Repository ทีละ Node แล้วอัพเดต UI
    await emit.forEach<EcuNode>(
      _repository.scanModules(),
      onData: (node) {
        final List<EcuNode> updatedNodes = List.from(state.nodes)..add(node);
        return state.copyWith(nodes: updatedNodes);
      },
    );

    // สิ้นสุดการแสกน
    emit(state.copyWith(isScanning: false));
  }

  void _onResetTopology(ResetTopology event, Emitter<TopologyState> emit) {
    emit(const TopologyState());
  }
}
