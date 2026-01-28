import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:motus_lab/core/database/tables/vehicles_table.dart';
import 'package:motus_lab/core/database/tables/scan_history_table.dart';
import 'package:motus_lab/core/database/tables/dtc_library_table.dart';
import 'package:motus_lab/core/database/tables/expert_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Vehicles,
  ScanHistory,
  DtcLibrary,
  PossibleCauses,
  Solutions,
  DiagnosticIntelligence
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Migration logic would go here
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'motus_lab.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
