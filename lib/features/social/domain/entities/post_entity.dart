class PostAuthorEntity {
  const PostAuthorEntity({
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

class PostEntity {
  const PostEntity({
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
  final PostAuthorEntity author;

  PostEntity copyWith({
    String? id,
    String? caption,
    String? imageUrl,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    DateTime? createdAt,
    PostAuthorEntity? author,
  }) {
    return PostEntity(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
    );
  }
}
