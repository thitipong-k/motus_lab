import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

class GraphSeries {
  final String label;
  final List<FlSpot> points;
  final Color color;

  const GraphSeries({
    required this.label,
    required this.points,
    required this.color,
  });
}

class LiveDataGraph extends StatelessWidget {
  final String title;
  final List<GraphSeries> seriesList;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  const LiveDataGraph({
    super.key,
    required this.title,
    required this.seriesList,
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
          padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (seriesList.length > 1) ...[
                const SizedBox(height: 4),
                _buildLegend(),
              ],
            ],
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
              lineBarsData: seriesList
                  .map((series) => LineChartBarData(
                        spots: series.points,
                        isCurved: true,
                        color: series.color,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: series.color.withOpacity(0.1),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    // [Overflow Protection] ใช้ Wrap แทน Row
    // กรณีมีหลายกราฟ หรือชื่อยาวๆ จะได้ปัดลงบรรทัดใหม่ได้
    // ช่วยป้องกัน Error "RenderFlex overflowed" ในหน้าจอมือถือ
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: seriesList.map((s) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              color: s.color,
            ),
            const SizedBox(width: 4),
            Text(s.label, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
