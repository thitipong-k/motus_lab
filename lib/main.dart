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
import 'package:motus_lab/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/dtc/dtc_bloc.dart';
import 'package:motus_lab/features/reporting/presentation/bloc/report_bloc.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
            create: (_) => locator<SettingsBloc>()..add(LoadSettings())),
        BlocProvider(create: (_) => locator<ScanBloc>()),
        BlocProvider(create: (_) => locator<LiveDataBloc>()),
        BlocProvider(create: (_) => locator<DtcBloc>()),
        BlocProvider(create: (_) => locator<ReportBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, AppStyle>(
        builder: (context, style) {
          // Listen to Settings to update ThemeCubit if needed (optional sync)
          // For now, Settings Page updates ThemeCubit directly.

          return MaterialApp(
            title: 'Motus Lab',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(style),
            themeMode: ThemeMode.light,
            home: const DashboardPage(),
          );
        },
      ),
    );
  }
}
