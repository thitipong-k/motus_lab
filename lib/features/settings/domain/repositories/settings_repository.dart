import 'package:motus_lab/features/settings/domain/entities/settings.dart';

/// Interface สำหรับการจัดการข้อมูลการตั้งค่า
/// ช่วยให้ Domain Layer ไม่ต้องรู้ว่าเก็บข้อมูลที่ไหน (SharedPrefs, DB, Cloud)
abstract class SettingsRepository {
  /// ดึงค่าตั้งค่าปัจจุบัน
  Future<Settings> getSettings();

  /// บันทึกค่าตั้งค่าใหม่
  Future<void> saveSettings(Settings settings);
}
