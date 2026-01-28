import 'package:flutter_js/flutter_js.dart';

/// เอ็นจิ้นสำหรับรันสคริปต์ (JavaScript) เพื่อจัดการโปรโตคอลเสริม
/// ช่วยให้ผู้ใช้สามารถเขียน Logic การวิเคราะห์รถได้เองโดยไม่ต้องแก้โค้ดหลัก
class ScriptingEngine {
  late JavascriptRuntime _jsRuntime;

  ScriptingEngine() {
    // 1. เริ่มทำงาน Javascript Runtime
    _jsRuntime = getJavascriptRuntime();
  }

  /// ฟังก์ชันรันสคริปต์ที่รับค่าเข้ามา
  /// [script] โค้ด JavaScript ที่ต้องการรัน
  /// ตัวอย่าง: "var rpm = 3000; rpm > 2500 ? 'High' : 'Normal';"
  dynamic execute(String script) {
    try {
      // 2. ประมวลผลสคริปต์
      final result = _jsRuntime.evaluate(script);

      // 3. คืนค่าผลลัพธ์ที่ได้จาก Engine
      print("Script Result: ${result.stringResult}");
      return result.stringResult;
    } catch (e) {
      print("Script Error: $e");
      return "Error: $e";
    }
  }

  /// ปิดการทำงานเพื่อคืนหน่วยความจำ
  void dispose() {
    _jsRuntime.dispose();
  }
}
