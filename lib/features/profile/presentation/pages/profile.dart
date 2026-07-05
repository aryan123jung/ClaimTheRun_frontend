import 'package:clain_the_run/features/profile/presentation/widgets/profileheadercard.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/profilestattile.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/statsheet.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/weeklyactivitycart.dart';
import 'package:clain_the_run/features/social/presentation/widgets/postcard.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Placeholder data — replace with real data from your backend/provider.
  static const _stats = [
    ProfileStatModel(
      icon: Icons.show_chart_rounded,
      iconColor: Color(0xFF72B63E),
      value: '256.4',
      label: 'Total Km',
    ),
    ProfileStatModel(
      icon: Icons.timer_outlined,
      iconColor: Color(0xFF3D6FE0),
      value: '24:36:14',
      label: 'Total Time',
    ),
    ProfileStatModel(
      icon: Icons.speed_rounded,
      iconColor: Color(0xFFB6A72E),
      value: "6'21\"",
      label: 'Avg Pace',
    ),
    ProfileStatModel(
      icon: Icons.local_fire_department_rounded,
      iconColor: Color(0xFFE08A2E),
      value: '19,860',
      label: 'Calories',
    ),
    ProfileStatModel(
      icon: Icons.directions_run_rounded,
      iconColor: Color(0xFFB03A3A),
      value: '47',
      label: 'Total Runs',
    ),
  ];

  static const _weekDays = [
    DailyDistance(label: 'Mon', km: 6.2),
    DailyDistance(label: 'Tue', km: 8.1),
    DailyDistance(label: 'Wed', km: 5.0),
    DailyDistance(label: 'Thu', km: 7.3),
    DailyDistance(label: 'Fri', km: 10.2),
    DailyDistance(label: 'Sat', km: 12.6),
    DailyDistance(label: 'Sun', km: 9.0),
  ];

  static const _myPosts = [
    PostModel(
      authorName: 'Aryan Jung Chhetri',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=11',
      timestamp: 'Today, 7:15 AM',
      caption: "How's the view???",
      imageUrl:
          'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
      likeCount: 23,
      commentCount: 23,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Track your progress. Own your journey.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6E6E6E)),
            ),
            const SizedBox(height: 16),
            const ProfileHeaderCard(
              name: 'Aryan Jung Chhetri',
              bio: 'Live in the present moment',
              avatarUrl: 'https://i.pravatar.cc/150?img=11',
              runCount: 47,
              territoryCount: 1,
              postCount: 1,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'My Stats',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => showAllStatsSheet(context, stats: _stats),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'See more',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B6D11),
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Color(0xFF3B6D11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD8D8D5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    ProfileStatTile(stat: _stats[i], showDivider: i != 2),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Activity Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 10),
            WeeklyActivityChart(
              days: _weekDays,
              totalDistanceKm: 57.8,
              totalTime: '5:42:18',
              avgPace: "5'55\" / km",
            ),
            const SizedBox(height: 22),
            const Text(
              'My Posts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 10),
            for (final post in _myPosts) ...[
              PostCard(post: post),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
