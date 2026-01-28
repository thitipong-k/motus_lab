/// โมเดลสำหรับขั้นตอนการทำงานของ Service Function
/// หนึ่งฟังก์ชัน (เช่น Oil Reset) อาจประกอบด้วยหลายขั้นตอนย่อย
class ServiceStep {
  final String title;
  final String description;
  final List<int> command; // คำสั่ง HEX ที่ต้องส่งไป ECU
  final Duration delay; // ระยะเวลารอหลังจากส่งคำสั่ง (ถ้ามี)

  const ServiceStep({
    required this.title,
    required this.description,
    required this.command,
    this.delay = Duration.zero,
  });
}

/// โมเดลหลักของฟังก์ชันงานบริการ
class ServiceFunction {
  final String id;
  final String name;
  final String iconName; // อ้างอิงชื่อไอคอน
  final List<ServiceStep> steps;

  const ServiceFunction({
    required this.id,
    required this.name,
    required this.iconName,
    required this.steps,
  });
}
