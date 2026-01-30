import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/core/theme/app_style.dart';
import 'package:motus_lab/features/reporting/domain/entities/report_entities.dart';
import 'package:motus_lab/features/reporting/presentation/bloc/report_bloc.dart';
import 'package:motus_lab/features/reporting/presentation/pages/report_settings_dialog.dart';
import 'package:motus_lab/features/scan/domain/entities/dtc_result.dart';
import 'package:motus_lab/features/settings/domain/entities/settings.dart';
import 'package:motus_lab/features/settings/presentation/bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state.status == ReportStatus.exported) {
          if (state.generatedPdf != null) {
            // Open PDF for printing/viewing
            Printing.layoutPdf(
              onLayout: (format) async => state.generatedPdf!.readAsBytesSync(),
              name: 'Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
            );
          } else {
            // CSV or other non-PDF success
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report exported successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          // Reset status to prevent duplicate popups on rebuild
          context.read<ReportBloc>().add(ResetReportStatus());
        } else if (state.status == ReportStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export Failed: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
          // Also reset failure status to allow retry
          context.read<ReportBloc>().add(ResetReportStatus());
        }
      },
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SETTINGS"),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentSettings = state.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Workshop Section
              const Text(
                "Workshop Branding",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    BlocBuilder<ReportBloc, ReportState>(
                      builder: (context, reportState) {
                        final config = reportState.config;
                        if (config == null) return const SizedBox();

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo with visible border/background
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: config.logoPath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            _buildLogoImage(config.logoPath!),
                                      )
                                    : const Icon(Icons.store,
                                        color: Colors.grey),
                              ),
                              const SizedBox(width: 16),
                              // Faded Text Info
                              Expanded(
                                child: Opacity(
                                  opacity: 0.6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        config.shopName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        config.address,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      if (config.taxId != null &&
                                          config.taxId!.isNotEmpty)
                                        Text(
                                          "TAX ID: ${config.taxId}",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              // Clear Edit Button
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: AppColors.primary),
                                tooltip: "Edit Shop Profile",
                                onPressed: () => _openShopSettings(context),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Preferences",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.bluetooth),
                      title: const Text("Auto-Connect"),
                      subtitle: const Text("Scan for OBD2 on startup"),
                      trailing: SizedBox(
                        width: 48,
                        child: Switch(
                          value: currentSettings.isAutoConnect,
                          onChanged: (val) {
                            context
                                .read<SettingsBloc>()
                                .add(UpdateAutoConnect(val));
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: const Text("Connection Timeout"),
                      subtitle: Text(
                          "${currentSettings.connectionTimeoutSeconds} seconds"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Implement Timeout Picker
                        context.read<SettingsBloc>().add(
                            const UpdateConnectionTimeout(
                                15)); // Example update
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Data & Export",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.save_alt),
                      title: const Text("Export Reports"),
                      subtitle: const Text("PDF / CSV"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showExportDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      title: const Text("Clear Cache"),
                      subtitle: const Text("Remove all diagnostic logs"),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "System",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text("Visual Theme"),
                subtitle: Text(currentSettings.theme.displayName),
                onTap: () => _showThemeSelector(context, currentSettings.theme),
              ),

              ListTile(
                leading: const Icon(Icons.straighten),
                title: const Text("Unit System"),
                subtitle: Text(currentSettings.unitSystem == UnitSystem.imperial
                    ? "Imperial (mph, °F)"
                    : "Metric (km/h, °C)"),
                trailing: SizedBox(
                  width: 48,
                  child: Switch(
                    value: currentSettings.unitSystem == UnitSystem.imperial,
                    onChanged: (isImperial) {
                      context.read<SettingsBloc>().add(UpdateUnitSystem(
                          isImperial
                              ? UnitSystem.imperial
                              : UnitSystem.metric));
                    },
                  ),
                ),
              ),

              const ListTile(
                leading: Icon(Icons.language),
                title: Text("Language"),
                subtitle: Text("English (Device Default)"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogoImage(String path) {
    if (path.startsWith('data:image')) {
      final base64Data = path.split(',').last;
      return Image.memory(
        base64Decode(base64Data),
        height: 50,
        width: 50,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.red, size: 24),
      );
    }

    if (kIsWeb) {
      return const Icon(Icons.image, color: Colors.grey, size: 24);
    }

    final file = File(path);
    if (!file.existsSync()) {
      return const Icon(Icons.image_not_supported,
          color: Colors.grey, size: 24);
    }

    return Image.file(
      file,
      height: 50,
      width: 50,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, color: Colors.red, size: 24),
    );
  }

  void _openShopSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReportSettingsDialog(),
    );
  }

  void _showThemeSelector(BuildContext context, AppStyle currentStyle) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<SettingsBloc>(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Select Visual Theme",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                ...AppStyle.values.map((style) => RadioListTile<AppStyle>(
                      title: Text(style.displayName),
                      subtitle: Text(style.displayName),
                      value: style,
                      groupValue: currentStyle,
                      onChanged: (val) {
                        if (val != null) {
                          context.read<SettingsBloc>().add(UpdateTheme(val));
                          Navigator.pop(ctx);
                        }
                      },
                    )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Export Report",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.orange),
                title: const Text("Export as PDF"),
                subtitle: const Text("Professional Report for Print"),
                onTap: () {
                  Navigator.pop(ctx);
                  _generateReport(context, false); // PDF
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text("Export as CSV"),
                subtitle: const Text("Raw Data for Excel/Analysis"),
                onTap: () {
                  Navigator.pop(ctx);
                  _generateReport(context, true); // CSV
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _generateReport(BuildContext context, bool isCsv) {
    final reportData = DiagnosticReport(
      id: "R-${DateTime.now().millisecondsSinceEpoch}",
      timestamp: DateTime.now(),
      vehicleName: "Demo Vehicle",
      vehicleVin: "1234567890ABCDEFG",
      technicianName: "Motus Lab Tech",
      dtcList: [
        const DtcResult(code: "P0101", description: "MAF Circuit Range"),
        const DtcResult(code: "P0300", description: "Random Misfire"),
      ],
    );

    if (isCsv) {
      context.read<ReportBloc>().add(GenerateReportCsv(reportData));
    } else {
      context.read<ReportBloc>().add(GenerateReportPdf(reportData));
    }
  }
}
