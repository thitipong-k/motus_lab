import 'package:flutter/material.dart';
import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/features/scan/domain/services/diagnostic_expert_service.dart';

class EcuDetailDialog extends StatelessWidget {
  final EcuNode node;

  const EcuDetailDialog({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (node.status) {
      case EcuStatus.ok:
        statusColor = Colors.green;
        statusText = "Online (OK)";
        break;
      case EcuStatus.fault:
        statusColor = Colors.red;
        statusText = "DTC Found";
        break;
      case EcuStatus.disconnected:
        statusColor = Colors.grey;
        statusText = "Offline / Timeout";
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.memory, color: AppColors.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "${node.name} (${node.id})",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow("Status", statusText, color: statusColor),
            const SizedBox(height: 8),
            _buildDetailRow("Protocol", "ISO 15765-4 (CAN 11/500)"),
            const SizedBox(height: 8),
            _buildDetailRow(
                "Response Time", "${15 + (node.id.hashCode % 20)} ms"),
            const SizedBox(height: 8),
            _buildDetailRow("Address",
                "0x${node.id.hashCode.toRadixString(16).substring(0, 3).toUpperCase()}"),

            // ส่วนของคำแนะนำการซ่อม (Repair Guidelines)
            // จะแสดงผลเฉพาะเมื่อสถานะเป็น FAULT เท่านั้น
            if (node.status == EcuStatus.fault) ...[
              const Divider(height: 32),
              const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text("คำแนะนำการซ่อม (Technical Fixes)",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.amber)),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<String>>(
                future: locator<DiagnosticExpertService>()
                    .getGuidelines(node.id == "7E2" ? "7E2" : "P0300"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final steps = snapshot.data ?? ["No guidelines found"];

                  return Column(
                    children: steps
                        .map((step) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ",
                                      style:
                                          TextStyle(color: AppColors.primary)),
                                  Expanded(
                                      child: Text(step,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white70))),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child:
                    const Text("Close", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
