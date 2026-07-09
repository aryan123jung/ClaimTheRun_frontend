import 'dart:async';

import 'package:clain_the_run/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:clain_the_run/features/home/presentation/pages/home.dart';
import 'package:clain_the_run/features/leaderboard/presentation/pages/leaderboard.dart';
import 'package:clain_the_run/features/map/presentation/pages/map.dart';
import 'package:clain_the_run/features/profile/presentation/pages/profile.dart';
import 'package:clain_the_run/features/social/presentation/pages/social.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  Timer? _notificationRefreshTimer;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    SocialScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadNotifications);
    _notificationRefreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _notificationRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        height: 74,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111C26) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF233241) : const Color(0xFFDCDCDC),
            ),
          ),
        ),
        child: Row(
          children: [
            _DashboardNavItem(
              icon: Icons.home_rounded,
              active: _selectedIndex == 0,
              onTap: () => _onTabSelected(0),
            ),
            _DashboardNavItem(
              icon: Icons.map_outlined,
              active: _selectedIndex == 1,
              onTap: () => _onTabSelected(1),
            ),
            _DashboardNavItem(
              icon: Icons.groups_rounded,
              active: _selectedIndex == 2,
              onTap: () => _onTabSelected(2),
            ),
            _DashboardNavItem(
              icon: Icons.emoji_events_outlined,
              active: _selectedIndex == 3,
              onTap: () => _onTabSelected(3),
            ),
            _DashboardNavItem(
              icon: Icons.person_rounded,
              active: _selectedIndex == 4,
              onTap: () => _onTabSelected(4),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadNotifications() async {
    await ref.read(notificationViewModelProvider.notifier).loadNotifications();
  }
}

class _DashboardNavItem extends StatelessWidget {
  const _DashboardNavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              size: 30,
              color: active
                  ? const Color(0xFF72B63E)
                  : (isDark
                        ? const Color(0xFF7F8E99)
                        : const Color(0xFFA7A7A7)),
            ),
          ),
        ),
      ),
    );
  }
}
