import 'package:motus_lab/domain/entities/obd_communication.dart';

/// อินเตอร์เฟสการเชื่อมต่อ (Hardware Abstraction Layer - HAL)
/// ทำหน้าที่เป็น "สัญญากลาง" (Contract) เพื่อแยกส่วนงาน Hardware ออกจาก Logic ของแอป
/// ไม่ว่าจะเป็น Bluetooth, Serial, หรือ J2534 ทุกตัวต้องทำงานผ่าน Interface นี้เหมือนกัน
abstract class ConnectionInterface {
  /// ตรวจสอบว่าปัจจุบันมีการเชื่อมต่อกับตัวรถอยู่หรือไม่
  bool get isConnected;

  /// เชื่อมต่อไปยังตัวอุปกรณ์รับส่งข้อมูล (Adapter)
  /// [deviceId] - อาจเป็น Address, ชื่อพอร์ต, หรือ UUID ของอุปกรณ์
  Future<void> connect(String deviceId);

  /// ตัดการเชื่อมต่อและทำความสะอาด Resource
  Future<void> disconnect();

  /// ส่งคำสั่งไปยังตัวรถแบบมาตรฐาน (Standardized)
  /// รับค่าเป็น [ObdRequest] เพื่อรองรับคำสั่งที่ซับซ้อนในอนาคต
  /// คืนค่าเป็น [ObdResponse] ซึ่งมีข้อมูลดิบและสถานะการประมวลผลพร้อมใช้งาน
  Future<ObdResponse> send(ObdRequest request);

  /// ช่องทางรับข้อมูลดิบจากรถแบบ Real-time (Stream)
  /// ใช้สำหรับติดตามข้อมูลที่ไหลเข้าอย่างต่อเนื่อง (Monitoring)
  Stream<List<int>> get onDataReceived;
}
