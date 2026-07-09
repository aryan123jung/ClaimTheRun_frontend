import 'dart:async';

import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_request_entity.dart';
import 'package:clain_the_run/features/addfriend/presentation/view_model/addfriend_view_model.dart';
import 'package:clain_the_run/features/notification/domain/entities/app_notification_entity.dart';
import 'package:clain_the_run/features/notification/presentation/state/notification_state.dart';
import 'package:clain_the_run/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:clain_the_run/features/notification/presentation/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(notificationViewModelProvider.notifier).loadNotifications(),
    );
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      ref.read(notificationViewModelProvider.notifier).loadNotifications();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(notificationViewModelProvider);

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
                  TextButton(
                    onPressed: state.notifications.isEmpty
                        ? null
                        : () {
                            ref
                                .read(notificationViewModelProvider.notifier)
                                .markAllRead();
                          },
                    child: const Text('Read all'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
            Expanded(child: _NotificationBody(state: state)),
          ],
        ),
      ),
    );
  }
}

class _NotificationBody extends ConsumerWidget {
  const _NotificationBody({required this.state});

  final NotificationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.status == NotificationStatus.loading &&
        state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.notifications.isEmpty) {
      return Center(
        child: TextButton(
          onPressed: () {
            ref
                .read(notificationViewModelProvider.notifier)
                .loadNotifications();
          },
          child: Text(state.errorMessage!),
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return const Center(child: Text('No notifications yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: state.notifications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = state.notifications[index];
        return NotificationTile(
          notification: _toUiModel(item),
          onTap: () {
            ref.read(notificationViewModelProvider.notifier).markRead(item);
          },
          onPrimaryAction: _isPendingFriendRequest(item)
              ? () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final message = await ref
                      .read(addFriendViewModelProvider.notifier)
                      .acceptRequest(_requestFromNotification(item));
                  ref
                      .read(notificationViewModelProvider.notifier)
                      .removeNotification(item.id);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(message ?? 'Friend request accepted.'),
                    ),
                  );
                }
              : null,
          onSecondaryAction: _isPendingFriendRequest(item)
              ? () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final message = await ref
                      .read(addFriendViewModelProvider.notifier)
                      .rejectRequest(_requestFromNotification(item));
                  ref
                      .read(notificationViewModelProvider.notifier)
                      .removeNotification(item.id);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(message ?? 'Friend request rejected.'),
                    ),
                  );
                }
              : null,
        );
      },
    );
  }

  AppNotificationModel _toUiModel(AppNotificationEntity item) {
    return AppNotificationModel(
      title: item.title,
      message: item.message,
      timeLabel: formatNotificationTime(item.createdAt),
      avatarUrl:
          (item.actorProfileUrl != null && item.actorProfileUrl!.isNotEmpty)
          ? ApiEndpoints.profileImageUrl(item.actorProfileUrl!)
          : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(item.actorName)}&background=E6F3DC&color=3B6D11',
      type: mapNotificationType(item.type),
      isUnread: !item.isRead,
      primaryActionLabel: _isPendingFriendRequest(item) ? 'Accept' : null,
      secondaryActionLabel: _isPendingFriendRequest(item) ? 'Reject' : null,
    );
  }

  bool _isPendingFriendRequest(AppNotificationEntity item) {
    return item.type == 'FRIEND_REQUEST_SENT' && item.requestId != null;
  }

  FriendRequestEntity _requestFromNotification(AppNotificationEntity item) {
    return FriendRequestEntity(
      id: item.requestId!,
      status: 'PENDING',
      isIncoming: true,
      createdAt: item.createdAt,
      userId: '',
      fullname: item.actorName,
      username: item.actorUsername,
      profileUrl: item.actorProfileUrl,
    );
  }
}

NotificationType mapNotificationType(String type) {
  switch (type) {
    case 'FRIEND_REQUEST_ACCEPTED':
      return NotificationType.friendRequest;
    case 'FRIEND_REQUEST_SENT':
      return NotificationType.friendRequest;
    default:
      return NotificationType.friendRequest;
  }
}

String formatNotificationTime(DateTime createdAt) {
  final difference = DateTime.now().difference(createdAt);
  if (difference.inMinutes < 1) return 'now';
  if (difference.inHours < 1) return '${difference.inMinutes}m';
  if (difference.inDays < 1) return '${difference.inHours}h';
  if (difference.inDays == 1) return '1d';
  return '${difference.inDays}d';
}
