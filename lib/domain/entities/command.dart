
import 'package:equatable/equatable.dart';

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

  const Command({
    required this.name,
    required this.code,
    required this.description,
    this.unit = '',
    this.formula = '',
  });

  @override
  List<Object?> get props => [name, code, description, unit, formula];
}
