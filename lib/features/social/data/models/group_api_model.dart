import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';

class GroupApiModel {
  const GroupApiModel({
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
  final GroupCreatorApiModel creator;
  final DateTime createdAt;

  factory GroupApiModel.fromJson(Map<String, dynamic> json) {
    return GroupApiModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      isJoined: json['isJoined'] == true,
      creator: GroupCreatorApiModel.fromJson(
        Map<String, dynamic>.from(json['creator'] as Map? ?? const {}),
      ),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name,
      slug: slug,
      description: description,
      imageUrl: imageUrl,
      memberCount: memberCount,
      isJoined: isJoined,
      creator: creator.toEntity(),
      createdAt: createdAt,
    );
  }
}

class GroupCreatorApiModel {
  const GroupCreatorApiModel({
    required this.id,
    required this.fullname,
    required this.username,
    this.profileUrl,
  });

  final String id;
  final String fullname;
  final String username;
  final String? profileUrl;

  factory GroupCreatorApiModel.fromJson(Map<String, dynamic> json) {
    return GroupCreatorApiModel(
      id: json['id']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? 'Unknown Runner',
      username: json['username']?.toString() ?? '',
      profileUrl: json['profileUrl']?.toString(),
    );
  }

  GroupCreatorEntity toEntity() {
    return GroupCreatorEntity(
      id: id,
      fullname: fullname,
      username: username,
      profileUrl: profileUrl,
    );
  }
}
