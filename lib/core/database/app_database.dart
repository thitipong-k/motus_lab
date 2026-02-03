import 'package:drift/drift.dart';
import 'package:motus_lab/core/database/tables/service_reminders_table.dart';
import 'package:motus_lab/core/database/tables/vehicles_table.dart';
import 'package:motus_lab/core/database/tables/vehicle_profiles_table.dart';
import 'package:motus_lab/core/database/tables/scan_history_table.dart';
import 'package:motus_lab/core/database/tables/dtc_library_table.dart';
import 'package:motus_lab/core/database/tables/expert_tables.dart';
import 'package:motus_lab/core/database/tables/shop_profile_table.dart';
import 'package:motus_lab/core/database/tables/customers_table.dart';
import 'package:motus_lab/core/database/tables/vehicle_stats_table.dart';
import 'connection/connection.dart'
    if (dart.library.io) 'connection/native.dart'
    if (dart.library.html) 'connection/web.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Vehicles,
  VehicleProfiles,
  ScanHistory,
  DtcLibrary,
  PossibleCauses,
  Solutions,
  DiagnosticIntelligence,
  ShopProfiles,
  ServiceReminders,
  Customers,
  VehicleScanStats
])
class AppDatabase extends _$AppDatabase {
  AppDatabase({String? encryptionKey})
      : super(openConnection(key: encryptionKey));

  @override
  int get schemaVersion =>
      6; // Incremented for VehicleStats (Predictive Caching)

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            await m.createTable(shopProfiles);
          }
          if (from < 4) {
            await m.createTable(serviceReminders);
          }
          if (from < 5) {
            await m.createTable(customers);
            await m.addColumn(vehicles, vehicles.customerId);
          }
          if (from < 6) {
            await m.createTable(vehicleScanStats);
          }
        },
        beforeOpen: (details) async {
          // pre-populate shop profile if empty
          if (details.wasCreated) {
            // ...
          }
        },
      );
}
