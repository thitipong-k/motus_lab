import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/reports/domain/services/report_generator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/theme_cubit.dart';
import 'package:motus_lab/core/theme/app_style.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SETTINGS & REPORTS"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Workshop Tools",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
              title: const Text("Export Last Scan Report"),
              subtitle: const Text("Generate a PDF for the current vehicle"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // จำลองการส่งข้อมูล
                ReportGenerator.generateAndPrintReport(
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
          const Text("App Preferences",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),

          // Theme Selector
          BlocBuilder<ThemeCubit, AppStyle>(
            builder: (context, currentStyle) {
              return ListTile(
                leading: const Icon(Icons.palette),
                title: const Text("Visual Theme"),
                subtitle: Text(currentStyle.displayName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeSelector(context, currentStyle),
              );
            },
          ),

          const ListTile(
            leading: Icon(Icons.language),
            title: Text("Language"),
            subtitle: Text("English (Device Default)"),
          ),
        ],
      ),
    );
  }

  /// **แสดง Popup ให้เลือก Visual Theme (5 แบบ)**
  void _showThemeSelector(BuildContext context, AppStyle currentStyle) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        // Use BlocProvider.value to pass the existing cubit to the modal sheet
        return BlocProvider.value(
          value: context.read<ThemeCubit>(),
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
                    subtitle: Text(_getStyleDesc(style)),
                    value: style,
                    groupValue: currentStyle,
                    onChanged: (val) {
                      if (val != null) {
                        context.read<ThemeCubit>().setStyle(val);
                        Navigator.pop(ctx);
                      }
                    },
                  )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getStyleDesc(AppStyle style) {
    switch (style) {
      case AppStyle.cyberpunk:
        return "Neon / High Tech";
      case AppStyle.professional:
        return "Clean / Trustworthy";
      case AppStyle.glass:
        return "Modern / Translucent";
      case AppStyle.tactical:
        return "Rugged / Industrial";
      case AppStyle.eco:
        return "Minimal / Green";
    }
  }
}
