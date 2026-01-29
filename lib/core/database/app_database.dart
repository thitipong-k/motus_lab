import 'package:drift/drift.dart';
import 'package:motus_lab/core/database/tables/vehicles_table.dart';
import 'package:motus_lab/core/database/tables/vehicle_profiles_table.dart';
import 'package:motus_lab/core/database/tables/scan_history_table.dart';
import 'package:motus_lab/core/database/tables/dtc_library_table.dart';
import 'package:motus_lab/core/database/tables/expert_tables.dart';
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
  DiagnosticIntelligence
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2; // Incremented for VehicleProfiles

  // Migration logic would go here
}
