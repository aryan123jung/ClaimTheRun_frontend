class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.distanceKm,
    required this.time,
    this.isCurrentUser = false,
  });

  final int rank;
  final String name;
  final String avatarUrl;
  final double distanceKm;
  final String time;
  final bool isCurrentUser;
}

class GroupLeaderboardEntry {
  const GroupLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.membersCount,
    required this.distanceKm,
    required this.time,
  });

  final int rank;
  final String name;
  final String avatarUrl;
  final int membersCount;
  final double distanceKm;
  final String time;
}
