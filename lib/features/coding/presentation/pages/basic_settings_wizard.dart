import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/coding/presentation/bloc/basic_settings_bloc.dart';
import 'package:motus_lab/features/scan/presentation/widgets/sgw_unlock_dialog.dart';

class BasicSettingsWizard extends StatefulWidget {
  final String title;
  final String description;
  final int routineId;

  const BasicSettingsWizard({
    super.key,
    required this.title,
    required this.description,
    required this.routineId,
  });

  @override
  State<BasicSettingsWizard> createState() => _BasicSettingsWizardState();
}

class _BasicSettingsWizardState extends State<BasicSettingsWizard> {
  bool _engineOff = false;
  bool _ignitionOn = false;
  bool _batteryOk = false;

  bool get _preconditionsMet => _engineOff && _ignitionOn && _batteryOk;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BasicSettingsBloc, BasicSettingsState>(
      listener: (context, state) async {
        if (state is BasicSettingsSuccess) {
          // Add a small delay so user can read "Success" before closing
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.read<BasicSettingsBloc>().add(ResetBasicSettingsEvent());
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
              );
            }
          });
        } else if (state is BasicSettingsSgwLocked) {
          Navigator.of(context).pop(); // Close Wizard
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const SgwUnlockDialog(),
          );
          
          if (result == true && mounted) {
            context.read<BasicSettingsBloc>().add(ResetBasicSettingsEvent());
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("SGW Unlocked! You may now retry the routine."), backgroundColor: AppColors.success),
            );
          } else if (mounted) {
            context.read<BasicSettingsBloc>().add(ResetBasicSettingsEvent());
          }
        }
      },
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.description, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 24),
                
                if (state is BasicSettingsIdle || state is BasicSettingsError || state is BasicSettingsSgwLocked) ...[
                  if (state is BasicSettingsError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(state.message, style: const TextStyle(color: AppColors.error)),
                    ),
                  if (state is BasicSettingsSgwLocked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(state.message, style: const TextStyle(color: Colors.orangeAccent)),
                    ),
                  const Text("Preconditions", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text("Engine is OFF"),
                    value: _engineOff,
                    onChanged: (val) => setState(() => _engineOff = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text("Ignition is ON"),
                    value: _ignitionOn,
                    onChanged: (val) => setState(() => _ignitionOn = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text("Battery Voltage > 12.5V"),
                    value: _batteryOk,
                    onChanged: (val) => setState(() => _batteryOk = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.read<BasicSettingsBloc>().add(ResetBasicSettingsEvent());
                          Navigator.of(context).pop();
                        },
                        child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _preconditionsMet ? () {
                          context.read<BasicSettingsBloc>().add(StartRoutineEvent(widget.routineId));
                        } : null,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text("START ROUTINE"),
                      ),
                    ],
                  ),
                ] else if (state is BasicSettingsInProgress) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                  Center(child: Text(state.message)),
                ] else if (state is BasicSettingsSuccess) ...[
                  const Center(child: Icon(Icons.check_circle, color: AppColors.success, size: 64)),
                  const SizedBox(height: 16),
                  const Center(child: Text("Calibration Successful!", style: TextStyle(color: AppColors.success, fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<BasicSettingsBloc>().add(ResetBasicSettingsEvent());
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text("CLOSE"),
                    ),
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
