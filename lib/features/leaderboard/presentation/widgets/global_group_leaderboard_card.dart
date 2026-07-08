import 'package:clain_the_run/features/leaderboard/presentation/widgets/leaderboard_models.dart';
import 'package:flutter/material.dart';

class GlobalGroupLeaderboardCard extends StatelessWidget {
  const GlobalGroupLeaderboardCard({super.key, required this.entry});

  final GroupLeaderboardEntry entry;

  static const activeTextGreen = Color(0xFF3B6D11);

  static const _rankColors = {
    1: Color(0xFFB8860B),
    2: Color(0xFF8A8A8A),
    3: Color(0xFFB2703A),
  };

  static const _rankTints = {
    1: Color(0x24E6B540),
    2: Color(0x1EA0A0A0),
    3: Color(0x24C4783C),
  };

  static const _medalEmoji = {1: '🥇', 2: '🥈', 3: '🥉'};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (entry.rank <= 3) {
      return _buildTopRow(isDark);
    }
    return _buildStandardRow(isDark);
  }

  Widget _buildTopRow(bool isDark) {
    final tint = _rankTints[entry.rank]!;
    final medal = _medalEmoji[entry.rank]!;
    final rankColor = _rankColors[entry.rank]!;

    return Container(
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF111C26) : Colors.white,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [tint, tint.withValues(alpha: 0)]),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  medal,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 22,
                backgroundColor: rankColor.withValues(alpha: 0.3),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(entry.avatarUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.membersCount} members',
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
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.distanceKm.toStringAsFixed(0)} km',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: activeTextGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFB3BEC8)
                          : const Color(0xFF4B4B4B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardRow(bool isDark) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          SizedBox(
            width: 30,
            child: Text(
              '${entry.rank}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9A9A9A)),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(entry.avatarUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.membersCount} members',
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
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.distanceKm.toStringAsFixed(0)} km',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5F5E5A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.time,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFFB3BEC8)
                      : const Color(0xFF4B4B4B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
