import 'package:clain_the_run/features/home/presentation/widgets/run_route_map_preview.dart';
import 'package:clain_the_run/features/leaderboard/map/data/models/run_record.dart';
import 'package:flutter/material.dart';

class ActivityModel {
  const ActivityModel({
    required this.title,
    required this.subtitle,
    required this.distanceKm,
    required this.totalTime,
    required this.avgPace,
    required this.calories,
  });

  final String title;
  final String subtitle;
  final double distanceKm;
  final String totalTime;
  final String avgPace;
  final int calories;

  factory ActivityModel.fromRunRecord(RunRecord run) {
    final createdAt = run.createdAt?.toLocal();
    return ActivityModel(
      title: run.hasTerritory ? 'Territory Run' : 'Run Activity',
      subtitle: _formatSubtitle(createdAt),
      distanceKm: run.distanceMeters / 1000,
      totalTime: _formatDuration(run.durationSeconds),
      avgPace: _formatPace(run.distanceMeters, run.durationSeconds),
      calories: _estimateCalories(run.distanceMeters),
    );
  }

  static String _formatSubtitle(DateTime? value) {
    if (value == null) return 'Recent run';
    final now = DateTime.now();
    final sameDay =
        now.year == value.year &&
        now.month == value.month &&
        now.day == value.day;
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    if (sameDay) {
      return 'Today, $hour:$minute $suffix';
    }
    const months = <String>[
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
    return '${months[value.month - 1]} ${value.day}, $hour:$minute $suffix';
  }

  static String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  static String _formatPace(double distanceMeters, int durationSeconds) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return "0'00\"";
    final secondsPerKm = durationSeconds / (distanceMeters / 1000);
    final minutes = secondsPerKm ~/ 60;
    final seconds = (secondsPerKm.round() % 60).toString().padLeft(2, '0');
    return "$minutes'$seconds\"";
  }

  static int _estimateCalories(double distanceMeters) {
    final km = distanceMeters / 1000;
    return (km * 68).round();
  }
}

/// A single row in the "Recent Activity" list. Tapping it opens the
/// full run details popup (see run_details_sheet.dart).
class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity, this.onTap});

  final ActivityModel activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF111C26) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF233241) : const Color(0xFFD9D9D9),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark
                      ? const Color(0xFF1C2A36)
                      : const Color(0xFFE9E9E9),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const RunRouteMapPreview(zoom: 13.8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF111111),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.subtitle,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9BA8B4)
                            : const Color(0xFF9A9A9A),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${activity.distanceKm.toStringAsFixed(2)} km',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF9BA8B4)
                      : const Color(0xFF848484),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: isDark
                    ? const Color(0xFF9BA8B4)
                    : const Color(0xFF646464),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
