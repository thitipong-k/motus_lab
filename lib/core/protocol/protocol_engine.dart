import 'dart:convert';
import 'package:motus_lab/core/protocol/expression_evaluator.dart';
import 'package:motus_lab/domain/entities/command.dart';
import 'package:motus_lab/core/protocol/standard_pids.dart';
import 'package:motus_lab/core/protocol/models/protocol_pack.dart';

/// ตัวขับเคลื่อนหลักของระบบ (Protocol Engine)
/// ทำหน้าที่รับคำสั่ง (Command) และแปลงเป็นข้อมูลดิบ (Hex) เพื่อส่งไปยังรถ
/// และรับค่ากลับมาคำนวณตามสูตร
class ProtocolEngine {
  final ExpressionEvaluator _evaluator;
  ProtocolPack? _activePack;
  List<Command>? _cachedCommands;

  /// สร้าง Instance ของ Protocol Engine
  ProtocolEngine({ExpressionEvaluator? evaluator})
      : _evaluator = evaluator ?? ExpressionEvaluator();

  /// โหลด Protocol Pack จาก JSON String
  /// [jsonString] - เนื้อหาไฟล์ JSON (e.g. อ่านจาก assets หรือ downloaded file)
  void loadProtocolPack(String jsonString) {
    try {
      final jsonMap = jsonDecode(jsonString);
      _activePack = ProtocolPack.fromJson(jsonMap);
      _cachedCommands = null; // Clear cache
      print("Loaded Protocol Pack: ${_activePack?.meta.name}");
    } catch (e) {
      print("Error loading protocol pack: $e");
      // Fallback to null (StandardPids)
      _activePack = null;
    }
  }

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

  /// แปลง Bitmask 4 Bytes เป็นรายการของ PID Codes ที่รถรองรับ
  /// [response] - ข้อมูลดิบจากรถ
  /// [startPid] - PID เริ่มต้นของ Bitmask นี้
  List<String> decodeSupportedPids(List<int> response, int startPid) {
    if (response.length < 6) return []; // Header(2) + Data(4)

    List<String> supportedPids = [];
    // Data เริ่มที่ Byte 2 (A, B, C, D)
    List<int> data = response.sublist(2, 6);

    // วนลูป 32 bits (4 bytes * 8 bits)
    for (int i = 0; i < 32; i++) {
      int byteIndex = i ~/ 8;
      int bitIndex = 7 - (i % 8); // อ่านจากซ้ายไปขวา (MSB)

      int mask = 1 << bitIndex;
      if ((data[byteIndex] & mask) != 0) {
        // PID ที่รองรับ = startPid + 1 + i
        int pidVal = startPid + 1 + i;
        // แปลงเป็น Hex String เช่น 0C -> "010C" (สมมติ Mode 01 เสมอ)
        String pidHex = pidVal.toRadixString(16).toUpperCase().padLeft(2, '0');
        supportedPids.add("01$pidHex");
      }
    }

    return supportedPids;
  }

  /// คืนค่ารายการ PIDs ทั้งหมดที่รองรับ (จาก Pack หรือ Standard)
  List<Command> getAllSupportedPids() {
    // ถ้ามี Protocol Pack ให้ใช้นิยามจาก Pack
    if (_activePack != null && _cachedCommands == null) {
      _cachedCommands = _activePack!.commands.map((cmd) {
        return Command(
          name: cmd.name,
          code: cmd.pid,
          description: "From ${cmd.pid}",
          unit: cmd.unit,
          formula: cmd.formula,
        );
      }).toList();
    }

    return _cachedCommands ?? StandardPids.all;
  }
}
