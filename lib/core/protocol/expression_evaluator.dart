import 'package:math_expressions/math_expressions.dart';

/// ตัวคำนวณสูตร (Expression Evaluator)
/// ใช้สำหรับแปลงค่า Raw Byte ที่ได้จากรถ ให้เป็นค่าที่มนุษย์อ่านรู้เรื่อง
/// โดยใช้สูตรที่กำหนดใน Protocol (เช่น "A*256+B")
class ExpressionEvaluator {
  final Parser _parser = Parser();

  /// ฟังก์ชันประมวลผลสูตร
  /// [formula] - สูตรทางคณิตศาสตร์ (String) เช่น "A * 256 + B"
  /// [bytes] - ข้อมูลดิบจากรถ (List<int>)
  /// Return: ผลลัพธ์ที่คำนวณได้ (double)
  double evaluate(String formula, List<int> bytes) {
    if (formula.isEmpty) return 0.0;

    try {
      // ขั้นตอนที่ 1: แปลงสูตรเป็น Expression Object
      Expression exp = _parser.parse(formula);

      // ขั้นตอนที่ 2: สร้าง Context Model เพื่อเก็บตัวแปร
      ContextModel cm = ContextModel();

      // ขั้นตอนที่ 3: กำหนดค่าตัวแปร A, B, C, D... จากข้อมูล Byte
      // A = Byte[0], B = Byte[1], ...
      List<String> vars = ['A', 'B', 'C', 'D', 'E', 'F'];
      for (int i = 0; i < bytes.length && i < vars.length; i++) {
        cm.bindVariable(Variable(vars[i]), Number(bytes[i].toDouble()));
      }

      // ขั้นตอนที่ 4: คำนวณผลลัพธ์
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      // กรณีเกิดข้อผิดพลาดในการคำนวณ (เช่น สูตรผิด หรือ Byte ไม่พอ)
      print('Error evaluating formula "$formula": $e');
      return 0.0;
    }
  }
}
