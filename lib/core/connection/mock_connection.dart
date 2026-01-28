import 'dart:async';
import 'dart:math';
import 'package:motus_lab/core/connection/connection_interface.dart';

/// การเชื่อมต่อจำลอง (Mock Connection)
/// ใช้สำหรับทดสอบระบบโดยไม่ต้องต่อรถจริง
/// จะสุ่มค่าส่งกลับมาเหมือนรถจริงๆ ตอบสนอง
class MockConnection implements ConnectionInterface {
  bool _isConnected = false;
  final _controller = StreamController<List<int>>.broadcast();

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<List<int>> get onDataReceived => _controller.stream;

  @override
  Future<void> connect(String deviceId) async {
    // จำลองการ Delay เวลาเชื่อมต่อ 1 วินาที
    await Future.delayed(Duration(seconds: 1));
    _isConnected = true;
    print('Mock Connected to $deviceId');
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    print('Mock Disconnected');
  }

  @override
  Future<List<int>> send(List<int> data) async {
    if (!_isConnected) throw Exception("Device not connected");

    // จำลองการ Response ของรถ
    // ถ้าส่งคำสั่ง 01 0C (RPM) จะตอบกลับค่าสุ่ม
    // data[0] คือ Mode (01), data[1] คือ PID (0C)

    await Future.delayed(Duration(milliseconds: 100)); // Delay ระหว่างส่ง-รับ

    List<int> response = [];

    // Discovery (01 00) - Supported PIDs [01-20]
    if (data.length >= 2 && data[0] == 0x01 && data[1] == 0x00) {
      // Mocked: 04, 05, 0B, 0C, 0D, 0F, 10
      // Byte A (1-8): 0001 1000 = 0x18 (04, 05)
      // Byte B (9-16): 0011 1011 = 0x3B (0B, 0C, 0D, 0F, 10)
      // Byte C, D: 00 00
      response = [0x41, 0x00, 0x18, 0x3B, 0x00, 0x00];
    }
    // Load (01 04)
    else if (data.length >= 2 && data[0] == 0x01 && data[1] == 0x04) {
      // A*100/255 -> Random 20-80%
      int A = 50 + Random().nextInt(150);
      response = [0x41, 0x04, A];
    }
    // Coolant (01 05)
    else if (data.length >= 2 && data[0] == 0x01 && data[1] == 0x05) {
      // A - 40 -> Want 90 deg C -> A = 130
      int A = 120 + Random().nextInt(20);
      response = [0x41, 0x05, A];
    }
    // Intake Manifold Pressure (01 0B)
    else if (data.length >= 2 && data[0] == 0x01 && data[1] == 0x0B) {
      // A (kPa)
      int A = 30 + Random().nextInt(70);
      response = [0x41, 0x0B, A];
    }
    // RPM (01 0C)
    else if (data.length >= 2 && data[0] == 0x01 && data[1] == 0x0C) {
      final random = Random();
      int A = random.nextInt(50);
      int B = random.nextInt(256);
      response = [0x41, 0x0C, A, B];
    }
    // Speed (01 0D)
    else if (data.length >= 2 && data[0] == 0x01 && data[1] == 0x0D) {
      int speed = Random().nextInt(120);
      response = [0x41, 0x0D, speed];
    }
    // Intake Air Temp (01 0F)
    else if (data.length >= 2 && data[0] == 0x01 && data[1] == 0x0F) {
      // A - 40 -> Want 30 deg C -> A = 70
      int A = 60 + Random().nextInt(20);
      response = [0x41, 0x0F, A];
    }
    // MAF (01 10)
    else if (data.length >= 2 && data[0] == 0x01 && data[1] == 0x10) {
      // ((A*256)+B)/100
      int A = Random().nextInt(10);
      int B = Random().nextInt(256);
      response = [0x41, 0x10, A, B];
    }
    // Default
    else {
      response = [0x41, data.length > 1 ? data[1] : 0x00, 0x00];
    }

    // ส่งค่าเข้า Stream ด้วย
    _controller.add(response);

    return response;
  }
}
