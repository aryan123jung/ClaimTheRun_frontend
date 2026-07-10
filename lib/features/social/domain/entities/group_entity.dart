class GroupCreatorEntity {
  const GroupCreatorEntity({
    required this.id,
    required this.fullname,
    required this.username,
    this.profileUrl,
  });

  final String id;
  final String fullname;
  final String username;
  final String? profileUrl;
}

class GroupEntity {
  const GroupEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.memberCount,
    required this.isJoined,
    required this.creator,
    required this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String? imageUrl;
  final int memberCount;
  final bool isJoined;
  final GroupCreatorEntity creator;
  final DateTime createdAt;

  GroupEntity copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? imageUrl,
    int? memberCount,
    bool? isJoined,
    GroupCreatorEntity? creator,
    DateTime? createdAt,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
      creator: creator ?? this.creator,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
