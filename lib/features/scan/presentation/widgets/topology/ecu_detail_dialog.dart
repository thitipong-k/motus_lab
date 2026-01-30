import 'package:flutter/material.dart';
import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

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
