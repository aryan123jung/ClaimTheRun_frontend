import 'package:flutter/material.dart';

class ChatMessageModel {
  const ChatMessageModel({
    required this.text,
    required this.timestamp,
    required this.isMine,
    this.isRead = false,
  });

  final String text;
  final String timestamp;
  final bool isMine;
  final bool isRead;
}

/// A single chat bubble. Sent messages (isMine) are right-aligned in
/// brand green; received messages are left-aligned in light gray.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessageModel message;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMine
                  ? _brandGreen
                  : (isDark
                        ? const Color(0xFF1B2732)
                        : const Color(0xFFF1F1EF)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMine ? 18 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 18),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: isMine
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.timestamp,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? const Color(0xFF9BA8B4)
                      : const Color(0xFF9A9A9A),
                ),
              ),
              if (isMine) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all_rounded,
                  size: 14,
                  color: message.isRead ? _brandGreen : const Color(0xFF9A9A9A),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
