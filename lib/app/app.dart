import 'package:flutter/material.dart';
// [ARCHITECTURE] MultiBlocProvider: จัดการ State Management ระดับ Global ของแอปพลิเคชัน
// [UI] MaterialApp: ตั้งค่า Theme, Localization และหน้าเริ่มต้น (Home)
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/theme/app_theme.dart';
import 'package:motus_lab/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:motus_lab/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:motus_lab/features/reporting/presentation/bloc/report_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/dtc/dtc_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:motus_lab/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:motus_lab/l10n/app_localizations.dart';

class MotusApp extends StatelessWidget {
  const MotusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
            value: locator<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider.value(value: locator<SettingsBloc>()..add(LoadSettings())),
        BlocProvider.value(value: locator<ScanBloc>()),
        BlocProvider.value(value: locator<LiveDataBloc>()),
        BlocProvider.value(value: locator<DtcBloc>()),
        BlocProvider.value(
            value: locator<ReportBloc>()..add(LoadReportConfig())),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final style = state.settings.theme;
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
