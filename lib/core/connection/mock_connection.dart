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

    // ตรวจสอบว่าเป็นคำสั่ง RPM หรือไม่ (01 0C)
    if (data.length >= 2 && data[0] == 0x01 && data[1] == 0x0C) {
      // ตอบกลับ: 41 0C A B (41 = Success Response of 01)
      // A, B คือค่า RPM (RPM = (A*256+B)/4)
      final random = Random();
      int A = random.nextInt(50); // 0-50
      int B = random.nextInt(256); // 0-255
      // ถ้า A=30, B=0 -> (30*256)/4 = 1920 RPM

      response = [0x41, 0x0C, A, B];
    }
    // ตรวจสอบว่าเป็นคำสั่ง Speed หรือไม่ (01 0D)
    else if (data.length >= 2 && data[0] == 0x01 && data[1] == 0x0D) {
      // Speed = A km/h
      int speed = Random().nextInt(120);
      response = [0x41, 0x0D, speed];
    }
    // Default: ตอบกลับว่า OK แต่ไม่มีข้อมูล
    else {
      response = [0x41, data.length > 1 ? data[1] : 0x00, 0x00];
    }

    // ส่งค่าเข้า Stream ด้วย
    _controller.add(response);

    return response;
  }
}
