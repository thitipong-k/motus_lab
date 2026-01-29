import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/domain/entities/command.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';

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
  bool _useImperial = false;
  bool _isGraphMode = false;

  // เก็บประวัติข้อมูลสำหรับกราฟ (Key = Command Name)
  final Map<String, List<FlSpot>> _dataHistory = {};
  double _timeCounter = 0; // แกน X (เวลา)

  @override
  void initState() {
    super.initState();
    // Start with EMPTY list to trigger discovery
    context.read<LiveDataBloc>().add(StartStreaming([]));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openPidSelection() async {
    // Use state's active commands for current selection
    final currentBlocState = context.read<LiveDataBloc>().state;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PidSelectionPage(currentSelection: currentBlocState.activeCommands),
      ),
    );

    if (result != null && result is List<Command>) {
      // Just send update event, no need to set local state (BLoC handles it)
      _dataHistory.clear();
      _timeCounter = 0;
      context.read<LiveDataBloc>().add(UpdateActiveCommands(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LIVE DATA"),
        // ... actions omitted for brevity, keeping same structure ...
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'honda') {
                context.read<LiveDataBloc>().add(
                    const LoadProtocol("assets/protocols/honda_civic.json"));
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'honda',
                  child: Text('Simulate Honda Civic'),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: BlocConsumer<LiveDataBloc, LiveDataState>(
        listener: (context, state) {
          if (state.currentValues.isNotEmpty) {
            _updateHistory(state.currentValues, state.activeCommands);
          }
        },
        builder: (context, state) {
          if (state.isDiscovering) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Scanning supported PIDs..."),
                ],
              ),
            );
          }

          if (!state.isStreaming && state.activeCommands.isEmpty) {
            return const Center(child: Text("Connecting / No PIDs selected"));
          }

          if (_isGraphMode) {
            return _buildGraphView(state.activeCommands);
          } else {
            return _buildListView(state, state.activeCommands);
          }
        },
      ),
    );
  }

  void _updateHistory(
      Map<String, double> values, List<Command> activeCommands) {
    _timeCounter += 0.2; // เพิ่มเวลาตาม Timer (200ms)

    for (var cmd in activeCommands) {
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

  Widget _buildGraphView(List<Command> activeCommands) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeCommands.length,
      itemBuilder: (context, index) {
        final cmd = activeCommands[index];
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

  Widget _buildListView(LiveDataState state, List<Command> activeCommands) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeCommands.length,
      itemBuilder: (context, index) {
        final cmd = activeCommands[index];
        final rawValue = state.currentValues[cmd.name] ?? 0.0;
        final displayValue =
            UnitConverter.formatValue(rawValue, cmd.unit, _useImperial);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cmd.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(cmd.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    displayValue,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
