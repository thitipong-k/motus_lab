import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:motus_lab/domain/entities/shop_profile.dart';
import 'package:motus_lab/domain/repositories/shop_profile_repository.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

class ShopBrandingForm extends StatefulWidget {
  const ShopBrandingForm({super.key});

  @override
  State<ShopBrandingForm> createState() => _ShopBrandingFormState();
}

class _ShopBrandingFormState extends State<ShopBrandingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _taxIdController = TextEditingController();

  bool _isLoading = true;
  bool _isReadOnly = true;
  ShopProfile? _currentProfile;
  String? _selectedLogoPath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = locator<ShopProfileRepository>();
    final profile = await repo.getShopProfile();
    setState(() {
      _currentProfile = profile;
      _nameController.text = profile.name;
      _addressController.text = profile.address ?? '';
      _phoneController.text = profile.phone ?? '';
      _emailController.text = profile.email ?? '';
      _taxIdController.text = profile.taxId ?? '';
      _selectedLogoPath = profile.logoPath;
      _isLoading = false;
    });
  }

  Future<void> _pickLogo() async {
    if (_isReadOnly) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedLogoPath = result.files.single.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final repo = locator<ShopProfileRepository>();
      final updatedProfile = ShopProfile(
        id: _currentProfile?.id,
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        taxId: _taxIdController.text,
        logoPath: _selectedLogoPath,
      );

      await repo.updateShopProfile(updatedProfile);
      await _loadProfile();

      setState(() {
        _isReadOnly = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Shop Profile Updated'),
              backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          Row(
            children: [
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _isReadOnly
                            ? Colors.grey[300]!
                            : Colors.grey[400]!),
                  ),
                  child: _selectedLogoPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_selectedLogoPath!),
                              fit: BoxFit.cover,
                              color: _isReadOnly
                                  ? Colors.white.withOpacity(0.7)
                                  : null,
                              colorBlendMode:
                                  _isReadOnly ? BlendMode.lighten : null),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                color: _isReadOnly
                                    ? Colors.grey[400]
                                    : Colors.grey),
                            Text('Logo',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _isReadOnly
                                        ? Colors.grey[400]
                                        : Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _isReadOnly
                      ? "Workshop branding information. Click 'Edit' to make changes."
                      : "Upload your shop logo and fill in the details. These will appear in the PDF report header.",
                  style: TextStyle(
                      fontSize: 13,
                      color: _isReadOnly ? Colors.grey : Colors.blueGrey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildField("Workshop Name *", _nameController,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
          _buildField("Address", _addressController, maxLines: 2),
          Row(
            children: [
              Expanded(child: _buildField("Phone", _phoneController)),
              const SizedBox(width: 12),
              Expanded(child: _buildField("Email", _emailController)),
            ],
          ),
          _buildField("Tax ID / Business ID", _taxIdController),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_isReadOnly) {
                  setState(() => _isReadOnly = false);
                } else {
                  _saveProfile();
                }
              },
              icon: Icon(_isReadOnly ? Icons.edit : Icons.save),
              label: Text(_isReadOnly ? 'EDIT BRANDING' : 'SAVE BRANDING'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isReadOnly ? null : AppColors.primary,
                foregroundColor: _isReadOnly ? null : Colors.white,
              ),
            ),
          ),
          if (!_isReadOnly)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton(
                onPressed: () {
                  _loadProfile();
                  setState(() => _isReadOnly = true);
                },
                child: const Center(child: Text("CANCEL")),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {String? Function(String?)? validator, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: _isReadOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: _isReadOnly ? Colors.grey : AppColors.primary,
            fontSize: 14,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: _isReadOnly ? Colors.grey[300]! : AppColors.primary,
                width: _isReadOnly ? 0.5 : 1.0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2.0),
          ),
          filled: _isReadOnly,
          fillColor: _isReadOnly ? Colors.grey[50]?.withOpacity(0.5) : null,
        ),
        style: TextStyle(
          color: _isReadOnly ? Colors.grey[700] : Colors.black,
          fontSize: 15,
        ),
        validator: validator,
      ),
    );
  }
}
