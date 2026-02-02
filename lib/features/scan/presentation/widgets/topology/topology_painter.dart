import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';

class TopologyPainter extends CustomPainter {
  final List<EcuNode> nodes;

  TopologyPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Paint highSpeedPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint lowSpeedPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 1. Draw "Backbone" Buses
    // High Speed CAN (Powertrain)
    canvas.drawLine(
        const Offset(50, 100), Offset(size.width - 50, 100), highSpeedPaint);
    // Low Speed CAN (Body/Chassis)
    canvas.drawLine(
        const Offset(50, 240), Offset(size.width - 50, 240), lowSpeedPaint);

    // Gateway Connection
    canvas.drawLine(const Offset(300, 100), const Offset(300, 240), linePaint);

    // 2. Draw Nodes and their connections to buses
    for (var node in nodes) {
      final bool isPowertrain = node.id == "7E0" || node.id == "7E1";
      final targetY = isPowertrain ? 100.0 : 240.0;

      // Draw connection line
      canvas.drawLine(
        node.position,
        Offset(node.position.dx, targetY),
        linePaint
          ..color = isPowertrain
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.secondary.withOpacity(0.3),
      );

      _drawNode(canvas, node);
    }
  }

  void _drawNode(Canvas canvas, EcuNode node) {
    final Color color = _getStatusColor(node.status);

    // Glow effect
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final Paint nodePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromCenter(center: node.position, width: 90, height: 45);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    canvas.drawRRect(rrect, glowPaint);
    canvas.drawRRect(rrect, nodePaint);
    canvas.drawRRect(rrect, borderPaint);

    // Draw ID Text
    final idPainter = TextPainter(
      text: TextSpan(
        text: node.id,
        style:
            TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
      textDirection: TextDirection.ltr,
    );
    idPainter.layout();
    idPainter.paint(canvas, node.position - Offset(idPainter.width / 2, 10));

    // Draw Name Text (Small)
    final nameStr = node.name.split(' ').first; // Shorten for view
    final namePainter = TextPainter(
      text: TextSpan(
        text: nameStr,
        style: const TextStyle(fontSize: 8, color: Colors.white54),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(
        canvas, node.position + Offset(-namePainter.width / 2, 8));
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

  @override
  bool shouldRepaint(covariant TopologyPainter oldDelegate) {
    return oldDelegate.nodes != nodes;
  }
}
