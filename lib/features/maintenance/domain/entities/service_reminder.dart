import 'package:equatable/equatable.dart';

class ServiceReminder extends Equatable {
  final int id;
  final String title;
  final int? dueMileage;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? note;

  const ServiceReminder({
    required this.id,
    required this.title,
    this.dueMileage,
    this.dueDate,
    this.isCompleted = false,
    this.note,
  });

  @override
  List<Object?> get props =>
      [id, title, dueMileage, dueDate, isCompleted, note];
}
