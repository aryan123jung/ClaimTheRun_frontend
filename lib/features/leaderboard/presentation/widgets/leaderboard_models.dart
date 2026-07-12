class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.rank,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.distanceKm,
    required this.time,
    this.isCurrentUser = false,
  });

  final String id;
  final int rank;
  final String name;
  final String username;
  final String avatarUrl;
  final double distanceKm;
  final String time;
  final bool isCurrentUser;
}

class GroupLeaderboardEntry {
  const GroupLeaderboardEntry({
    required this.id,
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.membersCount,
    required this.distanceKm,
    required this.time,
  });

  final String id;
  final int rank;
  final String name;
  final String avatarUrl;
  final int membersCount;
  final double distanceKm;
  final String time;
}
