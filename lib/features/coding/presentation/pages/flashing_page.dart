import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/coding/presentation/bloc/flashing_bloc.dart';
import 'package:motus_lab/core/protocol/security/security_access_handler.dart';

class FlashingPage extends StatefulWidget {
  const FlashingPage({super.key});

  @override
  State<FlashingPage> createState() => _FlashingPageState();
}

class _FlashingPageState extends State<FlashingPage> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin', 'sgo', 'odx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _startFlashing() async {
    if (_selectedFile == null) return;
    
    // Read file bytes
    final bytes = await _selectedFile!.readAsBytes();
    
    // Inject default security access (in reality, this would be based on vehicle profile)
    final securityHandler = GenericSecurityAccess(0x01, 0xABCD);

    if (mounted) {
      context.read<FlashingBloc>().add(StartFlashingEvent(bytes, securityHandler));
    }
  }

  void _cancelFlashing() {
    context.read<FlashingBloc>().add(CancelFlashingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ECU Flasher'),
        backgroundColor: AppColors.surface,
      ),
      body: BlocConsumer<FlashingBloc, FlashingState>(
        listener: (context, state) {
          if (state is FlashingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ECU Flashed Successfully!'), backgroundColor: AppColors.success),
            );
          } else if (state is FlashingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}'), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Warning Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    border: Border.all(color: AppColors.error, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 36),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "WARNING: Ensure stable power supply. Do not disconnect the VCI during flashing. Doing so may brick the ECU.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // File Selection
                Card(
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text("Firmware Binary File", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _selectedFile != null
                            ? Text("Selected: ${_selectedFile!.path.split(Platform.pathSeparator).last}", style: const TextStyle(color: AppColors.success))
                            : const Text("No file selected", style: TextStyle(color: Colors.white54)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: state is FlashingIdle || state is FlashingError || state is FlashingSuccess ? _pickFile : null,
                          icon: const Icon(Icons.file_upload),
                          label: const Text("Choose File (.bin / .sgo)"),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Flashing Status
                if (state is! FlashingIdle) ...[
                  const Text("Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatusIndicator(state),
                ],

                const Spacer(),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (state is! FlashingIdle && state is! FlashingSuccess && state is! FlashingError)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelFlashing,
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                          child: const Text("ABORT"),
                        ),
                      ),
                    if (state is! FlashingIdle && state is! FlashingSuccess && state is! FlashingError)
                      const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_selectedFile != null && (state is FlashingIdle || state is FlashingError || state is FlashingSuccess))
                            ? _startFlashing
                            : null,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text("START FLASH", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(FlashingState state) {
    if (state is FlashingUnlocking) {
      return _buildLoadingRow("Unlocking Security Access (0x27)...");
    } else if (state is FlashingErasing) {
      return _buildLoadingRow("Erasing ECU Memory (0xFF00)...");
    } else if (state is FlashingTransferring) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Transferring Data..."),
              Text("${(state.progress * 100).toStringAsFixed(0)}%"),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.progress,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
          ),
        ],
      );
    } else if (state is FlashingValidating) {
      return _buildLoadingRow("Validating Checksum (0xFF01)...");
    } else if (state is FlashingSuccess) {
      return const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: 12),
          Text("ECU Flashed Successfully", style: TextStyle(color: AppColors.success)),
        ],
      );
    } else if (state is FlashingError) {
      return Row(
        children: [
          const Icon(Icons.error, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(child: Text(state.message, style: const TextStyle(color: AppColors.error))),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingRow(String text) {
    return Row(
      children: [
        const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 16),
        Text(text),
      ],
    );
  }
}
