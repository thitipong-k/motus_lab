import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';

/// การเชื่อมต่อผ่าน Serial Port (USB) สำหรับ Desktop
/// คลาสนี้ทำหน้าที่จัดการการรับ-ส่งข้อมูลผ่านสาย USB OBDII
class SerialConnection implements ConnectionInterface {
  SerialPort? _port;
  final _controller = StreamController<List<int>>.broadcast();

  @override
  bool get isConnected => _port != null && _port!.isOpen;

  @override
  Stream<List<int>> get onDataReceived => _controller.stream;

  /// ฟังก์ชันเชื่อมต่อกับอุปกรณ์ผ่าน Port Name (เช่น COM3 หรือ /dev/ttyUSB0)
  @override
  Future<void> connect(String portName) async {
    try {
      // 1. สร้าง Instance ของ SerialPort ตามชื่อที่ระบุ
      _port = SerialPort(portName);

      // 2. พยายามเปิด Port ในโหมด Read/Write
      if (!_port!.openReadWrite()) {
        throw Exception(
            "ไม่สามารถเปิด Serial Port: $portName ได้ (อาจถูกโปรแกรมอื่นใช้งานอยู่)");
      }

      // 3. ตั้งค่าพื้นฐานสำหรับ OBDII (Baudrate ปกติคือ 38400 หรือ 115200)
      final config = SerialPortConfig()
        ..baudRate = 38400
        ..bits = 8
        ..stopBits = 1
        ..parity = SerialPortParity.none;
      _port!.config = config;

      // 4. เริ่มฟังข้อมูลที่ไหลเข้ามาแบบ Asynchronous
      _startListening();

      print("เชื่อมต่อ USB Serial สำเร็จ: $portName");
    } catch (e) {
      _port = null;
      rethrow;
    }
  }

  /// ฟังก์ชันส่งข้อมูล Hex ออกไปยังรถ
  @override
  Future<List<int>> send(List<int> data) async {
    if (!isConnected) throw Exception("ไม่ได้เชื่อมต่อ USB Serial");

    // ส่งข้อมูลในรูปแบบ Uint8List
    final bytesWritten = _port!.write(Uint8List.fromList(data));

    if (bytesWritten < 0) {
      throw Exception("ส่งข้อมูลล้มเหลว");
    }

    return []; // ข้อมูลตอบกลับจะไหลกลับมาทาง Stream onDataReceived
  }

  /// ฟังก์ชันตัดการเชื่อมต่อและคืนทรัพยากร
  @override
  Future<void> disconnect() async {
    _port?.close();
    _port = null;
    print("ตัดการเชื่อมต่อ USB Serial เรียบร้อย");
  }

  /// ฟังก์ชันภายในสำหรับวนลูปรอรับข้อมูล
  void _startListening() {
    Future.delayed(Duration.zero, () async {
      while (isConnected) {
        // อ่านข้อมูลที่มีอยู่ใน Buffer
        if (_port!.bytesAvailable > 0) {
          final data = _port!.read(_port!.bytesAvailable);
          _controller.add(data.toList());
        }
        // พักสักครู่เพื่อไม่ให้กิน CPU มากเกินไป
        await Future.delayed(const Duration(milliseconds: 10));
      }
    });
  }
}
