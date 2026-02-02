import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motus_lab/core/connection/bluetooth_service.dart' as motus;
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/connection/mock_connection.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/dtc/dtc_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:motus_lab/features/scan/domain/usecases/connect_to_device.dart';
import 'package:motus_lab/features/scan/domain/usecases/get_supported_pids.dart';
import 'package:motus_lab/features/scan/domain/usecases/read_vin.dart';
import 'package:motus_lab/features/scan/data/repositories/topology_repository_impl.dart';
import 'package:motus_lab/features/scan/domain/repositories/topology_repository.dart';
import 'package:motus_lab/features/scan/presentation/bloc/topology/topology_bloc.dart';
import 'package:motus_lab/core/database/app_database.dart';
import 'package:motus_lab/features/scan/data/repositories/diagnostic_repository.dart';
import 'package:motus_lab/features/scan/data/repositories/protocol_repository.dart';
import 'package:motus_lab/features/scan/data/repositories/vehicle_profile_repository.dart';
import 'package:motus_lab/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:motus_lab/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:motus_lab/features/settings/domain/repositories/settings_repository.dart';
import 'package:motus_lab/core/services/vehicle_integration/home_widget_service.dart';
import 'package:motus_lab/core/services/vehicle_integration/carplay_service.dart';
import 'package:motus_lab/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:motus_lab/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:motus_lab/features/maintenance/data/repositories/maintenance_repository_impl.dart';
import 'package:motus_lab/features/maintenance/presentation/bloc/maintenance_bloc.dart';
import 'package:motus_lab/features/crm/domain/repositories/crm_repository.dart';
import 'package:motus_lab/features/crm/data/repositories/crm_repository_impl.dart';
import 'package:motus_lab/core/services/security/biometric_service.dart';
import 'package:motus_lab/features/crm/presentation/bloc/crm_bloc.dart';
import 'package:motus_lab/features/remote/domain/repositories/remote_repository.dart';
import 'package:motus_lab/features/remote/data/repositories/remote_repository_impl.dart';
import 'package:motus_lab/features/remote/presentation/bloc/remote_bloc.dart';
import 'package:motus_lab/features/reporting/domain/repositories/report_repository.dart';
import 'package:motus_lab/features/reporting/data/repositories/report_repository_impl.dart';
import 'package:motus_lab/features/reporting/data/services/pdf_generator_service.dart';
import 'package:motus_lab/features/reporting/presentation/bloc/report_bloc.dart';
import 'package:motus_lab/features/scan/domain/repositories/log_repository.dart';
import 'package:motus_lab/features/scan/data/repositories/log_repository_impl.dart';
import 'package:motus_lab/core/services/security/auth_service.dart';
import 'package:motus_lab/core/services/sync_service.dart';
import 'package:motus_lab/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:motus_lab/features/scan/domain/services/diagnostic_expert_service.dart';
import 'package:motus_lab/features/scan/data/repositories/vehicle_stats_repository.dart';
import 'package:motus_lab/core/services/cloud_seed_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // 0. External Services
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);

  // 1. Core Logic
  locator.registerLazySingleton(() => ProtocolEngine());
  locator.registerLazySingleton(() => DiagnosticExpertService(locator()));

  // 2. Connection Logic
  locator.registerLazySingleton(() => motus.BluetoothService());
  locator.registerLazySingleton<ConnectionInterface>(() => MockConnection());

  // Database & Repositories
  locator.registerLazySingleton(() => AppDatabase());
  locator.registerLazySingleton(() => DiagnosticRepository(locator()));
  locator.registerLazySingleton(() => ProtocolRepository());
  locator.registerLazySingleton(() => VehicleProfileRepository(locator()));
  locator.registerLazySingleton(() => VehicleStatsRepository(locator()));
  locator.registerLazySingleton<TopologyRepository>(
      () => TopologyRepositoryImpl(locator(), locator()));

  // 2.1 UseCases
  locator.registerLazySingleton(
      () => GetSupportedPidsUseCase(locator<VehicleProfileRepository>()));
  locator.registerLazySingleton(
      () => ConnectToDeviceUseCase(locator<ConnectionInterface>()));
  locator.registerLazySingleton(() => ReadVinUseCase(locator<ProtocolEngine>(),
      locator<ConnectionInterface>(), locator<ProtocolRepository>()));

  // 3. Blocs
  locator.registerLazySingleton(() => ScanBloc(
      bluetoothService: locator<motus.BluetoothService>(),
      connection: locator<ConnectionInterface>(),
      connectToDevice: locator<ConnectToDeviceUseCase>(),
      settingsRepository: locator<SettingsRepository>(),
      homeWidgetService: locator<HomeWidgetService>()));
  locator.registerLazySingleton(() => LiveDataBloc(
        engine: locator<ProtocolEngine>(),
        connection: locator<ConnectionInterface>(),
        repository: locator<ProtocolRepository>(),
        profileRepository: locator<VehicleProfileRepository>(),
        getSupportedPids: locator<GetSupportedPidsUseCase>(),
        readVin: locator<ReadVinUseCase>(),
        logRepository: locator<LogRepository>(),
        vehicleStatsRepository: locator<VehicleStatsRepository>(),
      ));

  locator.registerLazySingleton(() => DtcBloc(
        engine: locator<ProtocolEngine>(),
        connection: locator<ConnectionInterface>(),
        vehicleStatsRepository: locator<VehicleStatsRepository>(),
      ));

  locator.registerFactory(() => TopologyBloc(repository: locator()));

  // 5. Settings Feature
  locator.registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsLocalDataSourceImpl(locator()));
  locator.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(locator()));
  locator.registerLazySingleton<SettingsBloc>(
      () => SettingsBloc(repository: locator()));

  // 6. Maintenance Feature
  locator.registerLazySingleton<MaintenanceRepository>(
      () => MaintenanceRepositoryImpl(locator()));
  locator.registerFactory<MaintenanceBloc>(() => MaintenanceBloc(locator()));

  // 7. CRM Feature
  locator
      .registerLazySingleton<CrmRepository>(() => CrmRepositoryImpl(locator()));
  locator.registerFactory<CrmBloc>(() => CrmBloc(locator()));

  // 7.1 Data Logging
  locator.registerLazySingleton<MaintenanceRepository>(
      () => MaintenanceRepositoryImpl(locator()),
      instanceName: 'maintenance_repo_duplicate'); // Avoid conflict
  locator.registerLazySingleton<LogRepository>(() => LogRepositoryImpl());

  // 8. Remote Expert
  locator.registerLazySingleton<RemoteRepository>(() => RemoteRepositoryImpl());
  locator.registerFactory<RemoteBloc>(() => RemoteBloc(locator()));

  // 9. Professional Reporting
  locator
      .registerLazySingleton<PdfGeneratorService>(() => PdfGeneratorService());
  locator.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl(
        pdfService: locator(),
        prefs: locator(),
      ));
  locator.registerFactory<ReportBloc>(() => ReportBloc(locator()));

  // 10. Vehicle Integration
  locator.registerLazySingleton(() => HomeWidgetService());
  locator.registerLazySingleton(() => CarPlayService());

  // 8. Security
  locator.registerLazySingleton<BiometricService>(() => BiometricService());
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<SyncService>(
      () => SyncService(locator(), locator()));

  // 11. Auth Feature
  locator.registerFactory<AuthBloc>(() => AuthBloc(locator()));

  // 12. Seeding Service
  locator.registerLazySingleton<CloudSeedService>(
      () => CloudSeedService(locator()));

  // Initialize Sync System
  locator<SyncService>().init();
}
