import 'package:clain_the_run/features/notification/domain/entities/app_notification_entity.dart';

enum NotificationStatus { initial, loading, loaded, action, error }

class NotificationState {
  const NotificationState({
    required this.status,
    required this.notifications,
    this.errorMessage,
  });

  const NotificationState.initial()
    : status = NotificationStatus.initial,
      notifications = const [],
      errorMessage = null;

  final NotificationStatus status;
  final List<AppNotificationEntity> notifications;
  final String? errorMessage;

  NotificationState copyWith({
    NotificationStatus? status,
    List<AppNotificationEntity>? notifications,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
