import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/features/crm/domain/entities/customer.dart';
import 'package:motus_lab/features/crm/presentation/bloc/crm_bloc.dart';
import 'package:motus_lab/core/widgets/motus_button.dart';

class CustomerFormDialog extends StatefulWidget {
  final Customer? customer; // If provided, edit mode

  const CustomerFormDialog({super.key, this.customer});

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone ?? '';
      _emailController.text = widget.customer!.email ?? '';
      _addressController.text = widget.customer!.address ?? '';
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // [WORKFLOW] CRM: สร้าง Object Customer ใหม่จากข้อมูลในฟอร์ม
      final customer = Customer(
        id: widget.customer?.id ?? 0, // 0 for new
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        address:
            _addressController.text.isEmpty ? null : _addressController.text,
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
      );

      // [WORKFLOW] CRM: เรียกใช้ CrmBloc เพื่อเพิ่มหรือแก้ไขข้อมูลลูกค้า
      final bloc = context.read<CrmBloc>();
      if (widget.customer == null) {
        bloc.add(AddCustomer(customer));
      } else {
        bloc.add(UpdateCustomer(customer));
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.customer == null ? "New Customer" : "Edit Customer"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name *"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address"),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        MotusButton(
          label: "Save",
          onPressed: _save,
        ),
      ],
    );
  }
}
