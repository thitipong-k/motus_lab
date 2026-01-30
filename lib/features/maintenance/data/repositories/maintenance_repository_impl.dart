import 'package:motus_lab/core/database/app_database.dart';
import 'package:motus_lab/features/maintenance/domain/entities/service_reminder.dart'
    as domain;
import 'package:motus_lab/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:drift/drift.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final AppDatabase _db;

  MaintenanceRepositoryImpl(this._db);

  @override
  Stream<List<domain.ServiceReminder>> watchReminders() {
    return _db.select(_db.serviceReminders).watch().map((rows) {
      return rows.map((row) => _mapToEntity(row)).toList();
    });
  }

  @override
  Future<List<domain.ServiceReminder>> getReminders() async {
    final rows = await _db.select(_db.serviceReminders).get();
    return rows.map((row) => _mapToEntity(row)).toList();
  }

  @override
  Future<void> addReminder(String title,
      {int? mileage, DateTime? date, String? note}) async {
    await _db.into(_db.serviceReminders).insert(
          ServiceRemindersCompanion.insert(
            title: title,
            dueMileage: Value(mileage),
            dueDate: Value(date),
            note: Value(note),
          ),
        );
  }

  @override
  Future<void> completeReminder(int id, bool isCompleted) async {
    await (_db.update(_db.serviceReminders)..where((t) => t.id.equals(id)))
        .write(ServiceRemindersCompanion(isCompleted: Value(isCompleted)));
  }

  @override
  Future<void> deleteReminder(int id) async {
    await (_db.delete(_db.serviceReminders)..where((t) => t.id.equals(id)))
        .go();
  }

  domain.ServiceReminder _mapToEntity(ServiceReminder row) {
    return domain.ServiceReminder(
      id: row.id,
      title: row.title,
      dueMileage: row.dueMileage,
      dueDate: row.dueDate,
      isCompleted: row.isCompleted,
      note: row.note,
    );
  }
}
