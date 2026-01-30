import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/services/report_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/app_style.dart';
import 'package:motus_lab/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:motus_lab/features/reporting/presentation/pages/report_settings_dialog.dart';
import 'package:motus_lab/features/settings/domain/entities/settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsView();
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
      // ใช้ BlocBuilder เพื่อรอรับ State จาก SettingsBloc
      // และสร้าง UI ใหม่ทุกครั้งที่ค่า settings เปลี่ยน
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = state.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- CONNECTION SETTINGS (ตั้งค่าการเชื่อมต่อ) ---
              const Text("Connection",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("Auto-Connect"),
                      subtitle:
                          const Text("Automatically connect to last device"),
                      value: settings.isAutoConnect,
                      onChanged: (val) {
                        context
                            .read<SettingsBloc>()
                            .add(UpdateAutoConnect(val));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text("Connection Timeout"),
                      subtitle:
                          Text("${settings.connectionTimeoutSeconds} seconds"),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: settings.connectionTimeoutSeconds.toDouble(),
                          min: 5,
                          max: 60,
                          divisions: 11,
                          label: "${settings.connectionTimeoutSeconds}s",
                          onChanged: (val) {
                            context
                                .read<SettingsBloc>()
                                .add(UpdateConnectionTimeout(val.toInt()));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- WORKSHOP TOOLS ---
              const Text("Workshop Tools",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.print, color: AppColors.error),
                  title: const Text("Export Last Scan Report"),
                  subtitle:
                      const Text("Generate a PDF for the current vehicle"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showExportDialog(context);
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text("Workshop Branding",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.store, color: AppColors.primary),
                  title: const Text("Shop Information"),
                  subtitle: const Text("Configure Name, Address, Tax ID"),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ReportSettingsDialog(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // --- APP PREFERENCES ---
              const Text("App Preferences",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),

              // Visual Theme
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text("Visual Theme"),
                subtitle: Text(settings.theme.displayName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeSelector(context, settings.theme),
              ),

              // Unit System
              ListTile(
                leading: const Icon(Icons.straighten),
                title: const Text("Unit System"),
                subtitle: Text(settings.unitSystem == UnitSystem.metric
                    ? "Metric"
                    : "Imperial"),
                trailing: Switch(
                  value: settings.unitSystem == UnitSystem.imperial,
                  onChanged: (isImperial) {
                    context.read<SettingsBloc>().add(UpdateUnitSystem(
                        isImperial ? UnitSystem.imperial : UnitSystem.metric));
                  },
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

  void _showThemeSelector(BuildContext context, AppStyle currentStyle) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        // Pass the Bloc to the modal
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
                      subtitle: Text(style.displayName), // Simplified desc
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
                  _generateReport(false); // PDF
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text("Export as CSV"),
                subtitle: const Text("Raw Data for Excel/Analysis"),
                onTap: () {
                  Navigator.pop(ctx);
                  _generateReport(true); // CSV
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _generateReport(bool isCsv) {
    // Mock Data for Demo (In real app, this should come from Bloc State or Cache)
    const vin = "1234567890ABCDEFG";
    const dtcs = ["P0101", "P0300"];
    const liveData = {
      "Engine RPM": 750.0,
      "Coolant Temp": 92.0,
      "Vehicle Speed": 0.0,
    };

    if (isCsv) {
      locator<ReportService>()
          .generateCsvReport(vin: vin, dtcs: dtcs, liveData: liveData);
    } else {
      locator<ReportService>()
          .generateHealthReport(vin: vin, dtcs: dtcs, liveData: liveData);
    }
  }
}
