/// โมเดลข้อมูลลูกค้าสำหรับระบบ CRM
class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });
}

/// โมเดลประวัติการซ่อม (Work Order)
class JobHistory {
  final String id;
  final String customerId;
  final String vehicleInfo; // เช่น "Toyota Camry 2022"
  final DateTime date;
  final String findings; // ผลการตรวจเช็ค
  final double totalCost;

  const JobHistory({
    required this.id,
    required this.customerId,
    required this.vehicleInfo,
    required this.date,
    required this.findings,
    required this.totalCost,
  });
}
