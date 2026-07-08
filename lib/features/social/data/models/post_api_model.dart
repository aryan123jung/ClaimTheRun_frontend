import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';

class PostApiModel {
  const PostApiModel({
    required this.id,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.createdAt,
    required this.author,
    this.imageUrl,
  });

  final String id;
  final String caption;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;
  final PostAuthorApiModel author;

  factory PostApiModel.fromJson(Map<String, dynamic> json) {
    return PostApiModel(
      id: json['id'].toString(),
      caption: json['caption']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] == true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      author: PostAuthorApiModel.fromJson(
        Map<String, dynamic>.from(json['author'] as Map),
      ),
    );
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      caption: caption,
      imageUrl: imageUrl,
      likeCount: likeCount,
      commentCount: commentCount,
      isLiked: isLiked,
      createdAt: createdAt,
      author: author.toEntity(),
    );
  }
}

class PostAuthorApiModel {
  const PostAuthorApiModel({
    required this.id,
    required this.fullname,
    required this.username,
    this.profileUrl,
  });

  final String id;
  final String fullname;
  final String username;
  final String? profileUrl;

  factory PostAuthorApiModel.fromJson(Map<String, dynamic> json) {
    return PostAuthorApiModel(
      id: json['id']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? 'Unknown Runner',
      username: json['username']?.toString() ?? '',
      profileUrl: json['profileUrl']?.toString(),
    );
  }

  PostAuthorEntity toEntity() {
    return PostAuthorEntity(
      id: id,
      fullname: fullname,
      username: username,
      profileUrl: profileUrl,
    );
  }
}
