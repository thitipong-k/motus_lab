import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

class AdaptationPage extends StatefulWidget {
  const AdaptationPage({super.key});

  @override
  State<AdaptationPage> createState() => _AdaptationPageState();
}

class _AdaptationPageState extends State<AdaptationPage> {
  bool _drlEnabled = true;
  bool _autoLock = false;
  double _idleRpmAdjustment = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CODING & ADAPTATION"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Bitwise Toggles",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Daytime Running Lights (DRL)"),
                  subtitle: const Text("Enable or disable LED DRLs"),
                  value: _drlEnabled,
                  onChanged: (val) => setState(() => _drlEnabled = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text("Automatic Door Lock"),
                  subtitle: const Text("Lock doors when speed > 20km/h"),
                  value: _autoLock,
                  onChanged: (val) => setState(() => _autoLock = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("Parameter Adjustment",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Idle RPM Offset: ${_idleRpmAdjustment.toStringAsFixed(0)} RPM"),
                  Slider(
                    value: _idleRpmAdjustment,
                    min: -500,
                    max: 500,
                    divisions: 10,
                    label: _idleRpmAdjustment.round().toString(),
                    onChanged: (val) =>
                        setState(() => _idleRpmAdjustment = val),
                  ),
                  const Text(
                    "Note: Adjusting idle RPM may affect emissions and engine stability.",
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _showWriteWarning(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("WRITE TO ECU",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showWriteWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("CONFIRM WRITE"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to write these changes?"),
            SizedBox(height: 16),
            Text("✅ Engine OFF", style: TextStyle(color: Colors.green)),
            Text("✅ Ignition ON", style: TextStyle(color: Colors.green)),
            Text("✅ Battery > 12.5V", style: TextStyle(color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Changes written successfully!"),
                    backgroundColor: AppColors.success),
              );
            },
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );
  }
}
