import 'package:drift/drift.dart';

class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get vin => text().unique()();
  TextColumn get make => text().nullable()();
  TextColumn get model => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get protocol =>
      text().nullable()(); // Saved protocol (e.g. ISO 15765-4)

  // CRM Integration
  IntColumn get customerId => integer().nullable()();

  // Offline Sync Columns
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
