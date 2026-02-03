import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// ===================================================================
/// Database Connection Configuration (Native Platform)
/// ===================================================================
/// ฟังก์ชันสำหรับเปิดการเชื่อมต่อกับฐานข้อมูล SQLite บนเครื่อง (Android, iOS, Windows)
///
/// [key] - กุญแจสำหรับการเข้ารหัสฐานข้อมูล (Encryption Key)
/// ===================================================================
LazyDatabase openConnection({String? key}) {
  return LazyDatabase(() async {
    // 1. หาตำแหน่งโฟลเดอร์สำหรับเก็บไฟล์ฐานข้อมูลในเครื่อง
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'motus_lab.sqlite'));

    // 2. ตรวจสอบเงื่อนไขการเข้ารหัส
    // ตอนนี้บน Windows เราจะข้ามการเข้ารหัสไปก่อน (Bypass) เพื่อเลี่ยงปัญหา OpenSSL
    if (key != null && !Platform.isWindows) {
      // ใช้ SQLCipher สำหรับเข้ารหัสบน Mobile (Android, iOS)
      return NativeDatabase.createInBackground(
        file,
        setup: (rawDb) {
          // คำสั่งตั้งค่ารหัสผ่านให้ไฟล์ SQLite ก่อนเริ่มใช้งาน
          rawDb.execute("PRAGMA key = '$key';");
        },
      );
    }

    // 3. หากเป็น Windows หรือไม่มี Key จะเปิดแบบไฟล์ปกติ (ไม่เข้ารหัส)
    return NativeDatabase.createInBackground(file);
  });
}
