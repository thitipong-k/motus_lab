import 'package:get_it/get_it.dart';
import 'package:motus_lab/core/connection/bluetooth_service.dart' as motus;
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/connection/mock_connection.dart';
import 'package:motus_lab/core/connection/ble_connection.dart';
import 'package:motus_lab/features/scan/presentation/bloc/live_data/live_data_bloc.dart';
import 'package:motus_lab/features/scan/presentation/bloc/dtc/dtc_bloc.dart';
import 'package:motus_lab/core/database/app_database.dart';
import 'package:motus_lab/data/repositories/diagnostic_repository.dart';
import 'package:motus_lab/data/repositories/protocol_repository.dart';

final locator = GetIt.instance;

/// ฟังก์ชันสำหรับลงทะเบียน Service ทั้งหมดในแอป
/// ช่วยให้เรียกใช้ Instance เดิมซ้ำได้จากทุกที่ (Singleton)
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

  // 3. Blocs
  locator.registerFactory(() => LiveDataBloc(
        engine: locator<ProtocolEngine>(),
        connection: locator<ConnectionInterface>(),
        repository: locator<ProtocolRepository>(),
      ));

  locator.registerFactory(() => DtcBloc(
        engine: locator<ProtocolEngine>(),
        connection: locator<ConnectionInterface>(),
      ));
}
