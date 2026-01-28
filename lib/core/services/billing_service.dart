import 'dart:async';

/// บริการจัดการด้านการชำระเงินและเครดิตภายในแอป
/// ใช้สำหรับควบคุมการเข้าถึงฟีเจอร์ระดับ Pro (Feature Locking)
class BillingService {
  int _credits = 500; // แต้มสะสมจำลอง

  int get credits => _credits;

  /// ตรวจสอบว่ามีเครดิตเพียงพอสำหรับฟีเจอร์ที่ระบุหรือไม่
  bool hasEnoughCredits(int cost) {
    return _credits >= cost;
  }

  /// หักเครดิตหลังจากใช้งานฟีเจอร์สำเร็จ
  Future<bool> deductCredits(int amount) async {
    if (!hasEnoughCredits(amount)) return false;

    // จำลองการเชื่อมต่อ Server เพื่อบันทึกยอด
    await Future.delayed(const Duration(seconds: 1));
    _credits -= amount;
    return true;
  }

  /// เติมเครดิต (จำลองการซื้อผ่าน In-App Purchase)
  Future<void> addCredits(int amount) async {
    await Future.delayed(const Duration(seconds: 2));
    _credits += amount;
  }
}
