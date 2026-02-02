import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';
import 'package:motus_lab/features/scan/presentation/bloc/topology/topology_bloc.dart';
import 'package:motus_lab/features/scan/presentation/widgets/topology/topology_painter.dart';
import 'package:motus_lab/features/scan/presentation/widgets/topology/ecu_detail_dialog.dart';
import 'package:motus_lab/features/scan/domain/services/diagnostic_expert_service.dart';

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
  EcuNode? _selectedNode;

  @override
  void initState() {
    super.initState();
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
              setState(() => _selectedNode = null);
              context.read<TopologyBloc>().add(StartTopologyScan());
            },
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 900;

          return BlocBuilder<TopologyBloc, TopologyState>(
            builder: (context, state) {
              if (isTablet) {
                return Row(
                  children: [
                    // Left: Topology Map
                    Expanded(
                      flex: 2,
                      child: _buildCanvas(state),
                    ),
                    // Right: Sidebar Details
                    Container(
                      width: 350,
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        border: Border(left: BorderSide(color: Colors.white10)),
                      ),
                      child: _buildDetailsPanel(state),
                    ),
                  ],
                );
              }

              // Mobile: Simple Column
              return Column(
                children: [
                  if (state.isScanning)
                    const LinearProgressIndicator(minHeight: 2),
                  Expanded(child: _buildCanvas(state)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCanvas(TopologyState state) {
    return GestureDetector(
      onTapUp: (details) {
        _handleTap(details.localPosition, state.nodes);
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            size: Size.infinite,
            painter: TopologyPainter(state.nodes),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsPanel(TopologyState state) {
    if (_selectedNode == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree,
                size: 64, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text("Select a module to view details",
                style: TextStyle(color: Colors.white.withOpacity(0.34))),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedNode!.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "ID: ${_selectedNode!.id}",
            style:
                const TextStyle(color: Colors.white54, fontFamily: 'Courier'),
          ),
          const Divider(height: 48, color: Colors.white10),
          _buildDetailRow("Status", _selectedNode!.status.name.toUpperCase(),
              color: _getStatusColor(_selectedNode!.status)),
          _buildDetailRow("Protocol", "ISO 15765-4 (CAN)"),
          _buildDetailRow("Bus Speed", "500 kbit/s"),
          const SizedBox(height: 32),
          if (_selectedNode!.status == EcuStatus.fault)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      const Text("Fault Detected!",
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text("P0300: Random/Multiple Cylinder Misfire Detected",
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 16),

                  // ปุ่ม "แนวทางการแก้ไข" (Check Solution)
                  // ขั้นตอน: 1. เรียกใช้ DiagnosticExpertService 2. แสดงขั้นตอนการซ่อมบรรทัดต่อบรรทัด
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.build_circle, size: 18),
                      label: const Text("แนวทางการแก้ไข",
                          style: TextStyle(fontSize: 12)),
                      onPressed: () =>
                          _showRepairSolution(context, _selectedNode!),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// แสดงหน้าต่างแนวทางการแก้ไขปัญหา (Repair Solution Modal)
  void _showRepairSolution(BuildContext context, EcuNode node) {
    final expert = locator<DiagnosticExpertService>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 12),
                Text("แนวทางการซ่อมสำหรับ ${node.name}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 32, color: Colors.white10),

            // ใช้ FutureBuilder เพื่อรอโหลดข้อมูลจาก Expert System (Async)
            FutureBuilder<List<String>>(
              future: expert.getGuidelines(node.id == "7E2" ? "7E2" : "P0300"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final steps = snapshot.data ??
                    ['ไม่พบข้อมูลขั้นตอนการซ่อม', 'กรุณาตรวจสอบระบบอีกครั้ง'];

                return Column(
                  children: steps
                      .map((step) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("• ",
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 18)),
                                Expanded(
                                    child: Text(step,
                                        style: const TextStyle(
                                            color: Colors.white70))),
                              ],
                            ),
                          ))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("รับทราบ"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.34), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }

  Color _getStatusColor(EcuStatus status) {
    switch (status) {
      case EcuStatus.ok:
        return AppColors.success;
      case EcuStatus.fault:
        return AppColors.error;
      case EcuStatus.disconnected:
        return Colors.white24;
    }
  }

  void _handleTap(Offset localPosition, List<EcuNode> nodes) {
    const double hitWidth = 90.0;
    const double hitHeight = 45.0;

    for (var node in nodes) {
      final rect = Rect.fromCenter(
          center: node.position, width: hitWidth, height: hitHeight);
      if (rect.contains(localPosition)) {
        setState(() {
          _selectedNode = node;
        });

        // On mobile, also show a dialog since there's no sidebar
        final bool isMobile = MediaQuery.of(context).size.width <= 900;
        if (isMobile) {
          showDialog(
            context: context,
            builder: (context) => EcuDetailDialog(node: node),
          );
        }
        break;
      }
    }
  }
}
