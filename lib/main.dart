import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_theme.dart';
import 'package:motus_lab/features/dashboard/presentation/pages/dashboard_page.dart';

import 'package:motus_lab/core/services/service_locator.dart';

void main() {
  // เริ่มต้นระบบ Service Locator
  setupLocator();
  runApp(const MotusApp());
}

class MotusApp extends StatelessWidget {
  const MotusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motus Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardPage(),
    );
  }
}
