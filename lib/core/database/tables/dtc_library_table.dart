import 'package:drift/drift.dart';

class DtcLibrary extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()(); // e.g. P0101
  TextColumn get description => text()();
  TextColumn get possibleCauses => text().nullable()();

  // Offline Sync Columns (In case we update library from server)
  BoolColumn get isSynced => boolean()
      .withDefault(const Constant(true))(); // Default true for initial data
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
