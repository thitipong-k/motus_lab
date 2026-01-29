import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:motus_lab/l10n/app_localizations.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:motus_lab/features/scan/presentation/widgets/radar_view.dart';

/// หน้าสำหรับค้นหาและเชื่อมต่ออุปกรณ์ Bluetooth (รองรับหลายภาษา: EN/TH)
class ConnectionPage extends StatelessWidget {
  const ConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.titleDeviceSelection,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: BlocBuilder<ScanBloc, ScanState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 20),
              // Radar Animation Section
              Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: state.status == ScanStatus.scanning
                      ? const RadarView()
                      : const Icon(Icons.bluetooth_disabled,
                          size: 100, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),

              // Status Message
              _buildStatusText(context, state),

              const SizedBox(height: 20),

              // Device List
              Expanded(
                child: state.results.isEmpty
                    ? Center(
                        child: Text(AppLocalizations.of(context)!.msgNoDevices))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final result = state.results[index];
                          final isConnecting =
                              state.status == ScanStatus.connecting &&
                                  state.connectedDeviceId ==
                                      result.device.remoteId.str;
                          final isConnected =
                              state.status == ScanStatus.connected &&
                                  state.connectedDeviceId ==
                                      result.device.remoteId.str;

                          return _buildDeviceTile(
                              context, result, isConnecting, isConnected);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<ScanBloc, ScanState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: state.status == ScanStatus.scanning
                ? () => context.read<ScanBloc>().add(StopScan())
                : () => context.read<ScanBloc>().add(StartScan()),
            backgroundColor: AppColors.primary,
            child: Icon(state.status == ScanStatus.scanning
                ? Icons.stop
                : Icons.refresh),
          );
        },
      ),
    );
  }

  Widget _buildStatusText(BuildContext context, ScanState state) {
    String text = AppLocalizations.of(context)!.msgTapToScan;
    if (state.status == ScanStatus.scanning)
      text = AppLocalizations.of(context)!.lblScanning;
    if (state.status == ScanStatus.connecting)
      text = AppLocalizations.of(context)!.lblConnecting;
    if (state.status == ScanStatus.connected)
      text = AppLocalizations.of(context)!.lblConnected;
    if (state.status == ScanStatus.error)
      text = AppLocalizations.of(context)!.lblError(state.errorMessage ?? "");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: state.status == ScanStatus.error ? AppColors.error : null,
            ),
      ),
    );
  }

  Widget _buildDeviceTile(BuildContext context, ScanResult result,
      bool isConnecting, bool isConnected) {
    String name = result.device.platformName;
    if (name.isEmpty) {
      name = result.advertisementData.advName;
    }
    if (name.isEmpty) {
      name = "Unknown Device";
    }
    final mac = result.device.remoteId.str;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.directions_car,
          color: isConnected ? AppColors.success : AppColors.primary,
          size: 32,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(mac),
        trailing: isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2))
            : ElevatedButton(
                onPressed: isConnected
                    ? null
                    : () {
                        context.read<ScanBloc>().add(ConnectToDevice(mac));
                      },
                child: Text(isConnected
                    ? AppLocalizations.of(context)!.btnConnected
                    : AppLocalizations.of(context)!.btnConnect),
              ),
      ),
    );
  }
}
