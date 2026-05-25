import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/shared/widgets/empty_state.dart';
import 'package:motus_lab/shared/widgets/motus_button.dart';
import 'package:motus_lab/shared/widgets/motus_card.dart';
import 'package:motus_lab/shared/widgets/motus_snackbar.dart';
import 'package:motus_lab/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:motus_lab/features/scan/presentation/widgets/radar_view.dart';
import 'dart:io';
import 'package:motus_lab/l10n/app_localizations.dart';
import 'package:motus_lab/core/connection/j2534/j2534_scanner_service.dart';
import 'package:motus_lab/core/connection/doip/doip_profiles.dart';

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
                    ? EmptyState(
                        message: AppLocalizations.of(context)!.msgNoDevices,
                        icon: Icons.bluetooth_searching,
                      )
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: MotusButton(
                  onPressed: () {
                    // Directly connect to Mock Device
                    context
                        .read<ScanBloc>()
                        .add(const ConnectToDevice("MOCK-001"));

                    MotusSnackbar.showWarning(
                        context, "Entering Simulation Mode...");
                  },
                  icon: Icons.gamepad,
                  label: "ENTER DEMO MODE",
                  type: ButtonType.warning,
                ),
              ),
              if (Platform.isWindows) ...[
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                   child: Align(
                     alignment: Alignment.centerLeft,
                     child: Text("Advanced Desktop Connections", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                   child: MotusCard(
                     child: ListTile(
                       leading: const Icon(Icons.lan, color: AppColors.primary),
                       title: const Text("DoIP / ENET Cable"),
                       subtitle: const Text("Connect to modern vehicle via TCP/IP"),
                       trailing: ElevatedButton(
                         onPressed: () {
                           showModalBottomSheet(
                             context: context,
                             backgroundColor: AppColors.background,
                             shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                             builder: (context) {
                               return Padding(
                                 padding: const EdgeInsets.all(16.0),
                                 child: Column(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     const Text("Select ENET / DoIP Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                     const SizedBox(height: 16),
                                     ...doipProfiles.map((profile) => ListTile(
                                       leading: const Icon(Icons.router, color: AppColors.primary),
                                       title: Text(profile.name),
                                       subtitle: Text(profile.description),
                                       onTap: () {
                                         Navigator.pop(context);
                                         final ip = profile.ipAddress ?? "auto";
                                         context.read<ScanBloc>().add(ConnectToDevice("DOIP:$ip"));
                                         MotusSnackbar.showSuccess(context, "Initiating DoIP connection for ${profile.name}...");
                                       },
                                     )).toList(),
                                   ],
                                 ),
                               );
                             }
                           );
                         },
                         child: const Text("Profiles")
                       ),
                     )
                   )
                 ),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                   child: MotusCard(
                     child: ListTile(
                       leading: const Icon(Icons.usb, color: AppColors.primary),
                       title: const Text("J2534 PassThru Devices"),
                       subtitle: const Text("Scan Registry for VCI drivers"),
                       trailing: ElevatedButton(
                         onPressed: () async {
                           MotusSnackbar.showWarning(context, "Scanning HKLM\\Software\\PassThruSupport.04.04...");
                           final devices = await J2534ScannerService.scanDevices();
                           if (devices.isEmpty && context.mounted) {
                             MotusSnackbar.showError(context, "No J2534 devices found in Registry.");
                           } else if (context.mounted) {
                             MotusSnackbar.showSuccess(context, "Found ${devices.length} J2534 drivers!");
                             // Select the first one for demo
                             context.read<ScanBloc>().add(ConnectToDevice("J2534:${devices.first.name}"));
                           }
                         },
                         child: const Text("Scan & Connect")
                       ),
                     )
                   )
                 ),
              ],
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
            heroTag: "fab_connection",
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

    return MotusCard(
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
            : ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: ElevatedButton(
                  onPressed: isConnected
                      ? null
                      : () {
                          context.read<ScanBloc>().add(ConnectToDevice(mac));
                        },
                  child: Text(
                    isConnected
                        ? AppLocalizations.of(context)!.btnConnected
                        : AppLocalizations.of(context)!.btnConnect,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
      ),
    );
  }
}
