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

  @override
  String get menuSettings => 'ตั้งค่า';

  @override
  String get lblVisualTheme => 'ธีมของแอป';

  @override
  String get lblUnitSystem => 'หน่วยการวัด';

  @override
  String get lblLanguage => 'ภาษา';

  @override
  String get lblImperial => 'อังกฤษ (mph, °F)';

  @override
  String get lblMetric => 'เมตริก (km/h, °C)';

  @override
  String get navConnect => 'เชื่อมต่อ';

  @override
  String get navDash => 'แดชบอร์ด';

  @override
  String get navMap => 'ผังระบบ';

  @override
  String get navService => 'บริการ';

  @override
  String get navMenu => 'เมนู';

  @override
  String get moreHelp => 'ช่วยเหลือ';

  @override
  String get moreDiagnostics => 'วินิจฉัย';

  @override
  String get moreFreezeFrame => 'ฟรีซเฟรม';

  @override
  String get moreDataLogs => 'บันทึกข้อมูล';

  @override
  String get moreCRM => 'ลูกค้า';

  @override
  String get moreRemoteExpert => 'ผู้เชี่ยวชาญ';

  @override
  String get moreWallet => 'กระเป๋าเงิน';

  @override
  String get moreCoding => 'โค้ดดิ้ง';

  @override
  String get moreSniffer => 'สนิฟเฟอร์';

  @override
  String get moreKnowledge => 'ความรู้';

  @override
  String get moreSettings => 'ตั้งค่า';

  @override
  String get moreSeedCloud => 'อัปโหลดข้อมูล';

  @override
  String get secTitle => 'ความปลอดภัย';

  @override
  String get secAppLock => 'ระบบล็อคแอป';

  @override
  String get secAppLockDesc =>
      'ปกป้องข้อมูลสำคัญด้วยการยืนยันตัวตน (Biometrics)';

  @override
  String get secAuthReq => 'ต้องยืนยันตัวตน';
}
