import 'package:flutter_js/flutter_js.dart';
import 'package:motus_lab/core/utils/logger.dart';

/// เอนจิ้นรันสคริปต์ (Script Engine)
/// ใช้สำหรับคำนวณค่าจาก OBD โดยใช้ Javascript (Tier 3 Manufacturer Middleware)
/// เหมาะสำหรับสูตรคำนวณที่มีความซับซ้อน เช่น มีเงื่อนไข (if-else) หรือการจัดการ Bitwise ขั้นสูง
class ScriptEngine {
  late JavascriptRuntime _jsRuntime;

  ScriptEngine() {
    _jsRuntime = getJavascriptRuntime();
  }

  /// ประมวลผลสคริปต์เพื่อหาค่าผลลัพธ์
  /// [script] - โค้ด Javascript (เช่น "A * 2 + B > 100 ? 1 : 0")
  /// [bytes] - ข้อมูลดิบจากรถ (List<int>)
  double evaluate(String script, List<int> bytes) {
    try {
      // 1. เตรียม Context โดยการ Bind ตัวแปร A, B, C... จาก Bytes
      // เพื่อให้สคริปต์เรียกใช้งานได้โดยตรง
      final List<String> varNames = ['A', 'B', 'C', 'D', 'E', 'F'];
      String setupCode = "";

      for (int i = 0; i < bytes.length && i < varNames.length; i++) {
        setupCode += "var ${varNames[i]} = ${bytes[i]}; ";
      }

      // 2. ประกอบโค้ดและรัน
      // ห่อสคริปต์เพื่อให้คืนค่าเป็นตัวเลขเสมอ
      final String fullExecutionCode =
          "$setupCode (function() { return $script; })();";

      final JsEvalResult result = _jsRuntime.evaluate(fullExecutionCode);

      if (result.isError) {
        Logger.error("JS Execution Error: ${result.stringResult}");
        return 0.0;
      }

      // 3. แปลงผลลัพธ์กลับเป็น double
      final double? value = double.tryParse(result.stringResult);
      return value ?? 0.0;
    } catch (e) {
      Logger.error("ScriptEngine Exception", e);
      return 0.0;
    }
  }

  /// เปิดใช้งาน Resource เมื่อเลิกใช้งาน
  void dispose() {
    _jsRuntime.dispose();
  }
}
