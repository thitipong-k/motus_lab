import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:logger/logger.dart';

/// การเชื่อมต่อผ่าน Bluetooth LE (BLE)
/// ใช้ flutter_blue_plus ในการค้นหาและรับส่งข้อมูลกับ OBDII Dongle
class BleConnection implements ConnectionInterface {
  final Logger _logger = Logger();
  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;

  final _onDataController = StreamController<List<int>>.broadcast();
  StreamSubscription? _notificationSubscription;

  @override
  bool get isConnected =>
      _device != null && FlutterBluePlus.connectedDevices.contains(_device);

  @override
  Stream<List<int>> get onDataReceived => _onDataController.stream;

  @override
  Future<void> connect(String deviceId) async {
    // 1. ตรวจสอบสถานะ Bluetooth
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      throw Exception("Bluetooth adapter is turned off");
    }

    // 2. ค้นหาอุปกรณ์ (deviceId ในที่นี้คาดว่าเป็น MAC Address หรือ ID ของ FlutterBlue)
    _logger.i("Connecting to device: $deviceId");

    // ค้นหาอุปกรณ์ที่เคยเชื่อมต่อไว้แล้ว
    List<BluetoothDevice> connected = await FlutterBluePlus.connectedDevices;
    _device = connected.firstWhere((d) => d.remoteId.str == deviceId,
        orElse: () => throw Exception("Device not found"));

    // 3. เริ่มการเชื่อมต่อ
    await _device!.connect(autoConnect: false);

    // 4. ค้นหา OBD Service และ Characteristic
    // มาตรฐาน OBD2 BLE มักจะใช้ Serial Port Profile (SPP) แบบจำลอง
    // เราต้องหา Characteristic ที่รองรับ Write และ Notify/Indicate
    List<BluetoothService> services = await _device!.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write ||
            characteristic.properties.writeWithoutResponse) {
          _writeCharacteristic = characteristic;
        }
        if (characteristic.properties.notify ||
            characteristic.properties.indicate) {
          _readCharacteristic = characteristic;
        }
      }
    }

    if (_writeCharacteristic == null || _readCharacteristic == null) {
      await disconnect();
      throw Exception("Required OBD2 characteristics not found on this device");
    }

    // 5. ตั้งค่าการดักฟังข้อมูล (Notification)
    await _readCharacteristic!.setNotifyValue(true);
    _notificationSubscription =
        _readCharacteristic!.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        _onDataController.add(value);
      }
    });

    _logger.i("Successfully connected and setup characteristics");
  }

  @override
  Future<void> disconnect() async {
    await _notificationSubscription?.cancel();
    await _device?.disconnect();
    _device = null;
    _writeCharacteristic = null;
    _readCharacteristic = null;
    _logger.i("Disconnected from device");
  }

  @override
  Future<List<int>> send(List<int> data) async {
    if (!isConnected || _writeCharacteristic == null) {
      throw Exception("Not connected to a valid device");
    }

    // ส่งข้อมูล
    await _writeCharacteristic!.write(data, withoutResponse: false);

    // ในระบบ OBD2 ปกติ เรามักจะรอรับผลผ่าน Stream onDataReceived
    // แต่เพื่อความสะดวก เราคืนค่าว่างไปก่อน
    return [];
  }
}
