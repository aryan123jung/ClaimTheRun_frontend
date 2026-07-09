class FriendUserEntity {
  const FriendUserEntity({
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

  FriendUserEntity copyWith({
    String? id,
    String? fullname,
    String? username,
    String? profileUrl,
    int? mutualFriends,
    String? friendStatus,
    String? requestId,
  }) {
    return FriendUserEntity(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      username: username ?? this.username,
      profileUrl: profileUrl ?? this.profileUrl,
      mutualFriends: mutualFriends ?? this.mutualFriends,
      friendStatus: friendStatus ?? this.friendStatus,
      requestId: requestId ?? this.requestId,
    );
  }
}
