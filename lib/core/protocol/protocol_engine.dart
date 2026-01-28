import 'package:motus_lab/core/protocol/expression_evaluator.dart';
import 'package:motus_lab/domain/entities/command.dart';

/// ตัวขับเคลื่อนหลักของระบบ (Protocol Engine)
/// ทำหน้าที่รับคำสั่ง (Command) และแปลงเป็นข้อมูลดิบ (Hex) เพื่อส่งไปยังรถ
/// และรับค่ากลับมาคำนวณตามสูตร
class ProtocolEngine {
  final ExpressionEvaluator _evaluator;

  /// สร้าง Instance ของ Protocol Engine
  ProtocolEngine({ExpressionEvaluator? evaluator})
    : _evaluator = evaluator ?? ExpressionEvaluator();

  /// ฟังก์ชันสำหรับแปลงคำสั่งเป็น Hex String
  /// [command] - คำสั่งที่ต้องการส่ง
  /// Return: List ของข้อมูลที่เตรียมส่ง
  List<int> buildRequest(Command command) {
    // ขั้นตอนที่ 1: แปลงรหัสคำสั่ง (String) เป็น Hex Bytes
    // คาดหวัง code เช่น "010C" หรือ "0902"
    List<int> bytes = [];
    for (int i = 0; i < command.code.length; i += 2) {
      String byteString = command.code.substring(i, i + 2);
      bytes.add(int.parse(byteString, radix: 16));
    }
    return bytes;
  }

  /// ฟังก์ชันสำหรับรับข้อมูล Raw Hex และคำนวณเป็นค่ามนุษย์อ่านรู้เรื่อง
  /// [response] - ข้อมูลดิบที่รับมาจากรถ (เช่น [0x41, 0x0C, 0x1E, 0x20])
  /// [formula] - สูตรคำนวณ (เช่น "A*256+B / 4")
  /// Return: ค่าที่คำนวณแล้ว (Double)
  double parseResponse(List<int> response, String formula) {
    if (response.isEmpty) return 0.0;

    // ขั้นตอนที่ 1: ตัด Header ออก (สมมติว่าเป็น CAN Mode 1)
    // Response ตามมาตรฐาน OBD2 มักจะเริ่มด้วย (Mode + 40) + PID
    // เช่น ส่ง 01 0C -> รับ 41 0C A B
    // เราต้องการแค่ A B เพื่อไปคำนวณ

    // ตรวจสอบว่า response ยาวพอไหม (อย่างน้อย 2 bytes header + data)
    if (response.length <= 2) return 0.0;

    // ตัด 2 byte แรกออก (Header)
    List<int> dataBytes = response.sublist(2);

    // ขั้นตอนที่ 2: ส่งให้ Expression Evaluator คำนวณ
    return _evaluator.evaluate(formula, dataBytes);
  }
}
