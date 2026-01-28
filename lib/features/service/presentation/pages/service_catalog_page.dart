import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/service/domain/models/service_step.dart';

/// หน้าแสดงรายการงานบริการ (Service Functions)
/// เช่น การรีเซ็ตไฟน้ำมันเครื่อง หรือการเปลี่ยนผ้าเบรกไฟฟ้า
class ServiceCatalogPage extends StatelessWidget {
  const ServiceCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // รายการฟังก์ชันจำลอง
    final List<ServiceFunction> _services = [
      const ServiceFunction(
        id: "oil_reset",
        name: "OIL RESET",
        iconName: "oil_barrel",
        steps: [
          ServiceStep(
              title: "Security Access",
              description: "ขอสิทธิ์เข้าถึง ECU",
              command: [0x27, 0x01]),
          ServiceStep(
              title: "Reset Interval",
              description: "ล้างค่าระยะการเปลี่ยนถ่าย",
              command: [0x2E, 0xF1, 0x25]),
        ],
      ),
      const ServiceFunction(
        id: "epb_service",
        name: "EPB SERVICE",
        iconName: "brake_pads",
        steps: [],
      ),
      const ServiceFunction(
        id: "battery_reg",
        name: "BATTERY REG",
        iconName: "battery_charging",
        steps: [],
      ),
      const ServiceFunction(
        id: "sas_reset",
        name: "SAS RESET",
        iconName: "steering",
        steps: [],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("SERVICE FUNCTIONS"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return _buildServiceCard(context, service);
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceFunction service) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      child: InkWell(
        onTap: () => _showServiceExecutionDialog(context, service),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings_suggest,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              service.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// แสดงหน้าต่างยืนยันการรันลำดับคำสั่งบริการ
  void _showServiceExecutionDialog(
      BuildContext context, ServiceFunction service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("เริ่มขั้นตอน ${service.name}"),
        content: Text(
            "ระบบจะส่งชุดคำสั่ง ${service.steps.length} ขั้นตอนไปยังรถของคุณ ยืนยันหรือไม่?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ยกเลิก")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // ในระบบจริงจะส่งเข้า ServiceSequenceBloc
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("กำลังรัน ${service.name}..."),
                    backgroundColor: AppColors.primary),
              );
            },
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }
}
