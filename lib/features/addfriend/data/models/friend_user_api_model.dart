import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';

class FriendUserApiModel {
  const FriendUserApiModel({
    required this.id,
    required this.fullname,
    required this.username,
    required this.mutualFriends,
    required this.friendStatus,
    this.profileUrl,
    this.requestId,
  });

  final String id;
  final String fullname;
  final String username;
  final String? profileUrl;
  final int mutualFriends;
  final String friendStatus;
  final String? requestId;

  factory FriendUserApiModel.fromJson(Map<String, dynamic> json) {
    return FriendUserApiModel(
      id: json['id'].toString(),
      fullname: json['fullname']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profileUrl: json['profileUrl']?.toString(),
      mutualFriends: (json['mutualFriends'] as num?)?.toInt() ?? 0,
      friendStatus: json['friendStatus']?.toString() ?? 'NONE',
      requestId: json['requestId']?.toString(),
    );
  }

  FriendUserEntity toEntity() => FriendUserEntity(
    id: id,
    fullname: fullname,
    username: username,
    profileUrl: profileUrl,
    mutualFriends: mutualFriends,
    friendStatus: friendStatus,
    requestId: requestId,
  );
}
