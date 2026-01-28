import 'dart:math';
import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

class SimpleGauge extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;

  const SimpleGauge({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.clamp(min, max);
    final percentage = (displayValue - min) / (max - min);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: GaugePainter(percentage),
              ),
            ),
            Column(
              children: [
                Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 32,
                        color: AppColors.primary,
                      ),
                ),
                Text(unit, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class GaugePainter extends CustomPainter {
  final double percentage;

  GaugePainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const thickness = 10.0;

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Background arc (240 degrees)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - thickness / 2),
      pi * 0.75, // Start at bottom-left
      pi * 1.5, // Sweep 270 degrees
      false,
      backgroundPaint,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - thickness / 2),
      pi * 0.75,
      pi * 1.5 * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
