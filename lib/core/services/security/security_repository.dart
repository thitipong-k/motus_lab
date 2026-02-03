import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motus_lab/core/utils/logger.dart';

/// ===================================================================
/// SecurityRepository - ระบบจัดการความปลอดภัยและกุญแจเข้ารหัส
/// ===================================================================
/// ทำหน้าที่เก็บรักษา Key สำหรับเข้ารหัสฐานข้อมูลและข้อมูลสำคัญอื่นๆ
/// โดยมีการทำงานหลักดังนี้:
/// 1. ตรวจสอบว่ามี Key เดิมอยู่ไหม
/// 2. หากไม่มี จะทำการสุ่มสร้าง Key ใหม่ที่ปลอดภัยที่สุด (32 bytes)
/// 3. เก็บ Key ไว้ใน SharedPreferences (สำหรับ Windows) หรือ Secure Storage
/// ===================================================================
class SecurityRepository {
  final SharedPreferences _prefs;
  static const String _dbKeyName = 'motus_db_encryption_key';

  SecurityRepository({required SharedPreferences prefs}) : _prefs = prefs;

  /// ดึง Key สำหรับเข้ารหัสฐานข้อมูล
  /// หากเป็นครั้งแรกที่เปิดแอป จะทำการสร้าง Key ใหม่และเก็บไว้ทันที
  Future<String> getDatabaseKey() async {
    try {
      // 1. ลองอ่านค่าเดิมจากหน่วยความจำ
      String? key = _prefs.getString(_dbKeyName);

      if (key == null) {
        // 2. หากไม่พบ (รันครั้งแรก) ให้สร้าง Key ใหม่
        Logger.info(
            "SecurityRepository: ไม่พบเซสชันความปลอดภัยเดิม กำลังสร้าง Key ใหม่...");
        key = _generateSecureKey();

        // 3. บันทึกเก็บไว้เพื่อใช้ในครั้งต่อไป
        await _prefs.setString(_dbKeyName, key);
      }

      return key;
    } catch (e) {
      Logger.error(
          "SecurityRepository: เกิดข้อผิดพลาดในการจัดการระบบความปลอดภัย", e);
      // แผนสำรองกรณีฉุกเฉิน (เพื่อให้แอปยังรันได้)
      return "motus_fallback_secure_key_32_chars_!!";
    }
  }

  /// ฟังก์ชันสุ่มสร้าง Key ขนาด 32 Bytes (256-bit)
  /// ใช้ Random.secure() เพื่อความปลอดภัยระดับที่ใช้ในการเข้ารหัสข้อมูล
  String _generateSecureKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// ล้างข้อมูล Key ทั้งหมดออกจากเครื่อง
  /// (ใช้ในกรณีที่ต้องการล้างเครื่องใหม่ หรือ Reset ระบบ)
  Future<void> clearAllKeys() async {
    await _prefs.remove(_dbKeyName);
    Logger.warning(
        "SecurityRepository: กุญแจเข้ารหัสทั้งหมดถูกลบออกจากเครื่องแล้ว");
  }
}
