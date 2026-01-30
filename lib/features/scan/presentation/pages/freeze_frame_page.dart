import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/features/scan/presentation/bloc/freeze_frame/freeze_frame_bloc.dart';
import 'package:motus_lab/core/protocol/standard_pids.dart';
import 'package:motus_lab/core/utils/unit_converter.dart';
import 'package:motus_lab/domain/entities/command.dart';

class FreezeFramePage extends StatelessWidget {
  const FreezeFramePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FreezeFrameBloc(
        connection: locator(),
      )..add(LoadFreezeFrameData()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("FREEZE FRAME DATA"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Refresh
                // Use a builder below or just ignore for now as it auto-loads
              },
            )
          ],
        ),
        body: BlocBuilder<FreezeFrameBloc, FreezeFrameState>(
          builder: (context, state) {
            if (state is FreezeFrameLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FreezeFrameError) {
              return Center(child: Text("Error: ${state.message}"));
            } else if (state is FreezeFrameLoaded) {
              return _buildDataTable(context, state);
            }
            return const Center(child: Text("No Data"));
          },
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, FreezeFrameLoaded state) {
    // Columns: PID | Description | English Value | Units | Metric Value | Units
    // Row 1: 02 | DTC that caused Freeze Frame | [DTC] | - | [DTC] | -

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              // กำหนดความกว้างต่ำสุดให้เต็มหน้าจอ เพื่อให้ Scroll แนวนอนทำงานถูกต้อง
              // และป้องกัน Error "RenderFlex overflowed" กรณีหน้าจอกว้างจัด
              constraints: BoxConstraints(
                  minWidth: constraints.hasBoundedWidth
                      ? constraints.maxWidth
                      : 600), // Fallback width for safety
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columnSpacing: 20, // Add some spacing
                horizontalMargin: 20,
                // Center columns by expanding? DataTable doesn't support expanded columns easily.
                // But ConstrainedBox(minWidth) helps background stretch.
                columns: const [
                  DataColumn(
                      label: Text("PID",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Description",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("English Value",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Units",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Metric Value",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Units",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: [
                  // Row 1: DTC
                  DataRow(
                    cells: [
                      const DataCell(Text("02")),
                      const DataCell(Text("DTC that caused Freeze Frame")),
                      DataCell(Text(state.dtc,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold))),
                      const DataCell(Text("-")),
                      DataCell(Text(state.dtc,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold))),
                      const DataCell(Text("-")),
                    ],
                  ),
                  // Other PIDs
                  ..._buildPidRows(state.data),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataRow> _buildPidRows(Map<String, dynamic> data) {
    // List of PIDs we check in Bloc
    final List<Command> commands = [
      StandardPids.calculatedLoad,
      StandardPids.engineCoolantTemp,
      StandardPids.shortTermFuelTrim1,
      StandardPids.longTermFuelTrim1,
      StandardPids.engineRpm,
      StandardPids.vehicleSpeed,
    ];

    return commands.map((cmd) {
      final rawValue = (data[cmd.name]) as double? ?? 0.0;

      // Metric (Default in StandardPids)
      String metricVal = rawValue.toStringAsFixed(1);
      String metricUnit = cmd.unit;

      // English Conversion
      String englishVal = "";
      String englishUnit = "";

      if (cmd.unit == "km/h") {
        englishVal = (UnitConverter.kmhToMph(rawValue)).toStringAsFixed(1);
        englishUnit = "mph";
      } else if (cmd.unit == "°C") {
        englishVal =
            (UnitConverter.celsiusToFahrenheit(rawValue)).toStringAsFixed(1);
        englishUnit = "°F";
      } else if (cmd.unit == "kPa") {
        englishVal = (UnitConverter.kpaToPsi(rawValue)).toStringAsFixed(1);
        englishUnit = "psi";
      } else if (cmd.unit == "g/s") {
        englishVal =
            (UnitConverter.gramsPerSecToLbsPerMin(rawValue)).toStringAsFixed(2);
        englishUnit = "lb/min";
      } else {
        // Same for % or unknown
        englishVal = metricVal;
        englishUnit = metricUnit;
      }

      return DataRow(cells: [
        DataCell(Text(
            cmd.code.substring(2))), // Show only last 2 digits of PID (e.g. 0C)
        DataCell(Text(cmd.name)),
        DataCell(Text(englishVal)),
        DataCell(Text(englishUnit)),
        DataCell(Text(metricVal)),
        DataCell(Text(metricUnit)),
      ]);
    }).toList();
  }
}
