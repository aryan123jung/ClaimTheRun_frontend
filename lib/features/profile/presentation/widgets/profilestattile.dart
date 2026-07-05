import 'package:flutter/material.dart';

class ProfileStatModel {
  const ProfileStatModel({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
}

/// A single stat tile (icon, big value, label) used in the profile's
/// "My Stats" preview row.
class ProfileStatTile extends StatelessWidget {
  const ProfileStatTile({
    super.key,
    required this.stat,
    this.showDivider = true,
  });

  final ProfileStatModel stat;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            right: showDivider
                ? const BorderSide(color: Color(0xFFD8D8D5))
                : BorderSide.none,
          ),
        ),
        child: Column(
          children: [
            Icon(stat.icon, size: 26, color: stat.iconColor),
            const SizedBox(height: 12),
            Text(
              stat.value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6E6E6E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}