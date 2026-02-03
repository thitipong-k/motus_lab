import 'dart:convert';
import 'package:motus_lab/core/protocol/expression_evaluator.dart';
import 'package:motus_lab/domain/entities/command.dart';
import 'package:motus_lab/core/protocol/standard_pids.dart';
import 'package:motus_lab/core/protocol/models/protocol_pack.dart';
import 'package:motus_lab/domain/entities/obd_communication.dart';
import 'package:motus_lab/core/protocol/script_engine.dart';

/// ตัวขับเคลื่อนหลักของระบบ (Protocol Engine)
/// ทำหน้าที่เป็น "สมอง" ของการสื่อสาร โดยมีหน้าที่หลักคือ:
/// 1. แปลงวัตถุคำสั่ง (Command) เป็นสิ่งที่โปรโตคอลเข้าใจ
/// 2. นำข้อมูลดิบที่ได้จากรถมาคำนวณตามสูตร (Mathematics Formula) หรือ สคริปต์ (Tier 3 JS)
/// 3. จัดการการโหลดการตั้งค่าเฉพาะรุ่นรถ (Protocol Packs)
/// Protocol Engine - Brain of the communication layer (Enhanced with script support)
class ProtocolEngine {
  final ExpressionEvaluator _evaluator;
  final ScriptEngine _scriptEngine;
  ProtocolPack? _activePack;
  List<Command>? _cachedCommands;

  /// สร้างชุดขับเคลื่อนโปรโตคอล
  /// [evaluator] - ตัวคำนวณทางคณิตศาสตร์ (ถ้าไม่ระบุจะใช้ค่ามาตรฐาน)
  /// [scriptEngine] - ตัวประมวลผลสคริปต์ JS (สำหรับ Tier 3)
  ProtocolEngine({ExpressionEvaluator? evaluator, ScriptEngine? scriptEngine})
      : _evaluator = evaluator ?? ExpressionEvaluator(),
        _scriptEngine = scriptEngine ?? ScriptEngine();

  /// โหลดข้อมูลโปรโตคอลเฉพาะของรถแต่ละรุ่นจาก JSON
  /// [jsonString] - เนื้อหา JSON ที่นิยามคำสั่งและสูตรคำนวณของรถรุ่นนั้นๆ
  void loadProtocolPack(String jsonString) {
    try {
      final jsonMap = jsonDecode(jsonString);
      _activePack = ProtocolPack.fromJson(jsonMap);
      _cachedCommands = null; // ล้าง Cache เดิมทิ้งเพื่อใช้ข้อมูลใหม่
      print("โหลดโปรโตคอลสำเร็จ: ${_activePack?.meta.name}");
    } catch (e) {
      print("เกิดข้อผิดพลาดในการโหลดโปรโตคอล: $e");
      // หากพลาด จะกลับไปใช้ค่ามาตรฐาน (StandardPids)
      _activePack = null;
    }
  }

  /// แปลงคำสั่ง (Command Entity) ให้กลายเป็น ObdRequest
  /// ขั้นตอนนี้จะถูกเรียกก่อนส่งข้อมูลไปยัง Hardware Adapter
  ObdRequest buildRequest(Command command) {
    // คาดหวัง code เช่น "010C" (RPM)
    return ObdRequest(command: command.code);
  }

  /// นำผลลัพธ์จากรถ (ObdResponse) มาแปลงเป็นตัวเลขที่มนุษย์เข้าใจ
  /// [response] - ข้อมูลที่รถตอบกลับมา
  /// [formula] - สูตรการคำนวณ (ใช้เป็นแผนสำรอง)
  /// [script] - สคริปต์การคำนวณ (ถ้ามี จะถูกใช้ก่อน formula)
  double parseResponse(ObdResponse response, String formula, {String? script}) {
    // 1. ตรวจสอบก่อนว่าข้อมูลใช้ได้ไหม (ไม่เป็น NO DATA หรือ ERROR)
    if (!response.hasValidData) return 0.0;

    final rawBytes = response.rawData;
    // 2. ตรวจสอบความยาว (ต้องมีอย่างน้อย Header 2 bytes + ข้อมูล)
    if (rawBytes.length <= 2) return 0.0;

    // 3. ตัด Header (เช่น 41 0C) ออกเพื่อเอาเฉพาะเนื้อข้อมูล (Payload)
    List<int> dataBytes = rawBytes.sublist(2);

    // 4. เลือกวิธีประมวลผล: Tier 3 (Script) หรือ Tier 2 (Formula)
    if (script != null && script.isNotEmpty) {
      return _scriptEngine.evaluate(script, dataBytes);
    }

    // 5. ส่งข้อมูล payload ไปให้ Expression Evaluator คำนวณตามสูตร
    return _evaluator.evaluate(formula, dataBytes);
  }

  /// แปลงข้อมูล Bitmask (4 Bytes) จากรถ ให้เป็นรายการ PID ที่รถคันนี้รองรับ
  ///
  /// ระบบ OBD-II จะคืนข้อมูลรองรับ PIDs ในรูปแบบบิทแมสก์ 32 บิท
  /// (เช่น 0100 จะคืนว่า 0101-0120 รองรับอะไรบ้าง)
  ///
  /// [response] - ข้อมูลดิบที่ตอบกลับจากรถ
  /// [startPid] - PID เริ่มต้นของช่วง (เช่น 0x00, 0x20, 0x40)
  List<String> decodeSupportedPids(List<int> response, int startPid) {
    // 1. ตรวจสอบเบื้องต้น: ข้อมูลต้องยาวพอ (Header 2 bytes + Bitmask 4 bytes)
    if (response.length < 6) return [];

    List<String> supportedPids = [];
    // 2. ดึงข้อมูล 4 bytes หลักที่เป็นตัวกำหนดว่า PID ไหนรองรับบ้าง
    List<int> data = response.sublist(2, 6);

    // 3. วนลูปตรวจสอบทีละบิท (รวม 32 บิท)
    for (int i = 0; i < 32; i++) {
      int byteIndex = i ~/ 8; // หาว่าข้อมูลอยู่ใน Byte ไหน (0-3)
      int bitIndex = 7 - (i % 8); // หาตำแหน่งบิทจากซ้ายไปขวา (MSB)

      int mask = 1 << bitIndex;
      // 4. หากบิทนั้นมีค่าเป็น 1 แสดงว่ารถคันนี้รองรับ PID นั้น
      if ((data[byteIndex] & mask) != 0) {
        int pidVal = startPid + 1 + i;
        // 5. แปลงค่าตัวเลขเป็นรหัสฐาน 16 (Hex) เช่น 0x0C -> "010C"
        String pidHex = pidVal.toRadixString(16).toUpperCase().padLeft(2, '0');
        supportedPids.add("01$pidHex");
      }
    }

    return supportedPids;
  }

  /// ดึงรายการคำสั่งทั้งหมดที่มีให้ใช้งานในโปรเจค
  ///
  /// ลำดับการเลือก:
  /// 1. หากมีการโหลด 'Protocol Pack' (JSON กองกลาง) จะดึงคำสั่งจากในนั้นก่อน
  /// 2. หากไม่มี (หรือไม่พบ) จะรันกลับไปใช้คำสั่ง 'Standard Pids' (SAE J1979)
  List<Command> getAllSupportedPids() {
    // กรณีมี Protocol Pack ที่โหลดไว้แล้ว
    if (_activePack != null && _cachedCommands == null) {
      _cachedCommands = _activePack!.commands.map<Command>((ObdCommandDef cmd) {
        return Command(
          name: cmd.name,
          code: cmd.pid,
          description: "จากโปรโตคอล Pack: ${cmd.pid}",
          unit: cmd.unit,
          formula: cmd.formula,
          script: cmd.script,
        );
      }).toList();
    }

    // ส่งคืนรายการคำสั่งจาก Cache หรือใช้ค่ามาตรฐาน
    return _cachedCommands ?? StandardPids.all;
  }
}
