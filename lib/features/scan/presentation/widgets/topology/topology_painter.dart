import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';

class TopologyPainter extends CustomPainter {
  final List<EcuNode> nodes;

  TopologyPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint hsCanPaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint msCanPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Center Gateway
    const Offset cgwPos = Offset(300, 240);

    // 1. Draw "Backbone" Buses
    // High Speed CAN (y=100)
    canvas.drawLine(const Offset(50, 100), Offset(size.width - 50, 100), hsCanPaint);
    // CGW Connection to HS-CAN
    canvas.drawLine(cgwPos, const Offset(300, 100), hsCanPaint);

    // MS-CAN (y=380)
    canvas.drawLine(const Offset(50, 380), Offset(size.width - 50, 380), msCanPaint);
    // CGW Connection to MS-CAN
    canvas.drawLine(cgwPos, const Offset(300, 380), msCanPaint);

    // 2. Draw Nodes and their connections to buses
    for (var node in nodes) {
      if (node.busType == BusType.gateway) {
        _drawNode(canvas, node);
        continue;
      }

      final bool isHsCan = node.busType == BusType.hsCan;
      final targetY = isHsCan ? 100.0 : 380.0;
      final Paint connectorPaint = isHsCan ? hsCanPaint : msCanPaint;

      // Draw connection line
      canvas.drawLine(
        node.position,
        Offset(node.position.dx, targetY),
        connectorPaint,
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
      ..color = node.busType == BusType.gateway ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = node.busType == BusType.gateway ? 3.0 : 2.0;

    final rect = Rect.fromCenter(center: node.position, width: 90, height: 45);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    canvas.drawRRect(rrect, glowPaint);
    canvas.drawRRect(rrect, nodePaint);
    canvas.drawRRect(rrect, borderPaint);

    // Draw ID Text
    final idPainter = TextPainter(
      text: TextSpan(
        text: node.id,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
      textDirection: TextDirection.ltr,
    );
    idPainter.layout();
    idPainter.paint(canvas, node.position - Offset(idPainter.width / 2, 10));

    // Draw Name Text (Small)
    final nameStr = node.busType == BusType.gateway ? "CGW" : node.name.split(' ').first; // Shorten for view
    final namePainter = TextPainter(
      text: TextSpan(
        text: nameStr,
        style: const TextStyle(fontSize: 8, color: Colors.white54),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(canvas, node.position + Offset(-namePainter.width / 2, 8));

    // DTC Badge
    if (node.dtcCount > 0) {
      _drawDtcBadge(canvas, node);
    }
  }

  void _drawDtcBadge(Canvas canvas, EcuNode node) {
    final badgeCenter = node.position + const Offset(45, -22); // Top right corner
    
    final Paint badgePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(badgeCenter, 10, badgePaint);

    final TextPainter dtcText = TextPainter(
      text: TextSpan(
        text: node.dtcCount.toString(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    );
    dtcText.layout();
    dtcText.paint(canvas, badgeCenter - Offset(dtcText.width / 2, dtcText.height / 2));
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
