import 'package:clain_the_run/features/notification/domain/entities/app_notification_entity.dart';
import 'package:clain_the_run/features/notification/domain/usecases/notification_usecases.dart';
import 'package:clain_the_run/features/notification/presentation/state/notification_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
      NotificationViewModel.new,
    );

class NotificationViewModel extends Notifier<NotificationState> {
  late final GetNotificationsUsecase _getNotificationsUsecase;
  late final MarkNotificationReadUsecase _markNotificationReadUsecase;
  late final MarkAllNotificationsReadUsecase _markAllNotificationsReadUsecase;

  @override
  NotificationState build() {
    _getNotificationsUsecase = ref.read(getNotificationsUsecaseProvider);
    _markNotificationReadUsecase = ref.read(
      markNotificationReadUsecaseProvider,
    );
    _markAllNotificationsReadUsecase = ref.read(
      markAllNotificationsReadUsecaseProvider,
    );
    return const NotificationState.initial();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(
      status: NotificationStatus.loading,
      clearError: true,
    );
    final result = await _getNotificationsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.message,
      ),
      (items) => state = state.copyWith(
        status: NotificationStatus.loaded,
        notifications: items,
        clearError: true,
      ),
    );
  }

  Future<void> markRead(AppNotificationEntity item) async {
    if (item.isRead) return;
    final result = await _markNotificationReadUsecase(
      NotificationIdParams(id: item.id),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: NotificationStatus.loaded,
        notifications: [
          for (final n in state.notifications)
            if (n.id == item.id)
              AppNotificationEntity(
                id: n.id,
                title: n.title,
                message: n.message,
                type: n.type,
                isRead: true,
                createdAt: n.createdAt,
                actorName: n.actorName,
                actorUsername: n.actorUsername,
                actorProfileUrl: n.actorProfileUrl,
                requestId: n.requestId,
              )
            else
              n,
        ],
        clearError: true,
      ),
    );
  }

  Future<void> markAllRead() async {
    final result = await _markAllNotificationsReadUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: NotificationStatus.loaded,
        notifications: [
          for (final n in state.notifications)
            AppNotificationEntity(
              id: n.id,
              title: n.title,
              message: n.message,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
              actorName: n.actorName,
              actorUsername: n.actorUsername,
              actorProfileUrl: n.actorProfileUrl,
              requestId: n.requestId,
            ),
        ],
        clearError: true,
      ),
    );
  }

  void removeNotification(String notificationId) {
    state = state.copyWith(
      notifications: state.notifications
          .where((item) => item.id != notificationId)
          .toList(),
    );
  }
}
