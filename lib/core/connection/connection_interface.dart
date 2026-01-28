/// อินเตอร์เฟสการเชื่อมต่อ (Hardware Abstraction Layer - HAL)
/// เป็นสัญญา (Contract) ว่าทุกช่องทางการเชื่อมต่อ (Bluetooth, WiFi, USB)
/// จะต้องมีฟังก์ชันเหล่านี้เหมือนกัน
abstract class ConnectionInterface {
  /// สถานะการเชื่อมต่อ
  bool get isConnected;

  /// เชื่อมต่อไปยังอุปกรณ์
  /// [deviceId] - รหัสหรือชื่อของอุปกรณ์ที่ต้องการเชื่อมต่อ
  Future<void> connect(String deviceId);

  /// ตัดการเชื่อมต่อ
  Future<void> disconnect();

  /// ส่งข้อมูลไปยังรถ
  /// [data] - ข้อมูล (List of Bytes) ที่ต้องการส่ง
  Future<List<int>> send(List<int> data);

  /// Stream สำหรับรับข้อมูลที่รถส่งกลับมา (Asynchronous)
  Stream<List<int>> get onDataReceived;
}
