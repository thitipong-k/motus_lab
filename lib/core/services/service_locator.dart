import 'package:get_it/get_it.dart';
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
import 'package:motus_lab/core/database/app_database.dart';
import 'package:motus_lab/features/scan/data/repositories/diagnostic_repository.dart';
import 'package:motus_lab/features/scan/data/repositories/protocol_repository.dart';
import 'package:motus_lab/features/scan/data/repositories/vehicle_profile_repository.dart';
import 'package:motus_lab/domain/repositories/shop_profile_repository.dart';
import 'package:motus_lab/data/repositories/shop_profile_repository_impl.dart';
import 'package:motus_lab/core/services/report_service.dart';

final locator = GetIt.instance;

/// ฟังก์ชันสำหรับลงทะเบียน Service ทั้งหมดในแอป
/// ช่วยให้เรียกใช้ Instance เดิมซ้ำได้จากทุกที่ (Singleton)
/// [WORKFLOW STEP 0] Initialization: เริ่มต้นระบบและลงทะเบียน Dependencies
void setupLocator() {
  // 1. Core Logic
  locator.registerLazySingleton(() => ProtocolEngine());

  // 2. Connection Logic
  locator.registerLazySingleton(() => motus.BluetoothService());

  locator.registerLazySingleton<ConnectionInterface>(() => MockConnection());
  // locator.registerLazySingleton<ConnectionInterface>(() => BleConnection());

  // Database & Repositories
  locator.registerLazySingleton(() => AppDatabase());
  locator.registerLazySingleton(() => DiagnosticRepository(locator()));
  locator.registerLazySingleton(() => ProtocolRepository());
  locator.registerLazySingleton(() => VehicleProfileRepository(locator()));
  locator.registerLazySingleton<ShopProfileRepository>(
      () => ShopProfileRepositoryImpl(locator()));
  locator.registerLazySingleton(() => ReportService(locator()));

  // 2.1 UseCases
  locator.registerLazySingleton(
      () => GetSupportedPidsUseCase(locator<VehicleProfileRepository>()));
  locator.registerLazySingleton(
      () => ConnectToDeviceUseCase(locator<ConnectionInterface>()));
  locator.registerLazySingleton(() => ReadVinUseCase(locator<ProtocolEngine>(),
      locator<ConnectionInterface>(), locator<ProtocolRepository>()));

  // 3. Blocs
  locator.registerFactory(() => ScanBloc(
      bluetoothService: locator<motus.BluetoothService>(),
      connection: locator<ConnectionInterface>(),
      connectToDevice: locator<ConnectToDeviceUseCase>()));
  locator.registerFactory(() => LiveDataBloc(
        engine: locator<ProtocolEngine>(),
        connection: locator<ConnectionInterface>(),
        repository: locator<ProtocolRepository>(),
        profileRepository: locator<VehicleProfileRepository>(),
        getSupportedPids: locator<GetSupportedPidsUseCase>(),
        readVin: locator<ReadVinUseCase>(),
      ));

  locator.registerFactory(() => DtcBloc(
        engine: locator<ProtocolEngine>(),
        connection: locator<ConnectionInterface>(),
      ));
}
