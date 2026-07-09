import 'package:clain_the_run/features/notification/data/models/app_notification_api_model.dart';

abstract interface class INotificationDatasource {
  Future<List<AppNotificationApiModel>> getNotifications();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}
