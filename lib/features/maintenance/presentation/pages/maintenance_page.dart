import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/maintenance/presentation/bloc/maintenance_bloc.dart';
import 'package:intl/intl.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<MaintenanceBloc>()..add(LoadReminders()),
      child: const _MaintenanceView(),
    );
  }
}

class _MaintenanceView extends StatelessWidget {
  const _MaintenanceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SERVICE REMINDERS"),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_maintenance",
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<MaintenanceBloc, MaintenanceState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.build_circle_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("No maintenance reminders yet.",
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  const Text("Tap + to add a new service task."),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.reminders.length,
            itemBuilder: (context, index) {
              final item = state.reminders[index];
              return Card(
                color: item.isCompleted
                    ? Colors.green.withOpacity(0.1)
                    : AppColors.surface,
                child: ListTile(
                  leading: Checkbox(
                    value: item.isCompleted,
                    onChanged: (val) {
                      context
                          .read<MaintenanceBloc>()
                          .add(ToggleReminderComplete(item.id, val ?? false));
                    },
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      decoration:
                          item.isCompleted ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.dueMileage != null)
                        Text("Due: ${item.dueMileage} km"),
                      if (item.dueDate != null)
                        Text(
                            "Date: ${DateFormat('dd/MM/yyyy').format(item.dueDate!)}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      context
                          .read<MaintenanceBloc>()
                          .add(DeleteReminderEvent(item.id));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final mileageController = TextEditingController();
    // Simple logic for now
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Reminder"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Service Name"),
            ),
            TextField(
              controller: mileageController,
              decoration: const InputDecoration(labelText: "Due Mileage (km)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final mileage = int.tryParse(mileageController.text);
                context.read<MaintenanceBloc>().add(AddReminderEvent(
                      title: titleController.text,
                      mileage: mileage,
                    ));
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
