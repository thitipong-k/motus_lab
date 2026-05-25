import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/features/scan/presentation/bloc/topology/topology_bloc.dart';
import 'package:motus_lab/features/scan/presentation/widgets/topology/topology_painter.dart';

class TopologyPage extends StatelessWidget {
  const TopologyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<TopologyBloc>(),
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
    // Node radius is likely ~45px
    const double hitRadius = 45.0;

    for (var node in nodes) {
      final dx = localPosition.dx - node.position.dx;
      final dy = localPosition.dy - node.position.dy;
      if ((dx * dx + dy * dy) <= (hitRadius * hitRadius)) {
        // Hit!
        _showEcuActionSheet(context, node);
        break;
      }
    }
  }

  void _showEcuActionSheet(BuildContext context, dynamic node) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text("ID: ${node.id} | Status: ${node.status.name.toUpperCase()}"),
                  trailing: node.dtcCount > 0 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                        child: Text("${node.dtcCount} DTCs", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    : null,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.document_scanner, color: Colors.orange),
                  title: const Text("Read Fault Codes"),
                  subtitle: const Text("View and clear Diagnostic Trouble Codes"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Navigating to DTCs for ${node.name}...")));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart, color: Colors.blue),
                  title: const Text("Live Data Stream"),
                  subtitle: const Text("View real-time sensor values"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Loading Live Data for ${node.name}...")));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_suggest, color: Colors.green),
                  title: const Text("Active Tests & Coding"),
                  subtitle: const Text("Perform bi-directional control and adaptations"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Opening Actuation menu for ${node.name}...")));
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
