class RemoteSession {
  final String id;
  final String expertName;
  final bool isActive;
  final DateTime startTime;

  RemoteSession({
    required this.id,
    required this.expertName,
    this.isActive = true,
    required this.startTime,
  });
}

enum MessageType { text, image, system }

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.isMe = false,
  });
}
