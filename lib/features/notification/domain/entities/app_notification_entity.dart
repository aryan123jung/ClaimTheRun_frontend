class AppNotificationEntity {
  const AppNotificationEntity({
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
}
