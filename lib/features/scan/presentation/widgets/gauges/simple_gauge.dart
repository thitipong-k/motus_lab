import 'dart:math' as math;
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
    final double normalizedValue = value.clamp(min, max);
    final double percentage = (normalizedValue - min) / (max - min);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size based on smallest dimension
        // Ensure we don't get 0 or infinity
        double size = math.min(constraints.maxWidth, constraints.maxHeight);
        if (size == double.infinity) size = constraints.maxWidth;
        if (size == double.infinity) size = 200; // Fallback

        // Adjust gauge size to leave room for label
        final double gaugeSize = size * 0.75;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: gaugeSize,
              height: gaugeSize,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: percentage),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, animatedPercentage, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Circle with Shadow for depth
                      Container(
                        width: gaugeSize * 0.9,
                        height: gaugeSize * 0.9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: gaugeSize * 0.05,
                              offset: Offset(0, gaugeSize * 0.02),
                            ),
                          ],
                        ),
                      ),
                      // Gauge Painter
                      CustomPaint(
                        size: Size(gaugeSize, gaugeSize),
                        painter: GaugePainter(
                          percentage: animatedPercentage,
                        ),
                      ),
                      // Value Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            value.toStringAsFixed(0),
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      gaugeSize * 0.22, // Responsive Font Size
                                  color: AppColors.primary,
                                ),
                          ),
                          Text(
                            unit,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize:
                                      gaugeSize * 0.1, // Responsive Font Size
                                ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: size * 0.05),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.09, // Responsive Font Size
                  ),
            ),
          ],
        );
      },
    );
  }
}

class GaugePainter extends CustomPainter {
  final double percentage;

  GaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Radius adjusted for stroke thickness
    final radius = math.min(size.width, size.height) / 2 - (size.width * 0.05);
    final thickness = size.width * 0.08; // Responsive thickness

    const startAngle = math.pi * 0.75; // 135 degrees
    const sweepAngle = math.pi * 1.5; // 270 degrees

    // Background Arc
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Dynamic Gradient based on value
    const List<Color> gradientColors = [
      Colors.blueAccent,
      Colors.cyanAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.redAccent,
    ];

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: gradientColors,
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      transform: GradientRotation(startAngle - (math.pi * 0.1)),
    );

    final progressPaint = Paint()
      ..shader =
          gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Glow Effect (Outer Blur)
    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness + (size.width * 0.04)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    if (percentage > 0) {
      // Draw Glow
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * percentage,
        false,
        glowPaint,
      );

      // Draw Main Gradient Progress
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * percentage,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
