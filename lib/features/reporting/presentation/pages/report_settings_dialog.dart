import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    final config = context.read<ReportBloc>().state.config;
    _nameController = TextEditingController(text: config?.shopName ?? '');
    _addressController = TextEditingController(text: config?.address ?? '');
    _phoneController = TextEditingController(text: config?.phone ?? '');
    _taxOrLineController = TextEditingController(text: config?.taxId ?? '');

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state.config != null && _nameController.text.isEmpty) {
          _nameController.text = state.config!.shopName;
          _addressController.text = state.config!.address;
          _phoneController.text = state.config!.phone;
          _taxOrLineController.text = state.config!.taxId ?? '';
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Shop Settings', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("Shop Name", _nameController),
                _buildTextField("Address", _addressController, maxLines: 2),
                _buildTextField("Phone", _phoneController),
                _buildTextField("Tax ID / Line ID", _taxOrLineController),
              ],
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
      );
      context.read<ReportBloc>().add(UpdateReportConfig(config));
      Navigator.pop(context);
    }
  }
}
