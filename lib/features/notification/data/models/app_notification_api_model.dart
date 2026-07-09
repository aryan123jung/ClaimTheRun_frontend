import 'package:clain_the_run/features/notification/domain/entities/app_notification_entity.dart';

class AppNotificationApiModel {
  const AppNotificationApiModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.actorName,
    required this.actorUsername,
    this.actorProfileUrl,
    this.requestId,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String actorName;
  final String actorUsername;
  final String? actorProfileUrl;
  final String? requestId;

  factory AppNotificationApiModel.fromJson(Map<String, dynamic> json) {
    final actor = Map<String, dynamic>.from(json['actor'] as Map);
    return AppNotificationApiModel(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'FRIEND_REQUEST_SENT',
      isRead: json['isRead'] == true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      actorName: actor['fullname']?.toString() ?? 'Runner',
      actorUsername: actor['username']?.toString() ?? '',
      actorProfileUrl: actor['profileUrl']?.toString(),
      requestId: json['requestId']?.toString(),
    );
  }

  AppNotificationEntity toEntity() => AppNotificationEntity(
    id: id,
    title: title,
    message: message,
    type: type,
    isRead: isRead,
    createdAt: createdAt,
    actorName: actorName,
    actorUsername: actorUsername,
    actorProfileUrl: actorProfileUrl,
    requestId: requestId,
  );
}
