// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Motus Lab';

  @override
  String get titleDeviceSelection => 'เลือกอุปกรณ์';

  @override
  String get btnConnect => 'เชื่อมต่อ';

  @override
  String get btnConnected => 'เชื่อมต่อแล้ว';

  @override
  String get btnDisconnect => 'ตัดการเชื่อมต่อ';

  @override
  String get btnScan => 'สแกน';

  @override
  String get btnStop => 'หยุด';

  @override
  String get lblScanning => 'กำลังค้นหาอุปกรณ์ OBDII...';

  @override
  String get lblConnecting => 'กำลังเชื่อมต่ออุปกรณ์...';

  @override
  String get lblConnected => 'เชื่อมต่อสำเร็จ!';

  @override
  String lblError(String message) {
    return 'เกิดข้อผิดพลาด: $message';
  }

  @override
  String get msgNoDevices => 'ไม่พบอุปกรณ์ กดปุ่มรีเฟรชเพื่อสแกนใหม่';

  @override
  String get msgTapToScan => 'กดปุ่มรีเฟรชเพื่อเริ่มสแกน';
}
