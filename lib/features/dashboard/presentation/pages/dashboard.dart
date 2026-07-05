import 'package:clain_the_run/features/home/presentation/pages/home.dart';
import 'package:clain_the_run/features/leaderboard/presentation/pages/leaderboard.dart';
import 'package:clain_the_run/features/map/presentation/pages/map.dart';
import 'package:clain_the_run/features/profile/presentation/pages/profile.dart';
import 'package:clain_the_run/features/social/presentation/pages/social.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    SocialScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        height: 74,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFDCDCDC))),
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
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              size: 30,
              color: active ? const Color(0xFF72B63E) : const Color(0xFFA7A7A7),
            ),
          ),
        ),
      ),
    );
  }
}
