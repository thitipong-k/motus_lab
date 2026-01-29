import 'package:drift/drift.dart';

/// ตารางเก็บข้อมูลความสามารถของรถแต่ละรุ่น (Vehicle Profiles)
/// ใช้ VIN Prefix (8-10 ตัวแรก) เป็น Key ในการจำแนก
@DataClassName('VehicleProfile')
class VehicleProfiles extends Table {
  /// VIN Prefix (e.g. "JHMGD38") - ใช้เป็น Primary Key
  TextColumn get vinPrefix => text()();

  /// Protocol used (e.g. "ISO 15765-4 CAN 11/500")
  TextColumn get protocol => text()();

  /// JSON String เก็บรายการ PID Code ที่รองรับ (e.g. ["010C", "010D", ...])
  TextColumn get supportedPids => text()();

  /// JSON String เก็บ Map ของ ECU Header (Optional)
  TextColumn get ecuMap => text().nullable()();

  /// เวลาที่อัพเดตล่าสุด
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {vinPrefix};
}
