import 'package:flutter/material.dart';

enum NotificationType { friendRequest, like, comment, groupPost }

class AppNotificationModel {
  const AppNotificationModel({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.avatarUrl,
    required this.type,
    this.isUnread = false,
  });

  final String title;
  final String message;
  final String timeLabel;
  final String avatarUrl;
  final NotificationType type;
  final bool isUnread;
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, this.onTap});

  final AppNotificationModel notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? (notification.isUnread
                    ? const Color(0xFF17251B)
                    : const Color(0xFF111C26))
              : (notification.isUnread
                    ? const Color(0xFFF6FBF1)
                    : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF233241)
                : (notification.isUnread
                      ? const Color(0xFFDCECCF)
                      : const Color(0xFFE7E7E3)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(notification.avatarUrl),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _accentColor(notification.type),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      _icon(notification.type),
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF181818),
                          ),
                        ),
                      ),
                      Text(
                        notification.timeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF9BA8B4)
                              : const Color(0xFF8E8E8E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark
                          ? const Color(0xFFB3BEC8)
                          : const Color(0xFF696969),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return Icons.person_add_alt_1_rounded;
      case NotificationType.like:
        return Icons.favorite_rounded;
      case NotificationType.comment:
        return Icons.mode_comment_rounded;
      case NotificationType.groupPost:
        return Icons.groups_rounded;
    }
  }

  static Color _accentColor(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return const Color(0xFF55A63A);
      case NotificationType.like:
        return const Color(0xFFE1516A);
      case NotificationType.comment:
        return const Color(0xFF4A8FE7);
      case NotificationType.groupPost:
        return const Color(0xFF8A66D9);
    }
  }
}
