import 'package:flutter/material.dart';

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isLastMessageMine = false,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final bool isLastMessageMine;
}

/// A single row in the messages list: avatar (with online dot), name,
/// last message preview, timestamp, and an unread-count badge.
class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.conversation, this.onTap});

  final ConversationModel conversation;
  final VoidCallback? onTap;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD8D8D5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(conversation.avatarUrl),
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _brandGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (conversation.isLastMessageMine)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.done_all_rounded,
                              size: 15,
                              color: Color(0xFF6E6E6E),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: hasUnread
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFF6E6E6E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    conversation.timestamp,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                      color: hasUnread ? _brandGreen : const Color(0xFF9A9A9A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _brandGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${conversation.unreadCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
