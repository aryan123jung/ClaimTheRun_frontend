import 'package:clain_the_run/features/notification/presentation/widgets/notification_tile.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const _notifications = [
    AppNotificationModel(
      title: 'Friend Request',
      message: 'Nabin Shrestha sent you a friend request.',
      timeLabel: '2m',
      avatarUrl: 'https://i.pravatar.cc/150?img=52',
      type: NotificationType.friendRequest,
      isUnread: true,
    ),
    AppNotificationModel(
      title: 'New Like',
      message: 'Ram Khadka liked your post: "How\'s the view???"',
      timeLabel: '15m',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      type: NotificationType.like,
      isUnread: true,
    ),
    AppNotificationModel(
      title: 'New Comment',
      message: 'Riya Kapoor commented: "That route looks amazing!"',
      timeLabel: '48m',
      avatarUrl: 'https://i.pravatar.cc/150?img=25',
      type: NotificationType.comment,
    ),
    AppNotificationModel(
      title: 'Group Post',
      message: 'The Runners shared a new post about this weekend\'s group run.',
      timeLabel: '1h',
      avatarUrl: 'https://i.pravatar.cc/150?img=41',
      type: NotificationType.groupPost,
      isUnread: true,
    ),
    AppNotificationModel(
      title: 'Friend Request',
      message: 'Prerana Thapa wants to connect with you.',
      timeLabel: 'Yesterday',
      avatarUrl: 'https://i.pravatar.cc/150?img=48',
      type: NotificationType.friendRequest,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 18, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: isDark ? Colors.white : const Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'Friend requests, likes, comments, and group posts.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF9BA8B4)
                      : const Color(0xFF707070),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return NotificationTile(notification: _notifications[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
