import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/connection/mock_connection.dart';
import 'package:motus_lab/domain/entities/command.dart';

// สคริปต์ทดสอบการทำงานของระบบ Motus Core (Phase 1)
// ทดสอบ: ProtocolEngine + ExpressionEvaluator + MockConnection
void main() async {
  print("--- Starting Motus Core Verification (การทดสอบระบบแกนหลัก) ---");

  // 1. เริ่มต้นระบบ (Setup)
  final connection = MockConnection();
  final engine = ProtocolEngine();

  // 2. จำลองการเชื่อมต่อ (Connect)
  print("Step 1: Connecting to Mock Device...");
  await connection.connect("OBDII Simulator");
  if (connection.isConnected) {
    print(" -> Connected Success!");
  }

  // 3. เตรียมคำสั่ง RPM (01 0C)
  // สูตรมาตรฐาน: ((A * 256) + B) / 4
  final cmdRpm = Command(
    name: "Engine RPM",
    code: "010C",
    description: "Engine Speed",
    unit: "rpm",
    formula: "((A*256)+B)/4",
  );

  print("\nStep 2: Preparing Command '${cmdRpm.name}'");

  // 4. สร้าง Request Packet (Build)
  final request = engine.buildRequest(cmdRpm);
  // แปลงเป็น Hex String เพื่อแสดงผล: [1, 12] -> "01 0C"
  final requestHex = request
      .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join(' ');
  print(" -> Request Hex: $requestHex");

  // 5. ส่งและรอรับผล (Send & Receive)
  print("\nStep 3: Sending Command...");

  // สร้าง StreamSubscription เพื่อดักจับข้อมูลขาเข้า
  final subscription = connection.onDataReceived.listen((data) {
    final responseHex = data
        .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
    print(" -> Received Hex: $responseHex");

    // 6. แปลผล (Parse)
    print("\nStep 4: Parsing Response...");
    try {
      final value = engine.parseResponse(data, cmdRpm.formula);
      print(" -> Formula: ${cmdRpm.formula}");
      print(" -> Result: $value ${cmdRpm.unit}");
      print(" -> Status: Pass ✅");
    } catch (e) {
      print(" -> Error: $e ❌");
    }
  });

  // ส่งข้อมูลจริง
  await connection.send(request);

  // รอสักพักเพื่อให้ได้รับข้อมูลกลับมา
  await Future.delayed(Duration(seconds: 2));

  // จบการทำงาน
  await subscription.cancel();
  await connection.disconnect();
  print("\n--- Verification Complete ---");
}
