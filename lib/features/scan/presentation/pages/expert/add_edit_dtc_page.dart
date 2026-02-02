import 'package:flutter/material.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/scan/data/repositories/diagnostic_repository.dart';

class AddEditDtcPage extends StatefulWidget {
  final String? existingCode;
  const AddEditDtcPage({super.key, this.existingCode});

  @override
  State<AddEditDtcPage> createState() => _AddEditDtcPageState();
}

class _AddEditDtcPageState extends State<AddEditDtcPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _stepsController = TextEditingController();
  final _modelController = TextEditingController();

  final _repository = locator<DiagnosticRepository>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingCode != null) {
      _codeController.text = widget.existingCode!;
      // TODO: Load existing data if editing
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final steps = _stepsController.text
          .split("\n")
          .where((s) => s.trim().isNotEmpty)
          .toList();

      await _repository.upsertDtcKnowledge(
        code: _codeController.text.trim().toUpperCase(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        steps: steps,
        vehicleModel: _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("บันทึกข้อมูลแนวทางการซ่อมสำเร็จ")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text(widget.existingCode == null
            ? "เพิ่มข้อมูล DTC"
            : "แก้ไขข้อมูล DTC"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _codeController,
                      label: "รหัส DTC (เช่น P0420)",
                      hint: "กรอกรหัสข้อผิดพลาด",
                      validator: (v) => v!.isEmpty ? "กรุณากรอกรหัส" : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _titleController,
                      label: "หัวข้อปัญหา (Title)",
                      hint: "เช่น เครื่องฟอกไอเสียเสื่อมสภาพ",
                      validator: (v) => v!.isEmpty ? "กรุณากรอกหัวข้อ" : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _modelController,
                      label:
                          "รุ่นรถ (Vehicle Model - เว้นว่างได้ถ้าใช้ได้ทุกรุ่น)",
                      hint: "เช่น Toyota Hilux Revo",
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _descController,
                      label: "คำอธิบายอาการ (Description)",
                      hint: "ระบุอาการของรถเมื่อพบรหัสนี้",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _stepsController,
                      label: "ขั้นตอนการแก้ไข (แยกบรรทัดละ 1 ขั้นตอน)",
                      hint: "1. ตรวจสอบ...\n2. เปลี่ยน...",
                      maxLines: 6,
                      validator: (v) =>
                          v!.isEmpty ? "กรุณากรอกขั้นตอนการซ่อม" : null,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("บันทึกข้อมูล",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
