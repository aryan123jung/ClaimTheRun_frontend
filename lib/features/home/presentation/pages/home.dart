import 'dart:math';

import 'package:clain_the_run/features/notification/presentation/pages/notification.dart';
import 'package:clain_the_run/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:clain_the_run/features/home/presentation/widgets/activitycard.dart';
import 'package:clain_the_run/features/home/presentation/widgets/rundetails.dart';
import 'package:clain_the_run/features/leaderboard/map/data/datasources/run_api_service.dart';
import 'package:clain_the_run/features/leaderboard/map/data/models/run_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

enum RunMode { solo, group }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  RunMode _selectedRunMode = RunMode.solo;
  final RunApiService _runApiService = RunApiService();
  List<RunRecord> _recentRuns = const <RunRecord>[];
  bool _isLoadingRecentRuns = true;

  @override
  void initState() {
    super.initState();
    _loadRecentRuns();
  }

  Future<void> _loadRecentRuns() async {
    try {
      final runs = await _runApiService.fetchMyRuns();
      if (!mounted) return;
      setState(() {
        _recentRuns = runs;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recentRuns = const <RunRecord>[];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecentRuns = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            final messenger = ScaffoldMessenger.of(context);
            await ref
                .read(notificationViewModelProvider.notifier)
                .loadNotifications();
            await _loadRecentRuns();
            messenger.showSnackBar(
              const SnackBar(content: Text('Home refreshed.')),
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HomeHeader(),
                const SizedBox(height: 14),
                _StreakCard(runs: _recentRuns),
                const SizedBox(height: 12),

                _RunMapCard(
                  selectedRunMode: _selectedRunMode,
                  onRunModeChanged: (mode) {
                    setState(() {
                      _selectedRunMode = mode;
                    });
                  },
                  onStartRunPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Starting ${_selectedRunMode.name} run...',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 0),

                Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),

                const SizedBox(height: 10),
                _ProgressSection(
                  runs: _recentRuns,
                  isLoading: _isLoadingRecentRuns,
                ),

                const SizedBox(height: 16),

                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),

                const SizedBox(height: 10),
                _RecentActivitySection(
                  runs: _recentRuns,
                  isLoading: _isLoadingRecentRuns,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = ref.watch(
      notificationViewModelProvider.select(
        (state) => state.notifications.where((item) => !item.isRead).length,
      ),
    );

    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'OpenSans Bold',
            ),
            children: [
              TextSpan(
                text: 'Claim ',
                style: const TextStyle(color: Color(0xFF2CC76F)),
              ),
              TextSpan(
                text: 'The ',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF101010),
                ),
              ),
              TextSpan(
                text: 'Run',
                style: const TextStyle(color: Color(0xFF2CC76F)),
              ),
            ],
          ),
        ),

        const Spacer(),

        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111C26) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF233241)
                        : const Color(0xFFE3E3DF),
                  ),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 24,
                  color: isDark ? Colors.white : const Color(0xFF2A2430),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -3,
                  right: -5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.runs});

  final List<RunRecord> runs;

  @override
  Widget build(BuildContext context) {
    final weekProgress = _buildWeeklyRunProgress(runs);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1B26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _StreakDetails(progress: weekProgress)),
          SizedBox(width: 10),
          _DistanceRing(distanceKm: weekProgress.totalDistanceKm),
        ],
      ),
    );
  }
}

class _StreakDetails extends StatelessWidget {
  const _StreakDetails({required this.progress});

  final _WeeklyRunProgress progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                progress.completedDays == 0
                    ? 'Start your weekly run streak!'
                    : 'You ran ${progress.completedDays} day${progress.completedDays == 1 ? '' : 's'} this week',
                style: const TextStyle(
                  color: Color(0xFFCBC9CE),
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final day in progress.days)
              _WeekdayProgress(day: day.label, done: day.done),
          ],
        ),
      ],
    );
  }
}

class _WeekdayProgress extends StatelessWidget {
  const _WeekdayProgress({required this.day, required this.done});

  final String day;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: done ? const Color(0xFF72DB00) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF72DB00),
              width: done ? 0 : 2,
            ),
          ),
          child: done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
              : null,
        ),
      ],
    );
  }
}

class _DistanceRing extends StatelessWidget {
  const _DistanceRing({required this.distanceKm});

  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    final progress = (distanceKm / 30).clamp(0.0, 1.0);
    return SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 98,
            height: 98,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 7,
              backgroundColor: const Color(0xFF33303B),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF56B846),
              ),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                distanceKm.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'km',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

_WeeklyRunProgress _buildWeeklyRunProgress(List<RunRecord> runs) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final daysSinceSunday = now.weekday % 7;
  final startOfWeek = today.subtract(Duration(days: daysSinceSunday));
  const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final ranDays = List<bool>.filled(7, false);
  double totalDistanceKm = 0;

  for (final run in runs) {
    final createdAt = run.createdAt?.toLocal();
    if (createdAt == null) continue;
    final runDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final diff = runDay.difference(startOfWeek).inDays;
    if (diff < 0 || diff > 6) continue;
    ranDays[diff] = true;
    totalDistanceKm += run.distanceMeters / 1000;
  }

  return _WeeklyRunProgress(
    days: [
      for (int index = 0; index < 7; index++)
        _DayStatus(label: labels[index], done: ranDays[index]),
    ],
    totalDistanceKm: totalDistanceKm,
  );
}

class _WeeklyRunProgress {
  const _WeeklyRunProgress({required this.days, required this.totalDistanceKm});

  final List<_DayStatus> days;
  final double totalDistanceKm;

  int get completedDays => days.where((day) => day.done).length;
}

class _DayStatus {
  const _DayStatus({required this.label, required this.done});

  final String label;
  final bool done;
}

class _RunMapCard extends StatelessWidget {
  const _RunMapCard({
    required this.selectedRunMode,
    required this.onRunModeChanged,
    required this.onStartRunPressed,
  });

  final RunMode selectedRunMode;
  final ValueChanged<RunMode> onRunModeChanged;
  final VoidCallback onStartRunPressed;
  static const _mapCenter = LatLng(27.7172, 85.3240);
  static const _mapStyle = '''
{
  "version": 8,
  "sources": {
    "osm": {
      "type": "raster",
      "tiles": [
        "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
      ],
      "tileSize": 256,
      "attribution": "© OpenStreetMap contributors"
    }
  },
  "layers": [
    {
      "id": "osm",
      "type": "raster",
      "source": "osm"
    }
  ]
}
''';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 354,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111C26) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF233241)
                      : const Color(0xFFD9D9D9),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MapLibreMap(
                      styleString: _mapStyle,
                      initialCameraPosition: const CameraPosition(
                        target: _mapCenter,
                        zoom: 12.5,
                      ),
                      compassEnabled: false,
                      myLocationEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      attributionButtonMargins: const Point(-1000, -1000),
                    ),
                    Container(
                      color: (isDark ? Colors.black : Colors.white).withValues(
                        alpha: isDark ? 0.14 : 0.30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 76,
            child: Container(
              width: 122,
              height: 122,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3ED46F).withValues(alpha: 0.22),
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: 96,
                height: 96,
                child: ElevatedButton(
                  onPressed: onStartRunPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3ED46F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  child: const Text('START RUN'),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Container(
                width: 286,
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111C26) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF233241)
                        : const Color(0xFFD6D6D6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.18 : 0.08,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Select Run Mode',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF111111),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    SizedBox(
                      height: 34,
                      child: Row(
                        children: [
                          Expanded(
                            child: _RunModeChip(
                              label: 'Solo',
                              isSelected: selectedRunMode == RunMode.solo,
                              onTap: () => onRunModeChanged(RunMode.solo),
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 22,
                            color: isDark
                                ? const Color(0xFF233241)
                                : const Color(0xFFD0D0D0),
                          ),

                          Expanded(
                            child: _RunModeChip(
                              label: 'Group',
                              isSelected: selectedRunMode == RunMode.group,
                              onTap: () => onRunModeChanged(RunMode.group),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunModeChip extends StatelessWidget {
  const _RunModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF1DC85D)
                  : (isDark
                        ? const Color(0xFF8FA0AE)
                        : const Color(0xFF9FA3A5)),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.runs, required this.isLoading});

  final List<RunRecord> runs;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final totalDistanceKm = runs.fold<double>(
      0,
      (sum, run) => sum + (run.distanceMeters / 1000),
    );
    final totalDurationSeconds = runs.fold<int>(
      0,
      (sum, run) => sum + run.durationSeconds,
    );
    final totalCalories = runs.fold<int>(
      0,
      (sum, run) => sum + ((run.distanceMeters / 1000) * 68).round(),
    );

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.route_rounded,
            iconColor: Color(0xFF6AB339),
            value: isLoading ? '...' : totalDistanceKm.toStringAsFixed(1),
            label: 'Total Km',
          ),
        ),

        SizedBox(width: 10),

        Expanded(
          child: _MetricCard(
            icon: Icons.timer_outlined,
            iconColor: Color(0xFFA99DFF),
            value: isLoading
                ? '--:--:--'
                : _formatProgressDuration(totalDurationSeconds),
            label: 'Total Time',
          ),
        ),

        SizedBox(width: 10),

        Expanded(
          child: _MetricCard(
            emoji: '🔥',
            value: isLoading ? '...' : '$totalCalories',
            label: 'Calories',
          ),
        ),
      ],
    );
  }
}

String _formatProgressDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.emoji,
  });

  final IconData? icon;
  final Color? iconColor;
  final String? emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 146,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF223242) : const Color(0xFFE1E1E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.14),
            blurRadius: 14,
            offset: const Offset(4, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (emoji != null)
            Text(emoji!, style: const TextStyle(fontSize: 34))
          else
            Icon(icon, size: 34, color: iconColor),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF111111),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF9BA8B4) : const Color(0xFF737373),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.runs, required this.isLoading});

  final List<RunRecord> runs;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activities = runs.map(ActivityModel.fromRunRecord).toList();

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111C26) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF233241) : const Color(0xFFD9D9D9),
          ),
        ),
        child: Text(
          'Saved runs will show up here after you finish and save a run.',
          style: TextStyle(
            color: isDark ? const Color(0xFF9BA8B4) : const Color(0xFF6E6E6E),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < activities.length; index++) ...[
          ActivityCard(
            activity: activities[index],
            onTap: () {
              showRunDetailsSheet(context, activity: activities[index]);
            },
          ),
          if (index != activities.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
