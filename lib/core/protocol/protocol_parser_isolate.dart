import 'dart:async';
import 'dart:isolate';
import 'package:motus_lab/domain/entities/obd_communication.dart';
import 'package:motus_lab/core/protocol/expression_evaluator.dart';

/// ===================================================================
/// ระบบประมวลผลข้อมูล OBD-II แบบ Background (Isolate-Based Parsing)
/// ===================================================================
///
/// ปัญหาเดิม: การประมวลผลข้อมูลจากรถยนต์บน Main Thread ทำให้ UI กระตุก
/// เมื่อมีการอัพเดตค่าหลาย PIDs พร้อมกัน
///
/// วิธีแก้: ใช้ Dart Isolate เพื่อย้ายงานประมวลผลไปทำใน Background Thread
/// ทำให้ UI ยังคงลื่นไหลแม้ในขณะที่กำลังถอดรหัสข้อมูลจำนวนมาก
///
/// ข้อจำกัด: flutter_js (ScriptEngine) ใช้งานใน Isolate ไม่ได้
/// เพราะต้องการ Flutter Bindings ซึ่งไม่มีใน Background Thread
/// ดังนั้นจึงใช้เฉพาะ ExpressionEvaluator (Pure Dart) เท่านั้น
/// ===================================================================

/// คำร้องขอการประมวลผล (Request) ที่ส่งเข้า Isolate
class ParseRequest {
  final ObdResponse response; // ข้อมูลดิบจากรถยนต์
  final String formula; // สูตรคำนวณ (เช่น "A*256+B")
  final String? script; // สคริปต์ JS (ข้ามในโหมด Isolate)
  final String cmdName; // ชื่อคำสั่ง (เช่น "Engine RPM")

  ParseRequest({
    required this.response,
    required this.formula,
    this.script,
    required this.cmdName,
  });
}

/// ผลลัพธ์การประมวลผล (Result) ที่ส่งกลับจาก Isolate
class ParseResult {
  final String cmdName; // ชื่อคำสั่งที่ประมวลผล
  final double value; // ค่าที่คำนวณได้

  ParseResult({required this.cmdName, required this.value});
}

/// ===================================================================
/// ProtocolParserIsolate - Long-Lived Worker Isolate
/// ===================================================================
///
/// รูปแบบการทำงาน:
/// 1. LiveDataBloc เรียก start() เพื่อสร้าง Isolate
/// 2. Isolate ส่ง SendPort กลับมาเพื่อรับคำสั่ง
/// 3. LiveDataBloc ส่ง ParseRequest ผ่าน parse()
/// 4. Isolate ประมวลผลแล้วส่ง ParseResult กลับ
/// 5. LiveDataBloc รับผลลัพธ์ผ่าน Stream และอัพเดต State
/// ===================================================================
class ProtocolParserIsolate {
  SendPort? _sendPort; // ช่องทางส่งข้อมูลเข้า Isolate
  Isolate? _isolate; // Reference สำหรับจัดการ Isolate
  final StreamController<ParseResult> _resultController =
      StreamController<ParseResult>.broadcast();

  /// Stream สำหรับรับผลลัพธ์จาก Isolate
  Stream<ParseResult> get results => _resultController.stream;

  /// เริ่มต้น Isolate Worker
  Future<void> start() async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_parserEntry, receivePort.sendPort);

    // รับ SendPort และผลลัพธ์จาก Isolate
    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message; // เก็บช่องทางสื่อสารไว้
      } else if (message is ParseResult) {
        _resultController.add(message); // ส่งผลลัพธ์ออก Stream
      }
    });
  }

  /// ส่งคำร้องขอประมวลผลเข้า Isolate
  void parse(ParseRequest request) {
    _sendPort?.send(request);
  }

  /// หยุดและทำลาย Isolate
  void stop() {
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
  }

  /// ===================================================================
  /// Entry Point ของ Isolate (ทำงานใน Background Thread)
  /// ใช้เฉพาะ ExpressionEvaluator (Pure Dart) เท่านั้น
  /// ===================================================================
  static void _parserEntry(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort); // ส่งช่องทางรับข้อมูลกลับ

    final evaluator = ExpressionEvaluator();

    // ลูปรับคำสั่งจาก Main Thread
    receivePort.listen((message) {
      if (message is ParseRequest) {
        double result = 0.0;
        try {
          // ตรวจสอบว่าข้อมูลถูกต้องและมีความยาวเพียงพอ
          if (message.response.hasValidData &&
              message.response.rawData.length > 2) {
            // ตัด Header (Mode + PID) ออก เหลือเฉพาะ Data Bytes
            final dataBytes = message.response.rawData.sublist(2);

            // คำนวณค่าจากสูตร (ข้าม Script เพราะ flutter_js ใช้ใน Isolate ไม่ได้)
            result = evaluator.evaluate(message.formula, dataBytes);
          }
        } catch (e) {
          // จัดการ Error แบบเงียบ ป้องกัน Isolate Crash
        }

        // ส่งผลลัพธ์กลับไป Main Thread
        mainSendPort.send(ParseResult(
          cmdName: message.cmdName,
          value: result,
        ));
      }
    });
  }
}
