import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

class LiveDataGraph extends StatelessWidget {
  final String label;
  final List<FlSpot> points;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  const LiveDataGraph({
    super.key,
    required this.label,
    required this.points,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: true),
              titlesData: const FlTitlesData(
                show: true,
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 22),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white10),
              ),
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: points,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
