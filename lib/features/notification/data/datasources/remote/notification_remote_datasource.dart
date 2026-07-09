import 'package:clain_the_run/core/api/api_client.dart';
import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/notification/data/datasources/notification_datasource.dart';
import 'package:clain_the_run/features/notification/data/models/app_notification_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRemoteDatasourceProvider = Provider<INotificationDatasource>((
  ref,
) {
  return NotificationRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class NotificationRemoteDatasource implements INotificationDatasource {
  NotificationRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<AppNotificationApiModel>> getNotifications() async {
    final response = await _apiClient.get(ApiEndpoints.notifications);
    final data = (response.data['data'] as List?) ?? const [];
    return data
        .map(
          (e) => AppNotificationApiModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  @override
  Future<void> markAllRead() async {
    await _apiClient.patch(ApiEndpoints.markAllNotificationsRead);
  }

  @override
  Future<void> markRead(String id) async {
    await _apiClient.patch(ApiEndpoints.markNotificationRead(id));
  }
}
