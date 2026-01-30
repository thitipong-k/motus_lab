import 'dart:io'; // For Platform check
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:window_manager/window_manager.dart'; // For Desktop
import 'package:flutter/material.dart';
import 'package:motus_lab/l10n/app_localizations.dart';
import 'package:motus_lab/core/theme/app_theme.dart';
import 'package:motus_lab/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/theme_cubit.dart';
import 'package:motus_lab/core/theme/app_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // [WORKFLOW STEP 0] Initialization: เริ่มต้นระบบและลงทะเบียน Dependencies
  // โหลด Service Locator (GetIt) เพื่อเตรียมพร้อม injection ทั่วทั้งแอป
  // และ Register Factory/Singleton ของ Bloc และ Repository ต่างๆ
  await setupLocator();

  // --- 1. Mobile: Immersive Mode ---
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // Hide Status Bar & Nav Bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Optional: Lock Orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // --- 2. Desktop: Full Screen ---
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      // size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden, // Clean look, no title bar
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setFullScreen(true); // Force Full Screen
    });
  }

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
