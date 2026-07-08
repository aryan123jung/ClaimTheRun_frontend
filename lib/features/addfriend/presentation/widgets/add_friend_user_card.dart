import 'package:flutter/material.dart';

class AddFriendUserModel {
  const AddFriendUserModel({
    required this.name,
    required this.avatarUrl,
    required this.mutualFriends,
    required this.subtitle,
    this.isIncomingRequest = false,
  });

  final String name;
  final String avatarUrl;
  final int mutualFriends;
  final String subtitle;
  final bool isIncomingRequest;
}

class AddFriendUserCard extends StatelessWidget {
  const AddFriendUserCard({
    super.key,
    required this.user,
    required this.primaryLabel,
    required this.onPrimaryTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  final AddFriendUserModel user;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E7E3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF181818),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6F6F6F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.mutualFriends} mutual friends',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8F8F8F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                label: primaryLabel,
                onTap: onPrimaryTap,
                isPrimary: true,
              ),
              if (secondaryLabel != null && onSecondaryTap != null) ...[
                const SizedBox(height: 8),
                _ActionButton(
                  label: secondaryLabel!,
                  onTap: onSecondaryTap!,
                  isPrimary: false,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF55A63A) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFF55A63A)
                : const Color(0xFFD8D8D5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isPrimary ? Colors.white : const Color(0xFF606060),
          ),
        ),
      ),
    );
  }
}
