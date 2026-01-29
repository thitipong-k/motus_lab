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

    await Future.delayed(
        Duration(milliseconds: 50)); // Faster response for smoother graph

    List<int> response = [];

    // --- MODE 01: Live Data ---
    if (data.length >= 2 && data[0] == 0x01) {
      final pid = data[1];

      // 01 00: Supported PIDs
      if (pid == 0x00) {
        // Mock supporting ONLY:
        // PID 0C (RPM) -> Byte 2, Bit 4 -> 0x10
        // PID 0D (Speed) -> Byte 2, Bit 3 -> 0x08
        // Combined Byte 2: 0x18
        // Result: 41 00 00 18 00 00
        response = [0x41, 0x00, 0x00, 0x18, 0x00, 0x00];
      }
      // 01 20: Supported PIDs [21-40]
      else if (pid == 0x20) {
        // No more PIDs
        response = [0x41, 0x20, 0x00, 0x00, 0x00, 0x00];
      }
      // 01 0C: Engine RPM (Sine Wave)
      // Formula: ((A*256)+B)/4
      else if (pid == 0x0C) {
        // Generate Sine Wave: 800 - 4000 RPM
        // Period: 10 seconds
        final now = DateTime.now().millisecondsSinceEpoch;
        final sineValue = sin(now / 10000 * 2 * pi); // -1 to 1
        // Map -1..1 to 800..4000
        // Normalized 0..1 = (sine + 1) / 2
        double rpm = 800 + ((sineValue + 1) / 2) * 3200;

        // Add some noise (+- 50 rpm)
        rpm += (Random().nextDouble() - 0.5) * 50;

        int rawValue = (rpm * 4).round();
        int A = (rawValue ~/ 256) & 0xFF;
        int B = rawValue & 0xFF;
        response = [0x41, 0x0C, A, B];
      }
      // 01 0D: Vehicle Speed (Ramp Up/Down)
      // Formula: A
      else if (pid == 0x0D) {
        // Ramp: 0 -> 100 -> 0 every 20 seconds
        final now = DateTime.now().millisecondsSinceEpoch;
        final cycle = now % 20000; // 0 - 19999
        int speed;
        if (cycle < 10000) {
          // Accelerate 0 -> 100
          speed = (cycle / 100).round();
        } else {
          // Decelerate 100 -> 0
          speed = ((20000 - cycle) / 100).round();
        }
        response = [0x41, 0x0D, speed];
      }
      // 01 05: Coolant Temp
      else if (pid == 0x05) {
        int temp = 90; // Constant nominal
        int A = temp + 40;
        response = [0x41, 0x05, A];
      } else {
        response = [0x41, pid, 0x00];
      }
    }

    // --- MODE 21: Honda Custom PIDs ---
    else if (data.length >= 2 && data[0] == 0x21) {
      final pid = data[1];
      // 21 01: CVT Temp
      if (pid == 0x01) {
        // Mock value 85 deg C -> 85 + 40 = 125 (0x7D)
        response = [0x61, 0x01, 0x7D];
      } else {
        response = [0x7F, 0x21, 0x12]; // Subfunction not supported
      }
    }

    // --- MODE 03: Read DTCs ---
    else if (data.length >= 1 && data[0] == 0x03) {
      // Mock returning 2 DTCs: P0123, U0456
      // Standard ISO 15765-4 usually splits this into multiple frames for CAN,
      // but for logic testing we can assume the Parser handles valid bytes.
      // SAE J1979 format: [43] [N] [DTC1_HB] [DTC1_LB] [DTC2_HB] [DTC2_LB] ...
      // DTC Format:
      // P0123 -> P=00 (0000), 0=0 (00), 1=1 (01) -> 0000 0001 -> 01
      //          2=2 (0010), 3=3 (0011)          -> 0010 0011 -> 23
      // So P0123 = 01 23
      // U0456 -> U=11 (11), 0=0 (00), 4=4 (0100) -> 1100 0100 -> C4
      //          5=5 (0101), 6=6 (0110)          -> 0101 0110 -> 56
      // So U0456 = C4 56

      // Response: 43 (Mode+40) 02 (Count) 01 23 C4 56
      response = [0x43, 0x02, 0x01, 0x23, 0xC4, 0x56];
    }

    // --- MODE 04: Clear DTCs ---
    else if (data.length >= 1 && data[0] == 0x04) {
      // Success response is just 44
      response = [0x44];
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
