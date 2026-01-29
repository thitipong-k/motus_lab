import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:motus_lab/core/database/app_database.dart';
import 'package:motus_lab/core/database/tables/vehicle_profiles_table.dart';

/// Repository สำหรับจัดการข้อมูล Vehicle Profiles
/// ใช้สำหรับอ่าน/เขียนข้อมูล PIDs ที่รถแต่ละรุ่นรองรับ
class VehicleProfileRepository {
  final AppDatabase _db;

  VehicleProfileRepository(this._db);

  /// บันทึก Profile ใหม่หรืออัพเดตที่มีอยู่แล้ว
  Future<void> saveProfile({
    required String vin,
    required String protocol,
    required List<String> supportedPids,
    Map<String, String>? ecuMap,
  }) async {
    // ใช้ VIN Prefix 8-10 ตัวแรก
    final vinPrefix = vin.length >= 8 ? vin.substring(0, 8) : vin;

    final entry = VehicleProfilesCompanion(
      vinPrefix: Value(vinPrefix),
      protocol: Value(protocol),
      supportedPids: Value(jsonEncode(supportedPids)),
      ecuMap: Value(ecuMap != null ? jsonEncode(ecuMap) : null),
      lastUpdated: Value(DateTime.now()),
    );

    await _db.into(_db.vehicleProfiles).insertOnConflictUpdate(entry);
    print("Saved Vehicle Profile: $vinPrefix");
  }

  /// ค้นหา Profile จาก VIN
  /// Return: List of PID codes (ถ้ามี) หรือ null (ถ้าไม่เจอ)
  Future<List<String>?> getSupportedPids(String vin) async {
    if (vin.length < 8) return null;
    final vinPrefix = vin.substring(0, 8);

    final query = _db.select(_db.vehicleProfiles)
      ..where((tbl) => tbl.vinPrefix.equals(vinPrefix));

    final result = await query.getSingleOrNull();

    if (result != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(result.supportedPids);
        return jsonList.cast<String>();
      } catch (e) {
        print("Error decoding PIDs for $vinPrefix: $e");
        return null;
      }
    }
    return null;
  }
}
