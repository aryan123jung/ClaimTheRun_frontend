import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class PostModel {
  const PostModel({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.timestamp,
    required this.caption,
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String timestamp;
  final String caption;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
}

String formatPostTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return 'Just now';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }

  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${monthNames[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFEDEDEA),
        ),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        post.timestamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9BA8B4)
                              : const Color(0xFF9A9A9A),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onMorePressed,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF9BA8B4)
                        : const Color(0xFF6E6E6E),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
          if (post.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 11,
              child: _PostImage(imageUrl: post.imageUrl!),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Row(
              children: [
                _ActionChip(
                  icon: post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: post.isLiked
                      ? _brandGreen
                      : const Color(0xFF6E6E6E),
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

class _PostImage extends StatelessWidget {
  const _PostImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image/')) {
      return Image.memory(
        _decodeDataImage(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    return Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity);
  }

  Uint8List _decodeDataImage(String dataUrl) {
    final base64Part = dataUrl.split(',').last;
    return base64Decode(base64Part);
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
