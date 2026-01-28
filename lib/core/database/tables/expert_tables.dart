import 'package:drift/drift.dart';

// 1. สาเหตุที่เป็นไปได้ (Knowledge Base)
class PossibleCauses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()(); // e.g. "Dirty MAF Sensor"
  TextColumn get description => text().nullable()();
  IntColumn get difficultyLevel =>
      integer().withDefault(const Constant(1))(); // 1-5

  // Sync Support
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 2. วิธีการแก้ไข (Service Manual)
class Solutions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get causeId => integer().references(PossibleCauses, #id)();
  TextColumn get steps => text()(); // JSON or Plain Text steps
  RealColumn get estimatedCost => real().nullable()();

  // Sync Support
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
}

// 3. ความฉลาด (Logic Engine)
class DiagnosticIntelligence extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dtcCode => text()(); // e.g. "P0171"
  TextColumn get vehicleModel =>
      text().nullable()(); // e.g. "Honda Civic" (Simplified)
  IntColumn get causeId => integer().references(PossibleCauses, #id)();

  IntColumn get likelihoodScore =>
      integer().withDefault(const Constant(0))(); // 0-100%
  BoolColumn get verifiedByMechanic =>
      boolean().withDefault(const Constant(false))();

  // Sync Support
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
