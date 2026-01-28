import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_theme.dart';
import 'package:motus_lab/features/dashboard/presentation/pages/dashboard_page.dart';

import 'package:motus_lab/core/services/service_locator.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/theme_cubit.dart';

void main() {
  // เริ่มต้นระบบ Service Locator
  setupLocator();
  runApp(const MotusApp());
}

class MotusApp extends StatelessWidget {
  const MotusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Motus Lab',
            debugShowCheckedModeBanner: false,
            // Use configured themes
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // Use current mode from Cubit
            themeMode: themeMode,
            home: const DashboardPage(),
          );
        },
      ),
    );
  }
}
