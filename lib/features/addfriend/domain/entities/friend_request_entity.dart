class FriendRequestEntity {
  const FriendRequestEntity({
    required this.id,
    required this.status,
    required this.isIncoming,
    required this.createdAt,
    required this.userId,
    required this.fullname,
    required this.username,
    this.profileUrl,
  });

  final String id;
  final String status;
  final bool isIncoming;
  final DateTime createdAt;
  final String userId;
  final String fullname;
  final String username;
  final String? profileUrl;
}
