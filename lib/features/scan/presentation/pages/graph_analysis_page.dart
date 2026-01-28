import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';
import 'package:motus_lab/features/scan/presentation/widgets/graphs/live_data_graph.dart';

class GraphAnalysisPage extends StatefulWidget {
  const GraphAnalysisPage({super.key});

  @override
  State<GraphAnalysisPage> createState() => _GraphAnalysisPageState();
}

class _GraphAnalysisPageState extends State<GraphAnalysisPage> {
  // จำลองชุดข้อมูลสำหรับกราฟ (ในโปรเจกต์จริงจะเก็บใน Bloc หรือ Repository)
  final List<FlSpot> _rpmSpots = [];
  final List<FlSpot> _speedSpots = [];
  double _timeCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GRAPH ANALYSIS"),
      ),
      body: BlocListener<LiveDataBloc, LiveDataState>(
        listener: (context, state) {
          if (state.isStreaming) {
            setState(() {
              _timeCounter += 0.2; // อิงตาม Timer 200ms
              final rpm = state.currentValues["Engine RPM"] ?? 0.0;
              final speed = state.currentValues["Vehicle Speed"] ?? 0.0;

              _rpmSpots.add(FlSpot(_timeCounter, rpm));
              _speedSpots.add(FlSpot(_timeCounter, speed));

              // จำกัดจำนวนจุดไว้แค่ 50 จุด (เลื่อนกราฟ)
              if (_rpmSpots.length > 50) _rpmSpots.removeAt(0);
              if (_speedSpots.length > 50) _speedSpots.removeAt(0);
            });
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LiveDataGraph(
              label: "ENGINE RPM",
              points: List.from(_rpmSpots),
              minX: _rpmSpots.isNotEmpty ? _rpmSpots.first.x : 0,
              maxX: _rpmSpots.isNotEmpty ? _rpmSpots.last.x : 10,
              minY: 0,
              maxY: 8000,
            ),
            const SizedBox(height: 32),
            LiveDataGraph(
              label: "VEHICLE SPEED",
              points: List.from(_speedSpots),
              minX: _speedSpots.isNotEmpty ? _speedSpots.first.x : 0,
              maxX: _speedSpots.isNotEmpty ? _speedSpots.last.x : 10,
              minY: 0,
              maxY: 220,
            ),
          ],
        ),
      ),
    );
  }
}
