import 'package:flutter/material.dart';

class GroupModel {
  const GroupModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.memberCount,
    this.description = '',
    this.totalKm = 0,
    this.isJoined = false,
  });

  final String id;
  final String name;
  final String iconUrl;
  final int memberCount;
  final String description;
  final double totalKm;
  final bool isJoined;
}

/// A single row in the joined-groups list: group icon, name, member
/// count, total distance, message and overflow actions.
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
    this.onMessage,
    this.onMorePressed,
  });

  final GroupModel group;
  final VoidCallback? onTap;
  final VoidCallback? onMessage;
  final VoidCallback? onMorePressed;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111C26) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF233241) : const Color(0xFFEDEDEA),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF233241)
                        : const Color(0xFFE4E4E1),
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    group.iconUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _GroupAvatarFallback(name: group.name);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${group.memberCount} members',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _brandGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total km: ${group.totalKm.toStringAsFixed(0)}',
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
              _CircleIconButton(
                icon: Icons.chat_bubble_rounded,
                backgroundColor: _brandGreen.withValues(alpha: 0.65),
                iconColor: Colors.white,
                onTap: onMessage,
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onMorePressed,
                icon: Icon(
                  Icons.more_horiz_rounded,
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
      ),
    );
  }
}

class _GroupAvatarFallback extends StatelessWidget {
  const _GroupAvatarFallback({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE6F3DC),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: Color(0xFF3B6D11),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return 'G';
    return parts.map((part) => part[0].toUpperCase()).join();
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 17, color: iconColor),
        ),
      ),
    );
  }
}
