import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/coding/presentation/bloc/actuation_bloc.dart';
import 'package:motus_lab/features/coding/presentation/pages/basic_settings_wizard.dart';

class AdaptationPage extends StatefulWidget {
  const AdaptationPage({super.key});

  @override
  State<AdaptationPage> createState() => _AdaptationPageState();
}

class _AdaptationPageState extends State<AdaptationPage> {
  bool _drlEnabled = true;
  bool _autoLock = false;
  double _idleRpmAdjustment = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("CODING & ACTUATION"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "CODING"),
              Tab(text: "ACTIVE TESTS"),
              Tab(text: "BASIC SETTINGS"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCodingTab(),
            _buildActiveTestsTab(),
            _buildBasicSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCodingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Bitwise Toggles",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text("Daytime Running Lights (DRL)"),
                subtitle: const Text("Enable or disable LED DRLs"),
                value: _drlEnabled,
                onChanged: (val) => setState(() => _drlEnabled = val),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text("Automatic Door Lock"),
                subtitle: const Text("Lock doors when speed > 20km/h"),
                value: _autoLock,
                onChanged: (val) => setState(() => _autoLock = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text("Parameter Adjustment",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Idle RPM Offset: ${_idleRpmAdjustment.toStringAsFixed(0)} RPM"),
                Slider(
                  value: _idleRpmAdjustment,
                  min: -500,
                  max: 500,
                  divisions: 10,
                  label: _idleRpmAdjustment.round().toString(),
                  onChanged: (val) => setState(() => _idleRpmAdjustment = val),
                ),
                const Text(
                  "Note: Adjusting idle RPM may affect emissions and engine stability.",
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => _showWriteWarning(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text("WRITE TO ECU", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildActiveTestsTab() {
    return BlocConsumer<ActuationBloc, ActuationState>(
      listener: (context, state) {
        if (state is ActuationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
          );
        } else if (state is ActuationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}'), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is ActuationInProgress;
        int activeDid = (state is ActuationInProgress) ? state.did : ((state is ActuationSuccess) ? state.did : -1);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                border: Border.all(color: AppColors.secondary, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.secondary, size: 36),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Bi-Directional Control: Engine must be OFF and Ignition ON to perform these tests.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildActuationCard(
              context,
              title: "Cooling Fan High Speed",
              did: 0x011A,
              isActive: activeDid == 0x011A && state is ActuationSuccess,
              isLoading: isLoading && activeDid == 0x011A,
              globalLoading: isLoading,
            ),
            const SizedBox(height: 16),
            _buildActuationCard(
              context,
              title: "Fuel Pump Relay",
              did: 0x011B,
              isActive: activeDid == 0x011B && state is ActuationSuccess,
              isLoading: isLoading && activeDid == 0x011B,
              globalLoading: isLoading,
            ),
            const SizedBox(height: 16),
            _buildActuationCard(
              context,
              title: "A/C Compressor Clutch",
              did: 0x011C,
              isActive: activeDid == 0x011C && state is ActuationSuccess,
              isLoading: isLoading && activeDid == 0x011C,
              globalLoading: isLoading,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActuationCard(BuildContext context, {
    required String title,
    required int did,
    required bool isActive,
    required bool isLoading,
    required bool globalLoading,
  }) {
    return Card(
      color: isActive ? AppColors.success.withOpacity(0.2) : AppColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isActive ? AppColors.success : Colors.transparent, width: 2),
        borderRadius: BorderRadius.circular(12)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("DID: 0x${did.toRadixString(16).padLeft(4, '0').toUpperCase()}"),
        trailing: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : ElevatedButton(
                onPressed: globalLoading && !isActive ? null : () {
                  if (isActive) {
                    context.read<ActuationBloc>().add(StopActuationEvent(did));
                  } else {
                    context.read<ActuationBloc>().add(StartActuationEvent(did, const [0x01]));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? AppColors.error : AppColors.primary,
                ),
                child: Text(isActive ? "STOP" : "START"),
              ),
      ),
    );
  }

  void _showWriteWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("CONFIRM WRITE"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to write these changes?"),
            SizedBox(height: 16),
            Text("✅ Engine OFF", style: TextStyle(color: Colors.green)),
            Text("✅ Ignition ON", style: TextStyle(color: Colors.green)),
            Text("✅ Battery > 12.5V", style: TextStyle(color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Changes written successfully!"),
                    backgroundColor: AppColors.success),
              );
            },
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Common Service Routines", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        _buildServiceRoutineCard(
          context,
          title: "Throttle Body Alignment (TBA)",
          description: "Calibrate the electronic throttle body after cleaning or replacement.",
          routineId: 0x011A,
          icon: Icons.speed,
        ),
        const SizedBox(height: 16),
        _buildServiceRoutineCard(
          context,
          title: "Battery Registration",
          description: "Register a new battery replacement to reset the charging profile.",
          routineId: 0x0211,
          icon: Icons.battery_charging_full,
        ),
        const SizedBox(height: 16),
        _buildServiceRoutineCard(
          context,
          title: "Steering Angle Sensor (SAS)",
          description: "Calibrate the steering angle sensor after suspension work.",
          routineId: 0x0322,
          icon: Icons.directions_car,
        ),
        const SizedBox(height: 24),
        const Text("Modern & EV Service Routines", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.secondary)),
        const SizedBox(height: 16),
        _buildServiceRoutineCard(
          context,
          title: "EPB Service Mode",
          description: "Retract electronic parking brake calipers for pad replacement.",
          routineId: 0x0311,
          icon: Icons.back_hand,
        ),
        const SizedBox(height: 16),
        _buildServiceRoutineCard(
          context,
          title: "EV Coolant Bleeding",
          description: "Run automated bleeding routine for high-voltage battery coolant.",
          routineId: 0x0511,
          icon: Icons.water_drop,
        ),
        const SizedBox(height: 16),
        _buildServiceRoutineCard(
          context,
          title: "DPF / GPF Regeneration",
          description: "Force static regeneration of the particulate filter.",
          routineId: 0x0611,
          icon: Icons.cloud_off,
        ),
        const SizedBox(height: 16),
        _buildServiceRoutineCard(
          context,
          title: "Transmission Adaptive Reset",
          description: "Clear AT/CVT/DCT learning values after fluid or clutch replacement.",
          routineId: 0x0711,
          icon: Icons.settings_input_component,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildServiceRoutineCard(BuildContext context, {
    required String title,
    required String description,
    required int routineId,
    required IconData icon,
  }) {
    return Card(
      color: AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(description),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => BasicSettingsWizard(
              title: title,
              description: description,
              routineId: routineId,
            ),
          );
        },
      ),
    );
  }
}
