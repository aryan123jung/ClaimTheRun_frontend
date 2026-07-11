import 'package:clain_the_run/features/leaderboard/map/data/models/run_record.dart';

class FriendRunSummary {
  const FriendRunSummary({
    required this.totalKm,
    required this.territories,
    required this.totalRuns,
    required this.totalDurationSeconds,
    required this.totalDistanceMeters,
    required this.calories,
  });

  const FriendRunSummary.empty()
    : totalKm = 0,
      territories = 0,
      totalRuns = 0,
      totalDurationSeconds = 0,
      totalDistanceMeters = 0,
      calories = 0;

  final double totalKm;
  final int territories;
  final int totalRuns;
  final int totalDurationSeconds;
  final double totalDistanceMeters;
  final int calories;

  String get totalTime => formatDuration(totalDurationSeconds);
  String get avgPace => formatPace(totalDistanceMeters, totalDurationSeconds);
  String get formattedCalories => formatNumber(calories);

  static FriendRunSummary fromRuns(List<RunRecord> runs) {
    final totalDistanceMeters = runs.fold<double>(
      0,
      (sum, run) => sum + run.distanceMeters,
    );
    final totalDurationSeconds = runs.fold<int>(
      0,
      (sum, run) => sum + run.durationSeconds,
    );
    return FriendRunSummary(
      totalKm: totalDistanceMeters / 1000,
      territories: runs.where((run) => run.hasTerritory).length,
      totalRuns: runs.length,
      totalDurationSeconds: totalDurationSeconds,
      totalDistanceMeters: totalDistanceMeters,
      calories: runs.fold<int>(
        0,
        (sum, run) => sum + ((run.distanceMeters / 1000) * 68).round(),
      ),
    );
  }

  static String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static String formatPace(double distanceMeters, int durationSeconds) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return "0'00\"";
    final secondsPerKm = durationSeconds / (distanceMeters / 1000);
    final minutes = secondsPerKm ~/ 60;
    final seconds = (secondsPerKm.round() % 60).toString().padLeft(2, '0');
    return "$minutes'$seconds\"";
  }

  static String formatNumber(int value) {
    final digits = value.toString();
    final parts = <String>[];
    for (int end = digits.length; end > 0; end -= 3) {
      final start = (end - 3).clamp(0, digits.length);
      parts.insert(0, digits.substring(start, end));
    }
    return parts.join(',');
  }
}
