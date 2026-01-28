import 'dart:math';
import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

class RadarView extends StatefulWidget {
  const RadarView({super.key});

  @override
  State<RadarView> createState() => _RadarViewState();
}

class _RadarViewState extends State<RadarView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RadarPainter(_controller.value),
        );
      },
    );
  }
}

class RadarPainter extends CustomPainter {
  final double angle; // 0.0 to 1.0

  RadarPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final Paint circlePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw concentric circles
    canvas.drawCircle(center, radius * 0.3, circlePaint);
    canvas.drawCircle(center, radius * 0.6, circlePaint);
    canvas.drawCircle(center, radius * 0.9, circlePaint);

    // Draw sweeping gradient
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Gradient gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: pi / 2,
      colors: [
        AppColors.primary.withOpacity(0.0),
        AppColors.primary.withOpacity(0.5),
      ],
      stops: const [0.0, 1.0],
      transform: GradientRotation(angle * 2 * pi),
    );

    final Paint sweepPaint = Paint()..shader = gradient.createShader(rect);

    canvas.drawArc(rect, angle * 2 * pi, pi / 2, true, sweepPaint);

    // Draw center dot
    canvas.drawCircle(center, 5, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
