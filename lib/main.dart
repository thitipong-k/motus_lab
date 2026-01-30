import 'package:flutter/material.dart';
import 'package:motus_lab/l10n/app_localizations.dart';
import 'package:motus_lab/core/theme/app_theme.dart';
import 'package:motus_lab/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/theme_cubit.dart';
import 'package:motus_lab/core/theme/app_style.dart';

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
      // สร้าง ThemeCubit เพื่อจัดการ State ของธีมที่เลือก
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, AppStyle>(
        // เมื่อ State เปลี่ยน (เปลี่ยนธีม) UI จะ rebuild ใหม่ด้วย getTheme(style)
        builder: (context, style) {
          return MaterialApp(
            title: 'Motus Lab',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            debugShowCheckedModeBanner: false,
            // Use configured themes dynamically
            theme: AppTheme.getTheme(style),
            // Force Light mode logic because the theme itself defines brightness
            themeMode: ThemeMode.light,
            home: const DashboardPage(),
          );
        },
      ),
    );
  }
}
