import 'package:flutter/material.dart';

/// A single row in the messages list: avatar (with online dot), name,
/// last message preview, timestamp, and an unread-count badge.
class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isLastMessageMine = false,
    this.onTap,
  });

  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final bool isLastMessageMine;
  final VoidCallback? onTap;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF111C26) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF233241) : const Color(0xFFD8D8D5),
            ),
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
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  if (isOnline)
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
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (isLastMessageMine)
                          Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.done_all_rounded,
                              size: 15,
                              color: isDark
                                  ? const Color(0xFF9BA8B4)
                                  : const Color(0xFF6E6E6E),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: hasUnread
                                  ? (isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A))
                                  : (isDark
                                        ? const Color(0xFFB3BEC8)
                                        : const Color(0xFF6E6E6E)),
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
                    timestamp,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                      color: hasUnread
                          ? _brandGreen
                          : (isDark
                                ? const Color(0xFF9BA8B4)
                                : const Color(0xFF9A9A9A)),
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
                        '$unreadCount',
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
