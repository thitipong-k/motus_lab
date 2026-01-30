import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/features/maintenance/domain/entities/service_reminder.dart';
import 'package:motus_lab/features/maintenance/domain/repositories/maintenance_repository.dart';

// --- Events ---
abstract class MaintenanceEvent extends Equatable {
  const MaintenanceEvent();

  @override
  List<Object> get props => [];
}

class LoadReminders extends MaintenanceEvent {}

class AddReminderEvent extends MaintenanceEvent {
  final String title;
  final int? mileage;
  final DateTime? date;

  const AddReminderEvent({required this.title, this.mileage, this.date});
}

class ToggleReminderComplete extends MaintenanceEvent {
  final int id;
  final bool isCompleted;

  const ToggleReminderComplete(this.id, this.isCompleted);
}

class DeleteReminderEvent extends MaintenanceEvent {
  final int id;

  const DeleteReminderEvent(this.id);
}

class _RemindersUpdated extends MaintenanceEvent {
  final List<ServiceReminder> reminders;

  const _RemindersUpdated(this.reminders);
}

// --- State ---
class MaintenanceState extends Equatable {
  final List<ServiceReminder> reminders;
  final bool isLoading;

  const MaintenanceState({this.reminders = const [], this.isLoading = false});

  @override
  List<Object> get props => [reminders, isLoading];
}

// --- Bloc ---
class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  final MaintenanceRepository _repository;

  MaintenanceBloc(this._repository)
      : super(const MaintenanceState(isLoading: true)) {
    on<LoadReminders>(_onLoadReminders);
    on<_RemindersUpdated>(_onRemindersUpdated);
    on<AddReminderEvent>(_onAddReminder);
    on<ToggleReminderComplete>(_onToggleComplete);
    on<DeleteReminderEvent>(_onDeleteReminder);
  }

  Future<void> _onLoadReminders(
      LoadReminders event, Emitter<MaintenanceState> emit) async {
    emit(const MaintenanceState(isLoading: true));
    await emit.forEach(
      _repository.watchReminders(),
      onData: (List<ServiceReminder> data) =>
          MaintenanceState(reminders: data, isLoading: false),
    );
  }

  void _onRemindersUpdated(
      _RemindersUpdated event, Emitter<MaintenanceState> emit) {
    emit(MaintenanceState(reminders: event.reminders, isLoading: false));
  }

  Future<void> _onAddReminder(
      AddReminderEvent event, Emitter<MaintenanceState> emit) async {
    await _repository.addReminder(event.title,
        mileage: event.mileage, date: event.date);
  }

  Future<void> _onToggleComplete(
      ToggleReminderComplete event, Emitter<MaintenanceState> emit) async {
    await _repository.completeReminder(event.id, event.isCompleted);
  }

  Future<void> _onDeleteReminder(
      DeleteReminderEvent event, Emitter<MaintenanceState> emit) async {
    await _repository.deleteReminder(event.id);
  }
}
