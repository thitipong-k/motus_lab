import 'package:motus_lab/features/maintenance/domain/entities/service_reminder.dart';

abstract class MaintenanceRepository {
  Stream<List<ServiceReminder>> watchReminders();
  Future<List<ServiceReminder>> getReminders();
  Future<void> addReminder(String title,
      {int? mileage, DateTime? date, String? note});
  Future<void> completeReminder(int id, bool isCompleted);
  Future<void> deleteReminder(int id);
}
