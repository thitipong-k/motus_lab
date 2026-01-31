import 'dart:io';
import 'package:home_widget/home_widget.dart';
import 'package:logger/logger.dart';

/// Service สำหรับจัดการ Widget บนหน้าจอ Home Screen (Android/iOS)
/// ทำหน้าที่ส่งข้อมูลจาก Flutter ไปยัง Native Widget ผ่าน SharedPreferences
class HomeWidgetService {
  final Logger _logger = Logger();
  static const String _groupId =
      'group.com.motus_lab.widget'; // ต้องตรงกับ App Group ใน iOS
  static const String _androidWidgetName =
      'MotusWidget'; // ต้องตรงกับชื่อ Class ใน Android (MotusWidget.kt)

  /// อัปเดตสถานะการเชื่อมต่อ (Connected/Disconnected) ไปยัง Widget
  Future<void> updateConnectionStatus({required bool isConnected}) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      // บันทึกข้อมูลสถานะลงใน Shared Storage
      await HomeWidget.saveWidgetData<bool>('is_connected', isConnected);
      await HomeWidget.saveWidgetData<String>(
          'status_text', isConnected ? 'Connected' : 'Disconnected');

      // สั่งอัปเดตหน้าจอ Widget
      await _updateWidget();
    } catch (e) {
      _logger.e('Failed to update connection status widget: $e');
    }
  }

  /// ส่งข้อมูลรถยนต์ (เช่น Voltage, DTC) ไปแสดงผล
  Future<void> updateVehicleData(String label, String value) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      // ตัวอย่าง: 'voltage' -> '12.5V'
      await HomeWidget.saveWidgetData<String>(label, value);
      await _updateWidget();
    } catch (e) {
      _logger.e('Failed to update vehicle data widget ($label): $e');
    }
  }

  /// สั่งให้ Widget รีเฟรชหน้าจอเพื่อแสดงข้อมูลล่าสุด
  Future<void> _updateWidget() async {
    try {
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        iOSName: _androidWidgetName,
      );
    } catch (e) {
      _logger.e('Failed to force widget update: $e');
    }
  }
}
