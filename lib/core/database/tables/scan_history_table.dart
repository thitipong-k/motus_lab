import 'package:drift/drift.dart';
import 'package:motus_lab/core/database/tables/vehicles_table.dart';

class ScanHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId => integer().references(Vehicles, #id)();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get dtcCodes => text()(); // JSON or Comma-separated
  TextColumn get status => text().withDefault(const Constant('completed'))();

  // Offline Sync Columns
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
