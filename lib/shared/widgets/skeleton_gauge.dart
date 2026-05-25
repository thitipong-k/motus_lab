import 'package:flutter/material.dart';
import 'shimmer_skeleton.dart';
import 'package:motus_lab/shared/widgets/motus_card.dart';

/// =================================================================
/// Skeleton Gauge - Placeholder ระหว่างรอโหลดข้อมูล Gauge
/// =================================================================
///
/// แสดง Shimmer effect ที่มีรูปร่างคล้าย Gauge จริง
/// เพื่อลด Perceived Latency (ความรู้สึกว่ารอนาน)
/// =================================================================
class SkeletonGauge extends StatelessWidget {
  const SkeletonGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return MotusCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0), // ลดจาก 16 เพื่อป้องกัน Overflow
        child: FittedBox(
          // FittedBox จะ Scale ลงอัตโนมัติถ้าพื้นที่ไม่พอ
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // ใช้พื้นที่น้อยที่สุด
            children: const [
              // วงกลม Gauge Placeholder
              ShimmerSkeleton(
                width: 80, // ลดจาก 100
                height: 80,
                borderRadius: 40,
              ),
              SizedBox(height: 8), // ลดจาก 16
              // ชื่อ PID Placeholder
              ShimmerSkeleton(
                width: 60, // ลดจาก 80
                height: 10,
              ),
              SizedBox(height: 4), // ลดจาก 8
              // ค่า Placeholder
              ShimmerSkeleton(
                width: 35,
                height: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
