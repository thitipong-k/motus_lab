import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/crm/domain/models/customer.dart';

/// หน้าจอจัดการรายชื่อลูกค้า (Customer List)
class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ข้อมูลลูกค้าจำลอง
    final List<Customer> _customers = [
      const Customer(
          id: "C001",
          name: "สมชาย รักรถ",
          phone: "081-222-3333",
          email: "somchai@email.com"),
      const Customer(
          id: "C002",
          name: "วิภา แซ่แต้",
          phone: "089-999-8888",
          email: "wipa@email.com"),
      const Customer(
          id: "C003",
          name: "John Doe",
          phone: "085-555-4444",
          email: "john@email.com"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("WORKSHOP CRM"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.black),
              ),
              title: Text(customer.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("📞 ${customer.phone}"),
              trailing: const Icon(Icons.history),
              onTap: () => _showJobHistory(context, customer),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // เพิ่มลูกค้ารายใหม่ (จะทำในอนาคต)
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  /// แสดงหน้าต่างประวัติการซ่อมของลูกค้าแต่ละราย
  void _showJobHistory(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ประวัติของ ${customer.name}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildHistoryItem("24/01/2026", "Honda Civic",
                        "DTC: P0101 - MAF Sensor", 1200),
                    const Divider(),
                    _buildHistoryItem("10/12/2025", "Honda Civic",
                        "Oil Reset & Brake Check", 800),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(
      String date, String car, String detail, double cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text("${cost.toStringAsFixed(0)} บาท",
                  style: const TextStyle(color: AppColors.primary)),
            ],
          ),
          Text(car, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(detail,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
