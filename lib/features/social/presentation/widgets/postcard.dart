import 'package:flutter/material.dart';

class PostModel {
  const PostModel({
    required this.authorName,
    required this.authorAvatarUrl,
    required this.timestamp,
    required this.caption,
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  final String authorName;
  final String authorAvatarUrl;
  final String timestamp;
  final String caption;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
}

/// A single post in the social feed: author header, caption, optional
/// image, and like/comment actions.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onMorePressed,
  });

  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onMorePressed;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEDEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(post.authorAvatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        post.timestamp,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A9A9A),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onMorePressed,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: Color(0xFF6E6E6E),
                  ),
                  splashRadius: 18,
                ),
              ],
            ),
          ),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                post.caption,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          if (post.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 11,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Row(
              children: [
                _ActionChip(
                  icon: post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: post.isLiked ? _brandGreen : const Color(0xFF6E6E6E),
                  label: '${post.likeCount}',
                  onTap: onLike,
                ),
                const SizedBox(width: 6),
                _ActionChip(
                  icon: Icons.mode_comment_outlined,
                  iconColor: const Color(0xFF6E6E6E),
                  label: '${post.commentCount}',
                  onTap: onComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 19, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}