import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/domain/entities/command.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';
import 'package:motus_lab/core/protocol/standard_pids.dart';
import 'package:motus_lab/features/scan/presentation/widgets/gauges/simple_gauge.dart';
import 'package:motus_lab/features/scan/presentation/pages/live_data/pid_selection_page.dart';
import 'package:motus_lab/core/utils/unit_converter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:motus_lab/features/scan/presentation/widgets/graphs/live_data_graph.dart';

class LiveDataPage extends StatefulWidget {
  const LiveDataPage({super.key});

  @override
  State<LiveDataPage> createState() => _LiveDataPageState();
}

class _LiveDataPageState extends State<LiveDataPage> {
  // รายการคำสั่งที่จะดึงข้อมูลมาแสดง (เริ่มต้นด้วย RPM, Speed)
  List<Command> _activeCommands = [
    StandardPids.engineRpm,
    StandardPids.vehicleSpeed,
    StandardPids.engineCoolantTemp,
  ];

  bool _useImperial = false;
  bool _isGraphMode = false;

  // เก็บประวัติข้อมูลสำหรับกราฟ (Key = Command Name)
  final Map<String, List<FlSpot>> _dataHistory = {};
  double _timeCounter = 0; // แกน X (เวลา)

  @override
  void initState() {
    super.initState();
    // เริ่มดึงข้อมูลเมื่อเปิดหน้านี้
    context.read<LiveDataBloc>().add(StartStreaming(_activeCommands));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openPidSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PidSelectionPage(currentSelection: _activeCommands),
      ),
    );

    if (result != null && result is List<Command>) {
      setState(() {
        _activeCommands = result;
        _dataHistory.clear(); // ล้างกราฟเมื่อเปลี่ยน PIDs
        _timeCounter = 0;
      });
      context.read<LiveDataBloc>().add(UpdateActiveCommands(_activeCommands));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LIVE DATA"),
        actions: [
          // Unit Toggle
          TextButton(
            onPressed: () {
              setState(() {
                _useImperial = !_useImperial;
              });
            },
            child: Text(_useImperial ? "IMP" : "MET",
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          // View Toggle
          IconButton(
            icon: Icon(_isGraphMode ? Icons.list : Icons.show_chart),
            onPressed: () {
              setState(() {
                _isGraphMode = !_isGraphMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openPidSelection,
          ),
        ],
      ),
      body: BlocConsumer<LiveDataBloc, LiveDataState>(
        listener: (context, state) {
          if (state.currentValues.isNotEmpty) {
            _updateHistory(state.currentValues);
          }
        },
        builder: (context, state) {
          if (!state.isStreaming) {
            return const Center(child: Text("Connecting to data stream..."));
          }

          if (_isGraphMode) {
            return _buildGraphView();
          } else {
            return _buildListView(state);
          }
        },
      ),
    );
  }

  void _updateHistory(Map<String, double> values) {
    _timeCounter += 0.2; // เพิ่มเวลาตาม Timer (200ms)

    for (var cmd in _activeCommands) {
      if (!_dataHistory.containsKey(cmd.name)) {
        _dataHistory[cmd.name] = [];
      }

      double val = values[cmd.name] ?? 0.0;

      // Convert unit before saving points if needed?
      // No, keep raw value and convert on render to support toggling.

      final points = _dataHistory[cmd.name]!;
      points.add(FlSpot(_timeCounter, val));

      // Keep last 50 points
      if (points.length > 50) {
        points.removeAt(0);
      }
    }
  }

  Widget _buildGraphView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeCommands.length,
      itemBuilder: (context, index) {
        final cmd = _activeCommands[index];
        final rawPoints = _dataHistory[cmd.name] ?? [];

        // Convert points for display
        final displayPoints = rawPoints.map((p) {
          double val = p.y;
          if (_useImperial) {
            if (cmd.unit == "km/h")
              val = UnitConverter.kmhToMph(val);
            else if (cmd.unit == "°C")
              val = UnitConverter.celsiusToFahrenheit(val);
            else if (cmd.unit == "kPa")
              val = UnitConverter.kpaToPsi(val);
            else if (cmd.unit == "g/s")
              val = UnitConverter.gramsPerSecToLbsPerMin(val);
          }
          return FlSpot(p.x, val);
        }).toList();

        if (displayPoints.isEmpty) return const SizedBox();

        // Calculate Min/Max for Axis
        double minY =
            displayPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
        double maxY =
            displayPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);

        // Add padding
        minY = (minY - 5).floorToDouble();
        maxY = (maxY + 5).ceilToDouble();
        if (minY < 0) minY = 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LiveDataGraph(
              label:
                  "${cmd.name} (${_useImperial && cmd.unit == '°C' ? '°F' : (_useImperial && cmd.unit == 'km/h' ? 'mph' : cmd.unit)})",
              points: displayPoints,
              minX: displayPoints.first.x,
              maxX: displayPoints.last.x,
              minY: minY,
              maxY: maxY,
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(LiveDataState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeCommands.length,
      itemBuilder: (context, index) {
        final cmd = _activeCommands[index];
        final rawValue = state.currentValues[cmd.name] ?? 0.0;

        // Special display for RPM and Speed (Gauge)
        if (cmd.code == "010C" || cmd.code == "010D") {
          // Convert for Gauge if needed
          double gaugeValue = rawValue;
          String gaugeUnit = cmd.unit;
          double maxGauge = cmd.code == "010C" ? 8000 : 220;

          if (_useImperial && cmd.code == "010D") {
            // Speed
            gaugeValue = UnitConverter.kmhToMph(rawValue);
            gaugeUnit = "mph";
            maxGauge = 140; // ~220 kmh
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: SimpleGauge(
                label: cmd.name.toUpperCase(),
                value: gaugeValue,
                min: 0,
                max: maxGauge,
                unit: gaugeUnit.toUpperCase(),
              ),
            ),
          );
        }

        // Normal display in Card
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cmd.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(cmd.description,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Text(
                  UnitConverter.formatValue(rawValue, cmd.unit, _useImperial),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
