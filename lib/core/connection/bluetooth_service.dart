import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';

/// เซอร์วิสสำหรับจัดการ Bluetooth ในภาพรวม (Scan, List, Permission)
/// ทำหน้าที่เป็นหน้าด่านก่อนจะสร้าง BleConnection จริง
class BluetoothService {
  final Logger _logger = Logger();

  // Stream สำหรับรายการอุปกรณ์ที่ค้นเจอ
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  // เริ่มการค้นหาอุปกรณ์
  Future<void> startScan() async {
    // ตรวจสอบความพร้อมก่อน
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      _logger.w("Bluetooth is off");
      return;
    }

    _logger.i("Starting scan...");
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      androidUsesFineLocation: true,
    );
  }

  // หยุดการค้นหา
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      _logger.i("Scan stopped");
    } catch (e) {
      _logger.w("Error stopping scan: $e");
    }
  }

  // ตรวจสอบสิทธิ์ (Android 12+)
  // ในโปรเจกต์จริงต้องใช้ permission_handler เพิ่มเติม
  // เบื้องต้นใช้ฟังก์ชันในตัวของ flutter_blue_plus
  Future<bool> isReady() async {
    return await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
  }
}
