import 'package:clain_the_run/features/addfriend/domain/entities/friend_request_entity.dart';

class FriendRequestApiModel {
  const FriendRequestApiModel({
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

  factory FriendRequestApiModel.fromJson(Map<String, dynamic> json) {
    final user = Map<String, dynamic>.from(json['user'] as Map);
    return FriendRequestApiModel(
      id: json['id'].toString(),
      status: json['status']?.toString() ?? 'PENDING',
      isIncoming: json['isIncoming'] == true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      userId: user['id']?.toString() ?? '',
      fullname: user['fullname']?.toString() ?? '',
      username: user['username']?.toString() ?? '',
      profileUrl: user['profileUrl']?.toString(),
    );
  }

  FriendRequestEntity toEntity() => FriendRequestEntity(
    id: id,
    status: status,
    isIncoming: isIncoming,
    createdAt: createdAt,
    userId: userId,
    fullname: fullname,
    username: username,
    profileUrl: profileUrl,
  );
}
