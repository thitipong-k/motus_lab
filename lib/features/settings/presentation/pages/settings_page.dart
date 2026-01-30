import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/services/report_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/app_style.dart';
import 'package:motus_lab/features/reports/presentation/widgets/shop_branding_form.dart';
import 'package:motus_lab/features/settings/presentation/bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with BlocProvider to ensure we have the SettingsBloc
    return BlocProvider(
      create: (context) => locator<SettingsBloc>()..add(LoadSettings()),
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
                  leading:
                      const Icon(Icons.picture_as_pdf, color: AppColors.error),
                  title: const Text("Export Last Scan Report"),
                  subtitle:
                      const Text("Generate a PDF for the current vehicle"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Mock data for demo
                    locator<ReportService>().generateHealthReport(
                      vin: "1234567890ABCDEFG",
                      dtcs: ["P0101", "P0300"],
                      liveData: {
                        "Engine RPM": 750.0,
                        "Coolant Temp": 92.0,
                        "Vehicle Speed": 0.0,
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text("Workshop Branding",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ShopBrandingForm(),
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
}
