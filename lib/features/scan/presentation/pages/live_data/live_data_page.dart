import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/domain/entities/command.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';
import 'package:motus_lab/features/scan/presentation/pages/live_data/pid_selection_page.dart';
import 'package:motus_lab/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:motus_lab/features/settings/domain/entities/settings.dart';
import 'package:motus_lab/core/utils/unit_converter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:motus_lab/features/scan/presentation/widgets/graphs/live_data_graph.dart';
import 'package:motus_lab/features/scan/presentation/widgets/gauges/simple_gauge.dart';
import 'package:motus_lab/core/widgets/motus_card.dart';
import 'package:motus_lab/core/widgets/loading_indicator.dart';
import 'package:motus_lab/core/widgets/empty_state.dart';
import 'package:motus_lab/features/reporting/presentation/bloc/report_bloc.dart';
import 'package:motus_lab/features/reporting/domain/entities/report_entities.dart';
import 'package:printing/printing.dart';

enum ViewMode { gauge, graph }

class LiveDataPage extends StatefulWidget {
  const LiveDataPage({super.key});

  @override
  State<LiveDataPage> createState() => _LiveDataPageState();
}

class _LiveDataPageState extends State<LiveDataPage> {
  // bool _useImperial = false; // Removed in favor of Global Settings
  ViewMode _viewMode = ViewMode.gauge;
  bool _isCombinedGraph = false;

  final List<Color> _seriesColors = [
    AppColors.primary,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent
  ];

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

  void _cycleViewMode() {
    setState(() {
      // สลับโหมดการแสดงผล (Gauge <-> Graph) แบบวนลูป
      int nextIndex = (_viewMode.index + 1) % ViewMode.values.length;
      _viewMode = ViewMode.values[nextIndex];
    });
  }

  IconData _getViewIcon() {
    switch (_viewMode) {
      case ViewMode.graph:
        return Icons.show_chart;
      case ViewMode.gauge:
        return Icons.speed;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch SettingsBloc for Unit System changes
    final settingsState = context.watch<SettingsBloc>().state;
    final useImperial =
        settingsState.settings.unitSystem == UnitSystem.imperial;

    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state.status == ReportStatus.exported) {
          if (state.generatedPdf != null) {
            Printing.layoutPdf(
              onLayout: (format) async => state.generatedPdf!.readAsBytesSync(),
              name: 'LiveReport_${DateTime.now().millisecondsSinceEpoch}.pdf',
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report exported successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          context.read<ReportBloc>().add(ResetReportStatus());
        } else if (state.status == ReportStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export Failed: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
          context.read<ReportBloc>().add(ResetReportStatus());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("LIVE DATA"),
          actions: [
            // Record Button
            BlocBuilder<LiveDataBloc, LiveDataState>(
              buildWhen: (previous, current) =>
                  previous.isLogging != current.isLogging ||
                  previous.activeCommands.length !=
                      current.activeCommands.length,
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    state.isLogging
                        ? Icons.stop_circle
                        : Icons.fiber_manual_record,
                    color: state.isLogging ? Colors.red : null,
                  ),
                  tooltip:
                      state.isLogging ? "Stop Recording" : "Start Recording",
                  onPressed: () {
                    if (state.isLogging) {
                      context.read<LiveDataBloc>().add(StopLogging());
                    } else {
                      if (state.activeCommands.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("No active PIDs to record!")));
                        return;
                      }
                      context.read<LiveDataBloc>().add(StartLogging());
                    }
                  },
                );
              },
            ),
            // Unit Toggle (Updates Global Settings)
            TextButton(
              onPressed: () {
                context.read<SettingsBloc>().add(UpdateUnitSystem(
                    useImperial ? UnitSystem.metric : UnitSystem.imperial));
              },
              child: Text(useImperial ? "IMP" : "MET",
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            // View Toggle
            IconButton(
              icon: Icon(_getViewIcon()),
              tooltip: "Switch View (Graph / Gauge)",
              onPressed: _cycleViewMode,
            ),
            if (_viewMode == ViewMode.graph)
              IconButton(
                icon: Icon(
                    _isCombinedGraph ? Icons.merge_type : Icons.call_split),
                tooltip: _isCombinedGraph ? "Split Graphs" : "Combine Graphs",
                onPressed: () {
                  setState(() {
                    _isCombinedGraph = !_isCombinedGraph;
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: "Export PDF Report",
              onPressed: () {
                final state = context.read<LiveDataBloc>().state;
                final reportData = DiagnosticReport(
                  id: "LR-${DateTime.now().millisecondsSinceEpoch}",
                  vehicleVin:
                      state.activeCommands.isNotEmpty ? "SCANNING" : "UNKNOWN",
                  vehicleName: "Current Live Streaming",
                  timestamp: DateTime.now(),
                  technicianName: "Motus Lab Tech",
                  dtcList: [], // Future: Link with DtcBloc findings
                );
                context.read<ReportBloc>().add(GenerateReportPdf(reportData));
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
              if (state.isDiscovering) {
                return const LoadingIndicator(
                    message: "Scanning supported PIDs...");
              }
            }

            if (!state.isStreaming && state.activeCommands.isEmpty) {
              return const EmptyState(
                icon: Icons.sensors_off,
                message: "Connecting / No PIDs selected",
              );
            }

            switch (_viewMode) {
              case ViewMode.graph:
                return _buildGraphView(state.activeCommands, useImperial);
              case ViewMode.gauge:
                return _buildGaugeView(
                    state, state.activeCommands, useImperial);
            }
          },
        ),
      ),
    );
  }

  // อัปเดตประวัติข้อมูลกราฟเมื่อมีค่าใหม่เข้ามา
  void _updateHistory(
      Map<String, double> values, List<Command> activeCommands) {
    _timeCounter += 0.2; // เพิ่มเวลาตาม Timer (200ms)

    for (var cmd in activeCommands) {
      if (!_dataHistory.containsKey(cmd.name)) {
        _dataHistory[cmd.name] = [];
      }

      double val = values[cmd.name] ?? 0.0;
      final points = _dataHistory[cmd.name]!;
      points.add(FlSpot(_timeCounter, val));

      // เก็บประวัติย้อนหลังสูงสุด 50 จุด เพื่อประสิทธิภาพ
      if (points.length > 50) {
        points.removeAt(0);
      }
    }
  }

  // ... inside LiveDataPage

  // ... (existing code)

  Widget _buildGraphView(List<Command> activeCommands, bool useImperial) {
    if (activeCommands.isEmpty) return const SizedBox();

    if (_isCombinedGraph) {
      // Build ONE graph with all series
      List<GraphSeries> seriesList = [];
      double overallMinX = double.infinity;
      double overallMaxX = double.negativeInfinity;
      double overallMinY = double.infinity;
      double overallMaxY = double.negativeInfinity;

      for (int i = 0; i < activeCommands.length; i++) {
        final cmd = activeCommands[i];
        final rawPoints = _dataHistory[cmd.name] ?? [];
        if (rawPoints.isEmpty) continue;

        // Convert points
        final displayPoints = rawPoints.map((p) {
          double val = p.y;
          if (useImperial) {
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

        // Update Min/Max
        if (displayPoints.first.x < overallMinX)
          overallMinX = displayPoints.first.x;
        if (displayPoints.last.x > overallMaxX)
          overallMaxX = displayPoints.last.x;

        double localMinY =
            displayPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
        double localMaxY =
            displayPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);
        if (localMinY < overallMinY) overallMinY = localMinY;
        if (localMaxY > overallMaxY) overallMaxY = localMaxY;

        seriesList.add(GraphSeries(
          label: cmd.name,
          points: displayPoints,
          color: _seriesColors[i % _seriesColors.length],
        ));
      }

      if (seriesList.isEmpty) return const SizedBox();

      // Pad Y axis
      overallMinY = (overallMinY - 5).floorToDouble();
      overallMaxY = (overallMaxY + 5).ceilToDouble();
      if (overallMinY < 0) overallMinY = 0;

      return MotusCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LiveDataGraph(
            title: "Combined Graph",
            seriesList: seriesList,
            minX: overallMinX,
            maxX: overallMaxX,
            minY: overallMinY,
            maxY: overallMaxY,
          ),
        ),
      );
    }

    // Separate Graphs (Old Behavior)
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeCommands.length,
      itemBuilder: (context, index) {
        final cmd = activeCommands[index];
        final rawPoints = _dataHistory[cmd.name] ?? [];

        // Convert points for display
        final displayPoints = rawPoints.map((p) {
          double val = p.y;
          if (useImperial) {
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

        return MotusCard(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LiveDataGraph(
              title:
                  "${cmd.name} (${useImperial && cmd.unit == '°C' ? '°F' : (useImperial && cmd.unit == 'km/h' ? 'mph' : cmd.unit)})",
              seriesList: [
                GraphSeries(
                    label: cmd.name,
                    points: displayPoints,
                    color: AppColors.primary)
              ],
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

  Widget _buildGaugeView(
      LiveDataState state, List<Command> activeCommands, bool useImperial) {
    // ใช้ GridView สำหรับแสดงเกจหลายๆ ตัว
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220, // Responsive: More columns on wide screen
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: activeCommands.length,
      itemBuilder: (context, index) {
        final cmd = activeCommands[index];
        final rawValue = state.currentValues[cmd.name] ?? 0.0;

        // Convert value and unit based on logic
        double value = rawValue;
        String unit = cmd.unit;
        double min = cmd.min;
        double max = cmd.max;

        if (useImperial) {
          if (unit == "km/h") {
            value = UnitConverter.kmhToMph(rawValue);
            unit = "mph";
            max = 160; // Approximate 240kmh
          } else if (unit == "°C") {
            value = UnitConverter.celsiusToFahrenheit(rawValue);
            unit = "°F";
            min = 32;
            max = 300;
          } else if (unit == "kPa") {
            value = UnitConverter.kpaToPsi(rawValue);
            unit = "psi";
            max = max * 0.145;
          }
        }

        return MotusCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SimpleGauge(
              label: cmd.name,
              value: value,
              min: min,
              max: max,
              unit: unit,
            ),
          ),
        );
      },
    );
  }
}
