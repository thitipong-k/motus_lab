import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';
import 'package:motus_lab/features/scan/presentation/widgets/graphs/live_data_graph.dart';
import 'package:motus_lab/features/scan/presentation/pages/live_data/pid_selection_page.dart';
import 'package:motus_lab/core/protocol/standard_pids.dart';
import 'package:motus_lab/domain/entities/command.dart';

class GraphAnalysisPage extends StatefulWidget {
  const GraphAnalysisPage({super.key});

  @override
  State<GraphAnalysisPage> createState() => _GraphAnalysisPageState();
}

class _GraphAnalysisPageState extends State<GraphAnalysisPage> {
  // Map สำหรับเก็บข้อมูลกราฟแยกตามชื่อ Command
  final Map<String, List<FlSpot>> _graphData = {};

  // รายการ Command ที่เลือกแสดงผล
  List<Command> _selectedCommands = [
    StandardPids.engineRpm,
    StandardPids.vehicleSpeed
  ];

  double _timeCounter = 0;

  @override
  void initState() {
    super.initState();
    // เริ่มต้นส่งคำสั่ง Default ไปก่อน
    context.read<LiveDataBloc>().add(StartStreaming(_selectedCommands));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GRAPH ANALYSIS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openPidSelection,
            tooltip: "Select Data",
          )
        ],
      ),
      body: BlocListener<LiveDataBloc, LiveDataState>(
        listener: (context, state) {
          if (state.isStreaming) {
            setState(() {
              _timeCounter += 0.2; // อิงตาม Timer 200ms

              // วนลูปเก็บข้อมูลสำหรับทุก Command ที่เลือกไว้
              for (var cmd in _selectedCommands) {
                final value = state.currentValues[cmd.name] ?? 0.0;

                if (!_graphData.containsKey(cmd.name)) {
                  _graphData[cmd.name] = [];
                }

                _graphData[cmd.name]!.add(FlSpot(_timeCounter, value));

                // จำกัดจำนวนจุดไว้แค่ 50 จุด (เลื่อนกราฟ)
                if (_graphData[cmd.name]!.length > 50) {
                  _graphData[cmd.name]!.removeAt(0);
                }
              }
            });
          }
        },
        child: _selectedCommands.isEmpty
            ? const Center(child: Text("Select data using top-right button"))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _selectedCommands.length,
                separatorBuilder: (c, i) => const SizedBox(height: 32),
                itemBuilder: (context, index) {
                  final cmd = _selectedCommands[index];
                  final points = _graphData[cmd.name] ?? [];

                  // หา min/max X เพื่อให้กราฟเลื่อนสวยงาม
                  double minX = points.isNotEmpty ? points.first.x : 0;
                  double maxX = points.isNotEmpty ? points.last.x : 10;
                  if (maxX - minX < 10) maxX = minX + 10;

                  // หา MaxY แบบ Dynamic หรือ Hardcode ตาม Unit ก็ได้
                  // เพื่อความง่ายรอบนี้ขอใช้ Unit ในการกะคร่าวๆ
                  double maxY = 100;
                  if (cmd.unit == "rpm")
                    maxY = 8000;
                  else if (cmd.unit == "km/h")
                    maxY = 240;
                  else if (cmd.unit == "°C")
                    maxY = 150;
                  else if (cmd.unit == "kPa") maxY = 255;

                  return LiveDataGraph(
                    title: cmd.name.toUpperCase(),
                    seriesList: [
                      GraphSeries(
                        label: cmd.name.toUpperCase(),
                        points: List.from(points),
                        color: AppColors.primary,
                      ),
                    ],
                    minX: minX,
                    maxX: maxX,
                    minY: 0,
                    maxY: maxY,
                  );
                },
              ),
      ),
    );
  }

  void _openPidSelection() async {
    // Navigate ไปหน้าเลือก PID (ต้อง import, แต่หน้านั้นอยู่ใน folder live_data เราอยู่ root pages)
    // path: features/scan/presentation/pages/live_data/pid_selection_page.dart
    // เนื่องจากไม่ได้แก้ import ด้านบน ผมจะใช้ dynamic import หรือแก้ด้านบนทีหลัง
    // แต่ tool replace_file_content ทำงานเป็น chunk
    // ดังนั้นต้องแน่ใจว่า import PidSelectionPage แล้ว
    // ซึ่งไฟล์เดิมยังไม่มี import นี้

    // **NOTE**: ผมจะขอแก้ import ใน Step ถัดไป หรือใช้ Replace Chunk ที่ใหญ่กว่านี้ครอบคลุม import
    // ครั้งนี้ขอเขียน logic ไปก่อน แล้วเดี๋ยวแก้ import ตาม

    // ignore: use_build_context_synchronously
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PidSelectionPage(currentSelection: _selectedCommands),
      ),
    );

    if (result != null && result is List<Command>) {
      setState(() {
        _selectedCommands = result;
        _graphData.clear(); // Reset กราฟเมื่อเปลี่ยนข้อมูล
        _timeCounter = 0;
      });
      // แจ้ง Bloc ให้เปลี่ยนชุดคำสั่ง
      context.read<LiveDataBloc>().add(UpdateActiveCommands(result));
      // ถ้า Bloc หยุดอยู่ (เช่น สลับหน้า) ให้เริ่มใหม่ด้วย
      context.read<LiveDataBloc>().add(StartStreaming(result));
    }
  }
}
