import 'package:flutter/material.dart';
import 'package:motus_lab/core/services/cloud_seed_service.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

class CloudSeedPage extends StatefulWidget {
  const CloudSeedPage({super.key});

  @override
  State<CloudSeedPage> createState() => _CloudSeedPageState();
}

class _CloudSeedPageState extends State<CloudSeedPage> {
  final Map<String, bool> _loadingMap = {};
  final Map<String, String> _statusMap = {};

  final List<Map<String, String>> _assets = [
    {
      'title': 'Core DTC Bank (Codes)',
      'subtitle': '9,000+ Standard Codes',
      'path': 'assets/data/codes.json',
      'brand': 'standard'
    },
    {
      'title': 'Generic Extension',
      'subtitle': 'Advanced Generic Definitions',
      'path': 'assets/data/generic_codes.json',
      'brand': 'standard'
    },
    {
      'title': 'Thai Repair Guides',
      'subtitle': 'Expert Fixes in Thai Language',
      'path': 'assets/data/diagnostic_data_th.json',
      'brand': 'thailand'
    },
    {
      'title': 'Manufacturer Database',
      'subtitle': '18,000+ Brand-Specific Codes',
      'path': 'assets/data/dtc_definitions.json',
      'brand': 'auto_detect'
    },
  ];

  Future<void> _runSeed(Map<String, String> asset) async {
    final path = asset['path']!;
    final brand = asset['brand']!;

    setState(() {
      _loadingMap[path] = true;
      _statusMap[path] = 'Seeding...';
    });

    try {
      final seeder = locator<CloudSeedService>();
      await seeder.seedBrandToCloud(brand, path);

      setState(() {
        _loadingMap[path] = false;
        _statusMap[path] = 'Success!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully seeded ${asset['title']}')),
        );
      }
    } catch (e) {
      setState(() {
        _loadingMap[path] = false;
        _statusMap[path] = 'Failed: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Data Manager'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _assets.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.white10),
        itemBuilder: (context, index) {
          final asset = _assets[index];
          final path = asset['path']!;
          final isLoading = _loadingMap[path] ?? false;
          final status = _statusMap[path] ?? 'Ready';

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Icon(
              Icons.insert_drive_file,
              color:
                  status == 'Success!' ? AppColors.success : AppColors.primary,
            ),
            title: Text(
              asset['title']!,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset['subtitle']!,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  'Status: $status',
                  style: TextStyle(
                    fontSize: 12,
                    color: status == 'Success!'
                        ? AppColors.success
                        : status.contains('Failed')
                            ? AppColors.error
                            : Colors.blueGrey,
                  ),
                ),
              ],
            ),
            trailing: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : ElevatedButton(
                    onPressed: () => _runSeed(asset),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'Success!'
                          ? Colors.grey
                          : AppColors.primary,
                    ),
                    child: Text(status == 'Success!' ? 'RE-SEED' : 'IMPORT'),
                  ),
          );
        },
      ),
    );
  }
}
