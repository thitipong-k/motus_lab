import 'dart:async';
import 'dart:math';
import 'package:motus_lab/core/connection/connection_interface.dart';

/// การเชื่อมต่อจำลอง (Mock Connection)
/// ใช้สำหรับทดสอบระบบโดยไม่ต้องต่อรถจริง
/// จะสุ่มค่าส่งกลับมาเหมือนรถจริงๆ ตอบสนอง
class MockConnection implements ConnectionInterface {
  bool _isConnected = false;
  final _controller = StreamController<List<int>>.broadcast();

  // Simulation State Variables
  double _fuelLevel = 100.0;
  double _coolantTemp = 40.0; // Start cold
  double _load = 20.0;

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
        Duration(milliseconds: 30)); // Faster response for smoother graph

    List<int> response = [];

    // --- MODE 01: Live Data ---
    if (data.length >= 2 && data[0] == 0x01) {
      final pid = data[1];

      // 01 00: Supported PIDs [01-20]
      if (pid == 0x00) {
        // Supported PIDs:
        // 04: Engine Load
        // 05: Coolant Temp
        // 06: Short Term Fuel Trim
        // 07: Long Term Fuel Trim
        // 0C: RPM
        // 0D: Speed
        // 10: MAF Air Flow

        // Bitmask Calculation:
        // Byte 1 (PIDs 01-08): 0001 1110 (binary) -> 0x1E (Supports 04, 05, 06, 07)
        // Byte 2 (PIDs 09-16): 0001 1001 (binary) -> 0x19 (Supports 0C, 0D, 10)
        // Byte 3 (PIDs 17-24): 0000 0000 -> 0x00
        // Byte 4 (PIDs 25-32): 0000 0000 -> 0x00 (But typically 01 20 check next)
        // Let's enable support for 01 20 check as well (Last bit of byte 4 = 1?) NO.
        // Let's just say we support up to 20 for now, + Fuel Level (2F) check in next block

        // To support 01 20 query, bit 32 (last bit of byte 4) must be 1.
        // So Byte 4 = 0000 0001 -> 0x01

        response = [0x41, 0x00, 0x1E, 0x19, 0x00, 0x01];
      }
      // 01 20: Supported PIDs [21-40]
      else if (pid == 0x20) {
        // Support 2F (Fuel Level)
        // 2F is 15th PID in this block (20 + 15 = 35? No 2F is 47 decimal)
        // Wait, 0x2F is 47. 21 is start. 47-20 = 27.
        // 2F is 47 decimal.
        // Block 2: 21..40 (0x15..0x28). Wait.
        // 0x20 is 32. 0x2F is 47.
        // Block 2 covers 33..64? No.
        // Block 1: 01..20 (0x01..0x14)
        // Block 2: 21..40 (0x15..0x28).
        // Block 3: 41..60 (0x29..0x3C).
        // Ah, 2F is 47 decimal. So it falls in Block 3 (Supported PIDs 41-60).
        // So we need to support PID 40 check to get to Block 3.

        // Let's re-read standard.
        // 01 00 -> PIDs 01-20
        // 01 20 -> PIDs 21-40
        // 01 40 -> PIDs 41-60

        // PID 2F (Fuel Level) is 47 decimal.
        // 47 falls in 41-60 range?
        // 0x2F = 47.
        // Live Data Page uses "Fuel Level" which is usually PID 2F.

        // Let's keep it simple.
        // Support 2F (47) means we need 01 40 support.

        // For 01 20 response (PIDs 21-40):
        // We want to support checking 01 40. So last bit of Byte 4 = 1.
        response = [0x41, 0x20, 0x00, 0x00, 0x00, 0x01];
      }
      // 01 40: Supported PIDs [41-60]
      else if (pid == 0x40) {
        // Support 2F hex? No, 2F is 47 decimal.
        // 2F hex is 47 decimal.
        // Range 41..60. 47 is the 7th PID in this block.
        // Byte 1: 41..48.
        // 47 is 7th bit. 0100 0000? No, 41=bit1.
        // 41, 42, 43, 44, 45, 46, 47.
        // 47 is bit 7. 0000 0010 -> 0x02.

        response = [0x41, 0x40, 0x02, 0x00, 0x00, 0x00];
      }

      // 01 04: Calculator Load Value
      else if (pid == 0x04) {
        // Sine wave 20% - 80%
        final now = DateTime.now().millisecondsSinceEpoch;
        final sine = sin(now / 5000); // Slower
        _load = 50 + (sine * 30);
        int val = (_load * 2.55).round(); // 100% = 255
        response = [0x41, 0x04, val];
      }

      // 01 05: Coolant Temp
      else if (pid == 0x05) {
        // Gradual warm up to 90C
        if (_coolantTemp < 90) {
          _coolantTemp += 0.1;
        } else {
          // Fluctuate 88-92
          _coolantTemp =
              90 + sin(DateTime.now().millisecondsSinceEpoch / 2000) * 2;
        }
        int val = (_coolantTemp + 40).round();
        response = [0x41, 0x05, val];
      }

      // 01 06: Short Term Fuel Trim
      else if (pid == 0x06) {
        // Fluctuate around 0 (-5% to +5%)
        // Formula: (A-128)*100/128
        // 0% = 128
        double trim = sin(DateTime.now().millisecondsSinceEpoch / 500) * 5;
        int val = ((trim * 1.28) + 128).round();
        response = [0x41, 0x06, val];
      }

      // 01 07: Long Term Fuel Trim
      else if (pid == 0x07) {
        // More stable around 2%
        int val = ((2.5 * 1.28) + 128).round();
        response = [0x41, 0x07, val];
      }

      // 01 0C: Engine RPM (Sine Wave)
      else if (pid == 0x0C) {
        // Generate Sine Wave: 800 - 4000 RPM
        final now = DateTime.now().millisecondsSinceEpoch;
        final sineValue = sin(now / 10000 * 2 * pi); // -1 to 1
        double rpm = 800 + ((sineValue + 1) / 2) * 3200;
        rpm += (Random().nextDouble() - 0.5) * 50; // Noise

        int rawValue = (rpm * 4).round();
        int A = (rawValue ~/ 256) & 0xFF;
        int B = rawValue & 0xFF;
        response = [0x41, 0x0C, A, B];
      }
      // 01 0D: Vehicle Speed (Ramp Up/Down)
      else if (pid == 0x0D) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final cycle = now % 20000; // 0 - 19999
        int speed;
        if (cycle < 10000) {
          speed = (cycle / 100).round();
        } else {
          speed = ((20000 - cycle) / 100).round();
        }
        response = [0x41, 0x0D, speed];
      }
      // 01 10: MAF Air Flow
      else if (pid == 0x10) {
        // Correlate with RPM roughly
        // Idle (800) ~ 2-4 g/s
        // 4000 rpm ~ 20-30 g/s
        // Just divide RPM by 150 for rough g/s
        // Formula: ((A*256)+B)/100
        final now = DateTime.now().millisecondsSinceEpoch;
        final sineValue = sin(now / 10000 * 2 * pi);
        double rpm = 800 + ((sineValue + 1) / 2) * 3200;

        double maf = rpm / 150;
        int raw = (maf * 100).round();
        int A = (raw ~/ 256) & 0xFF;
        int B = raw & 0xFF;
        response = [0x41, 0x10, A, B];
      }

      // 01 2F: Fuel Level
      else if (pid == 0x2F) {
        // Slowly decrease
        if (_fuelLevel > 0) _fuelLevel -= 0.001;
        int val = ((_fuelLevel * 255) / 100).round();
        response = [0x41, 0x2F, val];
      } else {
        // Not supported in this mock
        // Empty response or error?
        // Usually NO DATA or just nothing.
        // Let's return basics to avoid crash but user wants them hidden.
        // If we don't return 41 xx ... the parser might ignore it.
        response = [];
      }
    }

    // --- MODE 02: Freeze Frame ---
    else if (data.length >= 2 && data[0] == 0x02) {
      final pid = data[1];

      // 02 02: DTC that caused Freeze Frame
      if (pid == 0x02) {
        // Return P0123 (01 23)
        response = [0x42, 0x02, 0x01, 0x23];
      }

      // 02 04: Calc Load
      else if (pid == 0x04) {
        response = [0x42, 0x04, 153]; // 60%
      }
      // 02 05: Coolant Temp
      else if (pid == 0x05) {
        response = [0x42, 0x05, 133]; // 93 deg C
      }
      // 02 0C: RPM
      else if (pid == 0x0C) {
        // Freeze at 2500 RPM
        // 2500 * 4 = 10000 = 0x2710
        response = [0x42, 0x0C, 0x27, 0x10];
      }
      // 02 0D: Speed
      else if (pid == 0x0D) {
        // Freeze at 45 km/h
        response = [0x42, 0x0D, 45];
      }
      // 02 06: STFT B1
      else if (pid == 0x06) {
        // +10% -> 128 + (10 * 1.28) = 141
        response = [0x42, 0x06, 141];
      }
      // 02 07: LTFT B1
      else if (pid == 0x07) {
        // +5% -> 128 + (5 * 1.28) = 134
        response = [0x42, 0x07, 134];
      } else {
        // Default empty or 0 for others to prevent errors
        response = [0x42, pid, 0x00, 0x00];
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
      response = [0x43, 0x02, 0x01, 0x23, 0xC4, 0x56];
    }

    // --- MODE 04: Clear DTCs ---
    else if (data.length >= 1 && data[0] == 0x04) {
      response = [0x44];
    }

    // Default
    else {
      // Echo
      if (data.isNotEmpty)
        response = [0x41, data.length > 1 ? data[1] : 0x00, 0x00];
    }

    // ส่งค่าเข้า Stream ด้วย
    if (response.isNotEmpty) {
      _controller.add(response);
    }

    return response;
  }
}
