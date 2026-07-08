import 'package:flutter/material.dart';

class FriendModel {
  const FriendModel({
    required this.name,
    required this.avatarUrl,
    required this.totalKm,
    required this.territories,
  });

  final String name;
  final String avatarUrl;
  final double totalKm;
  final int territories;
}

/// A single row in the friends list: avatar, name, stats, message and
/// overflow actions.
class FriendCard extends StatelessWidget {
  const FriendCard({
    super.key,
    required this.friend,
    this.onTap,
    this.onMessage,
    this.onMorePressed,
  });

  final FriendModel friend;
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
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(friend.avatarUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${friend.totalKm.toStringAsFixed(0)} km total',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF9BA8B4)
                            : const Color(0xFF9A9A9A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: _brandGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Territories: ${friend.territories}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFFB3BEC8)
                                : const Color(0xFF6E6E6E),
                          ),
                        ),
                      ],
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
