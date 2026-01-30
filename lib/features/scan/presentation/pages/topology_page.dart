import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/features/scan/presentation/bloc/topology/topology_bloc.dart';
import 'package:motus_lab/features/scan/data/repositories/topology_repository_impl.dart';
import 'package:motus_lab/features/scan/presentation/widgets/topology/topology_painter.dart';
import 'package:motus_lab/features/scan/presentation/widgets/topology/ecu_detail_dialog.dart';

class TopologyPage extends StatelessWidget {
  const TopologyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TopologyBloc(repository: TopologyRepositoryImpl()),
      child: const _TopologyView(),
    );
  }
}

class _TopologyView extends StatefulWidget {
  const _TopologyView();

  @override
  State<_TopologyView> createState() => _TopologyViewState();
}

class _TopologyViewState extends State<_TopologyView> {
  @override
  void initState() {
    super.initState();
    // Auto-start scan on page load
    context.read<TopologyBloc>().add(StartTopologyScan());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VEHICLE TOPOLOGY"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Rescan Network",
            onPressed: () {
              context.read<TopologyBloc>().add(StartTopologyScan());
            },
          )
        ],
      ),
      body: BlocBuilder<TopologyBloc, TopologyState>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isScanning)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text("Scanning CAN Bus..."),
                  ),

                // Topology Canvas
                // พื้นที่วาดแผนผังเครือข่ายรถยนต์ รองรับการกดเพื่อดูรายละเอียด
                GestureDetector(
                  onTapUp: (details) {
                    // ตรวจสอบตำแหน่งการกดว่าตรงกับ Node ไหนหรือไม่
                    _handleTap(details.localPosition, state.nodes);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 400,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: CustomPaint(
                      painter: TopologyPainter(state.nodes),
                    ),
                  ),
                ),

                if (!state.isScanning && state.nodes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Found ${state.nodes.length} Modules",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleTap(Offset localPosition, List<dynamic> nodes) {
    // Simple hit test: check distance to each node
    // Node radius is likely ~30-40px defined in Painter
    const double hitRadius = 40.0;

    for (var node in nodes) {
      final dx = localPosition.dx - node.position.dx;
      final dy = localPosition.dy - node.position.dy;
      if ((dx * dx + dy * dy) <= (hitRadius * hitRadius)) {
        // Hit!
        showDialog(
          context: context,
          builder: (context) => EcuDetailDialog(node: node),
        );
        break;
      }
    }
  }
}
