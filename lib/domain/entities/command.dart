import 'package:equatable/equatable.dart';

/// ระดับความสำคัญของคำสั่ง (ใช้สำหรับ Dynamic Polling)
enum CommandPriority {
  high, // อ่านถี่มาก (e.g. RPM, Speed) - ทุก 50ms
  normal, // อ่านปกติ (e.g. Load, MAF) - ทุก 500ms
  low, // อ่านนานๆ ที (e.g. Coolant, Temp) - ทุก 2000ms
}

/// คำสั่ง (Command) สำหรับส่งไปยัง ECU
/// เป็น Entitiy หลักที่ใช้ระบุงานที่ต้องการทำ เช่น "อ่านรอบเครื่อง", "อ่าน VIN"
class Command extends Equatable {
  /// ชื่อคำสั่ง (เช่น "Engine RPM")
  final String name;

  /// รหัส PID หรือ Service ID (เช่น "010C")
  final String code;

  /// คำอธิบายเพิ่มเติม
  final String description;

  /// หน่วยวัด (เช่น "rpm", "km/h")
  final String unit;

  /// สูตรคำนวณ (เช่น "A*256+B / 4")
  final String formula;

  /// ค่าต่ำสุดที่คาดหวัง (สำหรับ Gauge)
  final double min;

  /// ค่าสูงสุดที่คาดหวัง (สำหรับ Gauge)
  final double max;

  /// ระดับความสำคัญ (Default: normal)
  final CommandPriority priority;

  const Command({
    required this.name,
    required this.code,
    required this.description,
    this.unit = '',
    this.formula = '',
    this.min = 0.0,
    this.max = 100.0,
    this.priority = CommandPriority.normal,
  });

  @override
  List<Object?> get props =>
      [name, code, description, unit, formula, min, max, priority];
}
