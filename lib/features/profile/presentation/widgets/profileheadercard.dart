import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.runCount,
    required this.territoryCount,
    required this.postCount,
    this.onEditAvatar,
    this.onEditProfile,
  });

  final String name;
  final String bio;
  final String avatarUrl;
  final int runCount;
  final int territoryCount;
  final int postCount;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditProfile;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarProvider = _buildAvatarProvider(avatarUrl);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFD8D8D5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: avatarProvider,
                child: avatarProvider == null
                    ? const Icon(Icons.person_rounded, size: 42)
                    : null,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Material(
                  color: _brandGreen,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onEditAvatar,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  bio,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF9BA8B4)
                        : const Color(0xFF6E6E6E),
                  ),
                ),
                const SizedBox(height: 10),
                if (onEditProfile != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: onEditProfile,
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _brandGreen,
                        side: BorderSide(
                          color: _brandGreen.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF16222E)
                        : const Color(0xFFFAFAF8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF233241)
                          : const Color(0xFFEAEAE6),
                    ),
                  ),
                  child: Row(
                    children: [
                      _CountColumn(value: runCount, label: 'Runs'),
                      _Divider(),
                      _CountColumn(value: territoryCount, label: 'Territories'),
                      _Divider(),
                      _CountColumn(value: postCount, label: 'Posts'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider<Object>? _buildAvatarProvider(String value) {
    if (value.isEmpty) return null;

    return NetworkImage(value);
  }
}

class _CountColumn extends StatelessWidget {
  const _CountColumn({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF8FA0AE) : const Color(0xFF909090),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 1,
      height: 44,
      color: isDark ? const Color(0xFF233241) : const Color(0xFFE3E3E0),
    );
  }
}
