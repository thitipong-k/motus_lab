import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// บริการสำหรับการส่งออกข้อมูล (Export) เป็นไฟล์ CSV
/// ใช้สำหรับเก็บประวัติการ Log ข้อมูลเซนเซอร์ในระยะยาว
class ExportService {
  /// ฟังก์ชันบันทึกข้อมูล Live Data ลงไฟล์ CSV
  /// [fileName] ชื่อไฟล์ที่ต้องการบันทึก
  /// [headers] หัวตาราง (เช่น RPM, Speed, Temp)
  /// [rows] ข้อมูลในแต่ละแถว
  static Future<String> exportToCsv({
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    try {
      // 1. หาตำแหน่งโฟลเดอร์สำหรับเก็บเอกสารในเครื่อง
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/$fileName.csv";
      final file = File(path);

      // 2. ปรับโครงสร้างข้อมูลให้อยู่ในรูปแบบ CSV (คั่นด้วย Comma)
      String csvData = "${headers.join(",")}\n";
      for (var row in rows) {
        csvData += "${row.join(",")}\n";
      }

      // 3. เขียนข้อมูลลงไฟล์
      await file.writeAsString(csvData);

      print("บันทึกไฟล์ CSV สำเร็จ: $path");
      return path;
    } catch (e) {
      throw Exception("การส่งออกข้อมูลล้มเหลว: $e");
    }
  }
}
