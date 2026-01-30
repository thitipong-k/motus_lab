import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/core/widgets/motus_button.dart';
import 'package:motus_lab/features/reporting/domain/entities/report_entities.dart';
import 'package:motus_lab/features/reporting/presentation/bloc/report_bloc.dart';

class ReportSettingsDialog extends StatefulWidget {
  const ReportSettingsDialog({super.key});

  @override
  State<ReportSettingsDialog> createState() => _ReportSettingsDialogState();
}

class _ReportSettingsDialogState extends State<ReportSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController
      _taxOrLineController; // Using TaxID field for Line/Tax
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    final config = context.read<ReportBloc>().state.config;
    _nameController = TextEditingController(text: config?.shopName ?? '');
    _addressController = TextEditingController(text: config?.address ?? '');
    _phoneController = TextEditingController(text: config?.phone ?? '');
    _taxOrLineController = TextEditingController(text: config?.taxId ?? '');
    _logoPath = config?.logoPath;

    // Load if empty
    if (config == null) {
      context.read<ReportBloc>().add(LoadReportConfig());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _taxOrLineController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb, // Crucial for Web persistence
    );

    if (result != null) {
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes != null) {
          // Convert to Data URI (Base64) for persistence on Web
          final base64String = base64Encode(bytes);
          setState(() {
            _logoPath = 'data:image/png;base64,$base64String';
          });
        }
      } else if (result.files.single.path != null) {
        setState(() {
          _logoPath = result.files.single.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state.config != null && _nameController.text.isEmpty) {
          _nameController.text = state.config!.shopName;
          _addressController.text = state.config!.address;
          _phoneController.text = state.config!.phone;
          _taxOrLineController.text = state.config!.taxId ?? '';
          _logoPath ??= state.config!.logoPath;
          setState(() {});
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Shop Settings', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Picker UI
                  _buildLogoPicker(),
                  const SizedBox(height: 16),
                  _buildTextField("Shop Name", _nameController),
                  _buildTextField("Address", _addressController, maxLines: 2),
                  _buildTextField("Phone", _phoneController),
                  _buildTextField("Tax ID / Line ID", _taxOrLineController),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          MotusButton(
            label: 'Save',
            icon: Icons.save,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPicker() {
    return Column(
      children: [
        const Text("Shop Logo",
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickLogo,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: _logoPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImage(_logoPath!),
                  )
                : const Icon(Icons.add_photo_alternate,
                    color: Colors.grey, size: 40),
          ),
        ),
        if (_logoPath != null)
          TextButton(
            onPressed: () => setState(() => _logoPath = null),
            child: const Text("Remove Logo",
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('data:image')) {
      final base64Data = path.split(',').last;
      return Image.memory(
        base64Decode(base64Data),
        fit: BoxFit.contain, // Corrected from pw.BoxFit
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.red),
      );
    }

    if (kIsWeb) {
      return const Icon(Icons.broken_image, color: Colors.orange);
    }

    // Desktop/Mobile File
    final file = File(path);
    if (!file.existsSync()) {
      return const Icon(Icons.image_not_supported, color: Colors.grey);
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, color: Colors.red),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final config = ReportConfig(
        shopName: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        taxId: _taxOrLineController.text,
        logoPath: _logoPath,
      );
      context.read<ReportBloc>().add(UpdateReportConfig(config));
      Navigator.pop(context);
    }
  }
}
