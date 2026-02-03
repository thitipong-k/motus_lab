import 'dart:convert';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/domain/entities/obd_communication.dart';

/// บริการสำหรับส่งผ่านข้อมูล (Relay) ไปยังช่างเทคนิคทางไกล
/// ใช้ WebSocket ในการรับส่งข้อมูล CAN Bus เพื่อให้วิกฤตความเร็ว (Low Latency)
class WebSocketRelay {
  final ConnectionInterface connection;
  bool _isRelaying = false;

  WebSocketRelay({required this.connection});

  /// เริ่มการส่งผ่านข้อมูลไปยัง Server
  void startRelay(String serverUrl) {
    _isRelaying = true;
    print("เริ่มเชื่อมต่อ Remote Relay ไปยัง: $serverUrl");

    // 1. ฟังข้อมูลจากตัวรถ (Local Connection)
    connection.onDataReceived.listen((data) {
      if (_isRelaying) {
        // 2. แปลงข้อมูลเป็น JSON และส่งขึ้น Server (จำลองการส่ง)
        final packet = jsonEncode({
          "timestamp": DateTime.now().toIso8601String(),
          "payload": data,
        });
        _sendToServer(packet);
      }
    });
  }

  void stopRelay() {
    _isRelaying = false;
    print("หยุดการส่งข้อมูล Relay");
  }

  /// จำลองการส่งข้อมูลไปยัง WebSocket Server
  void _sendToServer(String packet) {
    // ในระบบจริงจะใช้ IOWebSocketChannel.sink.add(packet)
    print("Relaying to Master: $packet");
  }

  /// ฟังก์ชันรับคำสั่งจาก Master (Remote) มาสั่งการเครื่องยนต์
  void handleRemoteCommand(List<int> command) {
    print("รับคำสั่งจากช่างทางไกล: $command");
    // แปลง List<int> เป็น Hex String (เช่น [0x01, 0x0C] -> "010C")
    final cmdString = command
        .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
        .join('');
    connection.send(ObdRequest(command: cmdString));
  }
}
