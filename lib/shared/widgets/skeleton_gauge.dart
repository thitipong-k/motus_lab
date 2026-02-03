import 'package:flutter/material.dart';
import 'shimmer_skeleton.dart';
import 'package:motus_lab/shared/widgets/motus_card.dart';

class SkeletonGauge extends StatelessWidget {
  const SkeletonGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return MotusCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gauge Circle Placeholder
            const ShimmerSkeleton(
              width: 100,
              height: 100,
              borderRadius: 50,
            ),
            const SizedBox(height: 16),
            // Title Placeholder
            const ShimmerSkeleton(
              width: 80,
              height: 12,
            ),
            const SizedBox(height: 8),
            // Value Placeholder
            const ShimmerSkeleton(
              width: 40,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
