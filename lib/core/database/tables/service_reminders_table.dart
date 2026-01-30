import 'package:drift/drift.dart';

class ServiceReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()(); // e.g., "Change Oil"
  IntColumn get dueMileage => integer().nullable()(); // e.g., 50000
  DateTimeColumn get dueDate => dateTime().nullable()(); // e.g., 2024-12-31
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
}
