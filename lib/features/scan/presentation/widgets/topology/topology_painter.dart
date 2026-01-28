import 'dart:math';
import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';

class TopologyPainter extends CustomPainter {
  final List<EcuNode> nodes;

  TopologyPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final Paint linePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw main Bus line (Conceptual)
    canvas.drawLine(
      Offset(size.width * 0.1, center.dy),
      Offset(size.width * 0.9, center.dy),
      linePaint,
    );

    for (var node in nodes) {
      _drawNode(canvas, node);
      // Draw vertical connection to bus
      canvas.drawLine(
        node.position,
        Offset(node.position.dx, center.dy),
        linePaint,
      );
    }
  }

  void _drawNode(Canvas canvas, EcuNode node) {
    final Color color = _getStatusColor(node.status);

    final Paint nodePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw Node Box
    final rect = Rect.fromCenter(center: node.position, width: 80, height: 40);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)), nodePaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);

    // Draw Text Placeholder (ID)
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.id,
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        node.position - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  Color _getStatusColor(EcuStatus status) {
    switch (status) {
      case EcuStatus.ok:
        return AppColors.success;
      case EcuStatus.fault:
        return AppColors.error;
      case EcuStatus.disconnected:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant TopologyPainter oldDelegate) {
    return oldDelegate.nodes != nodes;
  }
}
