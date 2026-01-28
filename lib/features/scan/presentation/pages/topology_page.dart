import 'package:flutter/material.dart';
import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';
import 'package:motus_lab/features/scan/presentation/widgets/topology/topology_painter.dart';

class TopologyPage extends StatefulWidget {
  const TopologyPage({super.key});

  @override
  State<TopologyPage> createState() => _TopologyPageState();
}

class _TopologyPageState extends State<TopologyPage> {
  final List<EcuNode> _nodes = [
    const EcuNode(
        id: "ECM",
        name: "Engine Control",
        status: EcuStatus.ok,
        position: Offset(100, 100)),
    const EcuNode(
        id: "TCM",
        name: "Transmission",
        status: EcuStatus.ok,
        position: Offset(200, 100)),
    const EcuNode(
        id: "ABS",
        name: "Brake System",
        status: EcuStatus.fault,
        position: Offset(300, 100)),
    const EcuNode(
        id: "SRS",
        name: "Airbag",
        status: EcuStatus.ok,
        position: Offset(400, 100)),
    const EcuNode(
        id: "BCM",
        name: "Body Control",
        status: EcuStatus.disconnected,
        position: Offset(500, 100)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VEHICLE TOPOLOGY"),
      ),
      body: Center(
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
            painter: TopologyPainter(_nodes),
          ),
        ),
      ),
    );
  }
}
