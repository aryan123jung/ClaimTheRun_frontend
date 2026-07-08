import 'dart:ui';

import 'package:clain_the_run/features/home/presentation/widgets/activitycard.dart';
import 'package:flutter/material.dart';

/// Opens the run-details popup over a blurred backdrop. Uses a custom
/// dialog route (not the plain showDialog barrier) so the blur can be
/// animated in alongside the card for a smoother, less jarring entrance
/// than a hard-cut dim overlay (Doherty Threshold: transitions under
/// ~400ms feel responsive rather than laggy).
Future<void> showRunDetailsSheet(
  BuildContext context, {
  required ActivityModel activity,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Run details',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);

      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12 * curved.value,
          sigmaY: 12 * curved.value,
        ),
        child: Container(
          color: Colors.black.withValues(alpha: 0.25 * curved.value),
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: curved,
            child: _RunDetailsCard(activity: activity),
          ),
        ),
      );
    },
  );
}

class _RunDetailsCard extends StatelessWidget {
  const _RunDetailsCard({required this.activity});

  final ActivityModel activity;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Run Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _brandGreen,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    Text(
                      activity.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9A9A9A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD8D8D5)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: CustomPaint(
                      painter: _RoutePainter(),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _StatColumn(
                      icon: Icons.show_chart_rounded,
                      iconColor: const Color(0xFF6AB339),
                      value: activity.distanceKm.toStringAsFixed(2),
                      label: 'Total Km',
                    ),
                    _divider(),
                    _StatColumn(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFF3D6FE0),
                      value: activity.totalTime,
                      label: 'Total Time',
                    ),
                    _divider(),
                    _StatColumn(
                      icon: Icons.speed_rounded,
                      iconColor: const Color(0xFFB6A72E),
                      value: activity.avgPace,
                      label: 'Avg Pace',
                    ),
                    _divider(),
                    _StatColumn(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xFFE08A2E),
                      value: '${activity.calories}',
                      label: 'Calories',
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: const Color(0xFFD8D8D5));
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6E6E6E)),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFEFEFEC);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0DC)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final routePaint = Paint()
      ..color = const Color(0xFF72B63E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.2,
        size.width * 0.55,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.7,
        size.width * 0.85,
        size.height * 0.25,
      );
    canvas.drawPath(path, routePaint);

    final startPaint = Paint()..color = const Color(0xFF72B63E);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.75),
      5,
      startPaint,
    );
    final endPaint = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.25),
      5,
      endPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
