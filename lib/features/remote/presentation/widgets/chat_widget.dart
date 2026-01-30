import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/remote/domain/entities/remote_entities.dart';

class ChatWidget extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const ChatWidget({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return _buildMessageBubble(context, msg);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg) {
    final isMe = msg.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.grey[800],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.timestamp),
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
