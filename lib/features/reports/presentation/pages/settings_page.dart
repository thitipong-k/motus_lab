import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/reports/domain/services/report_generator.dart';

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
          const ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text("Dark Mode"),
            trailing: Switch(value: true, onChanged: null),
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
}
