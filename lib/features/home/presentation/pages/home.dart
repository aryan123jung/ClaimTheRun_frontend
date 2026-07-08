import 'dart:math';

import 'package:clain_the_run/features/notification/presentation/pages/notification.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

enum RunMode { solo, group }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RunMode _selectedRunMode = RunMode.solo;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF7F7F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HomeHeader(),
              const SizedBox(height: 14),
              const _StreakCard(),
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
                      content: Text('Starting ${_selectedRunMode.name} run...'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 0),

              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),

              const SizedBox(height: 10),
              const _ProgressSection(),

              const SizedBox(height: 16),

              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),

              const SizedBox(height: 10),
              const _RecentActivitySection(),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.menu, size: 28, color: Color(0xFF222222)),

        const SizedBox(width: 10),

        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'OpenSans Bold',
            ),
            children: [
              TextSpan(
                text: 'Claim ',
                style: TextStyle(color: Color(0xFF2CC76F)),
              ),
              TextSpan(
                text: 'The ',
                style: TextStyle(color: Color(0xFF101010)),
              ),
              TextSpan(
                text: 'Run',
                style: TextStyle(color: Color(0xFF2CC76F)),
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
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE3E3DF)),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 24,
              color: Color(0xFF2A2430),
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1B26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _StreakDetails()),
          SizedBox(width: 10),
          _DistanceRing(),
        ],
      ),
    );
  }
}

class _StreakDetails extends StatelessWidget {
  const _StreakDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('🔥', style: TextStyle(fontSize: 30)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Keep it up,Aryan!',
                style: TextStyle(
                  color: Color(0xFFCBC9CE),
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _WeekdayProgress(day: 'S', done: true),
            _WeekdayProgress(day: 'M', done: true),
            _WeekdayProgress(day: 'T', done: true),
            _WeekdayProgress(day: 'W', done: true),
            _WeekdayProgress(day: 'T', done: true),
            _WeekdayProgress(day: 'F', done: true),
            _WeekdayProgress(day: 'S', done: false),
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
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done ? const Color(0xFF72DB00) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF72DB00),
              width: done ? 0 : 2,
            ),
          ),
          child: done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : null,
        ),
      ],
    );
  }
}

class _DistanceRing extends StatelessWidget {
  const _DistanceRing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: 86,
            height: 86,
            child: CircularProgressIndicator(
              value: 0.82,
              strokeWidth: 6,
              backgroundColor: Color(0xFF33303B),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF56B846)),
            ),
          ),

          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '26.4',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'km',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD9D9D9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
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
                    Container(color: Colors.white.withValues(alpha: 0.30)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFD6D6D6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Select Run Mode',
                      style: TextStyle(
                        color: Color(0xFF111111),
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
                            color: const Color(0xFFD0D0D0),
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
                  : const Color(0xFF9FA3A5),
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
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.route_rounded,
            iconColor: Color(0xFF6AB339),
            value: '126.4',
            label: 'Total Km',
          ),
        ),

        SizedBox(width: 10),

        Expanded(
          child: _MetricCard(
            icon: Icons.timer_outlined,
            iconColor: Color(0xFFA99DFF),
            value: '14:42:30',
            label: 'Total Time',
          ),
        ),

        SizedBox(width: 10),

        Expanded(
          child: _MetricCard(emoji: '🔥', value: '9864', label: 'Calories'),
        ),
      ],
    );
  }
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
    return Container(
      height: 146,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E1E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
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
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF737373),
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
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ActivityCard(
          title: 'Morning Run',
          subtitle: 'Today, 7:15 AM',
          distance: '5.21 km',
        ),

        SizedBox(height: 12),

        _ActivityCard(
          title: 'First Territory Run',
          subtitle: 'May 17, 10:15 AM',
          distance: '57.00 km',
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.distance,
  });

  final String title;
  final String subtitle;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFE9E9E9),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(painter: _MapThumbPainter()),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9A9A9A),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          Text(
            distance,
            style: const TextStyle(
              color: Color(0xFF848484),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(width: 4),

          const Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: Color(0xFF646464),
          ),
        ],
      ),
    );
  }
}

class _MapThumbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF0F0F0);

    canvas.drawRect(Offset.zero & size, bgPaint);

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final greyPaint = Paint()
      ..color = const Color(0xFFC2C2C2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.9),
      Offset(size.width * 0.9, size.height * 0.1),
      whitePaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.18, 0),
      Offset(size.width * 0.46, size.height),
      whitePaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.72),
      greyPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.58, 0),
      Offset(size.width * 0.85, size.height),
      greyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
