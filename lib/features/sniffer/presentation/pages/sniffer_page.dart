import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

/// โมเดลจำลองข้อมูล Packet ของ CAN Bus
class CanPacket {
  final DateTime timestamp;
  final String id;
  final List<int> data;

  CanPacket({required this.timestamp, required this.id, required this.data});
}

/// หน้าจอ Sniffer สำหรับดักจับข้อมูลบน CAN Bus
/// ออกแบบมาให้ดู Raw Data (request/response hex) แบบเรียลไทม์
class SnifferPage extends StatefulWidget {
  const SnifferPage({super.key});

  @override
  State<SnifferPage> createState() => _SnifferPageState();
}

class _SnifferPageState extends State<SnifferPage> {
  final List<CanPacket> _packets = [];
  bool _isAutoScroll = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // จำลองการรับข้อมูล (ในระบบจริงจะรับมาจาก Hardware Stream)
    _mockIncomingData();
  }

  /// จำลองการดักจับข้อมูลเพื่อใช้ในการพัฒนา UI
  void _mockIncomingData() {
    Stream.periodic(const Duration(milliseconds: 500)).listen((_) {
      if (mounted) {
        setState(() {
          _packets.add(CanPacket(
            timestamp: DateTime.now(),
            id: (0x7E0 + _packets.length % 8).toRadixString(16).toUpperCase(),
            data: [0x03, 0x22, 0xF1, 0x90, 0x00, 0x00, 0x00, 0x00],
          ));

          // เก็บประวัติไว้สูงสุด 100 บรรทัดเพื่อไม่ให้เครื่องช้า
          if (_packets.length > 100) _packets.removeAt(0);

          if (_isAutoScroll) _scrollToBottom();
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CAN BUS SNIFFER"),
        actions: [
          IconButton(
            icon:
                Icon(_isAutoScroll ? Icons.vertical_align_bottom : Icons.pause),
            onPressed: () => setState(() => _isAutoScroll = !_isAutoScroll),
            tooltip: "Auto Scroll",
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => setState(() => _packets.clear()),
            tooltip: "Clear Logs",
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Table
          Container(
            color: Colors.white10,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text("TIME",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text("ID",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 6,
                    child: Text("DATA (HEX)",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Packet List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _packets.length,
              itemBuilder: (context, index) {
                final packet = _packets[index];
                return _buildPacketRow(packet);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacketRow(CanPacket packet) {
    final timeStr =
        "${packet.timestamp.minute}:${packet.timestamp.second}.${packet.timestamp.millisecond}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
            bottom:
                BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(timeStr,
                  style: const TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(
              flex: 2,
              child: Text("0x${packet.id}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary))),
          Expanded(
              flex: 6,
              child: Text(
                packet.data
                    .map((e) =>
                        e.toRadixString(16).padLeft(2, '0').toUpperCase())
                    .join(" "),
                style: const TextStyle(
                    fontFamily: 'monospace', color: Colors.white70),
              )),
        ],
      ),
    );
  }
}
