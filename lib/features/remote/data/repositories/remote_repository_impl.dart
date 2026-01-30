import 'dart:async';
import 'package:motus_lab/features/remote/domain/entities/remote_entities.dart';
import 'package:motus_lab/features/remote/domain/repositories/remote_repository.dart';

class RemoteRepositoryImpl implements RemoteRepository {
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _statusController = StreamController<bool>.broadcast();
  Timer? _mockReplyTimer;

  @override
  Stream<ChatMessage> get messageStream => _messageController.stream;

  @override
  Stream<bool> get sessionStatus => _statusController.stream;

  @override
  Future<RemoteSession> connectToSession() async {
    // [WORKFLOW] Remote: จำลอง Delay การเชื่อมต่อ 2 วินาที (เสมือนต่อ Server)
    await Future.delayed(const Duration(seconds: 2));

    _statusController.add(true);

    // [WORKFLOW] Remote: จำลองข้อความทักทายอัตโนมัติจากช่าง
    Future.delayed(const Duration(seconds: 1), () {
      _messageController.add(ChatMessage(
        id: DateTime.now().toString(),
        senderId: 'expert',
        content: 'สวัสดีครับ ผมช่างเทคนิคจาก Motus Lab มีอะไรให้ช่วยครับ?',
        timestamp: DateTime.now(),
        isMe: false,
      ));
    });

    return RemoteSession(
      id: 'session_123',
      expertName: 'ช่างสมชาย (Expert)',
      startTime: DateTime.now(),
    );
  }

  @override
  Future<void> sendMessage(String text) async {
    // Add user message to stream (to show in UI immediately if needed,
    // though Bloc usually handles optimistic UI)
    // Here we assume Bloc adds to state directly, but for consistency lets mimic echo

    // Simulate expert typing and replying
    _mockReplyTimer?.cancel();
    _mockReplyTimer = Timer(const Duration(seconds: 2), () {
      String reply = "ครับ เดี๋ยวผมช่วยตรวจสอบดูให้ครับ";
      if (text.contains("DTC")) {
        reply =
            "โค้ด DTC นี้อาจเกิดจากเซ็นเซอร์ O2 เสียหายครับ ลองเช็คแรงดันไฟดูครับ";
      } else if (text.contains("ราคา")) {
        reply = "ค่าบริการขึ้นอยู่กับอะไหล่ครับ ประมาณ 500-1000 บาท";
      }

      _messageController.add(ChatMessage(
        id: DateTime.now().toString(),
        senderId: 'expert',
        content: reply,
        timestamp: DateTime.now(),
        isMe: false,
      ));
    });
  }

  @override
  Future<void> disconnect() async {
    _statusController.add(false);
    _mockReplyTimer?.cancel();
  }
}
