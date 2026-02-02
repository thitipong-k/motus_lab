import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/shared/widgets/motus_card.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HELP CENTER"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroSection(context),
          const SizedBox(height: 24),
          _buildCategory(
            context,
            "Connectivity",
            Icons.bluetooth,
            [
              "How to pair your Bluetooth adapter",
              "WiFi: IP 192.168.0.10 & Port 35000",
              "How to choose the correct USB COM Port",
              "Baudrate settings (38400 vs 115200)",
              "Common connection issues",
            ],
          ),
          const SizedBox(height: 16),
          _buildCategory(
            context,
            "Diagnostics",
            Icons.troubleshoot,
            [
              "Understanding DTC codes",
              "How to clear Check Engine light",
              "Reading Freeze Frame data",
            ],
          ),
          const SizedBox(height: 16),
          _buildCategory(
            context,
            "Dashboard & Data",
            Icons.speed,
            [
              "Customizing live data gauges",
              "Recording logs and exports",
              "Unit conversion settings",
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.description),
              label: const Text("View Full Technical Manual (PDF)"),
              onPressed: () {
                // Future: Launch URL or internal PDF viewer
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return MotusCard(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.psychology, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              "How can we help today?",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Search our knowledge base or browse categories below",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(
      BuildContext context, String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item),
                trailing: const Icon(Icons.chevron_right, size: 16),
                onTap: () {
                  // Future: Show article detail
                },
              ),
            )),
      ],
    );
  }
}
