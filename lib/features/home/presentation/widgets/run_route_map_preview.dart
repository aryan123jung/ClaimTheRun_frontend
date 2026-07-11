import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class RunRouteMapPreview extends StatelessWidget {
  const RunRouteMapPreview({
    super.key,
    required this.routePoints,
    this.zoom = 13.2,
    this.showLightOverlay = false,
  });

  final List<LatLng> routePoints;
  final double zoom;
  final bool showLightOverlay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _RoutePreviewPainter(
              routePoints: routePoints,
              overlayOpacity: showLightOverlay ? 0.22 : 0,
            ),
          ),
          if (showLightOverlay)
            Container(color: Colors.white.withValues(alpha: 0.22)),
        ],
      ),
    );
  }
}

class _RoutePreviewPainter extends CustomPainter {
  const _RoutePreviewPainter({
    required this.routePoints,
    required this.overlayOpacity,
  });

  final List<LatLng> routePoints;
  final double overlayOpacity;

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

    final usablePoints = routePoints.length >= 2
        ? routePoints
        : _fallbackRoute();
    final bounds = _Bounds.fromPoints(usablePoints);
    final padding = min(size.width, size.height) * 0.14;
    final routePath = Path();

    for (int index = 0; index < usablePoints.length; index++) {
      final point = usablePoints[index];
      final projected = bounds.project(point, size, padding);
      if (index == 0) {
        routePath.moveTo(projected.dx, projected.dy);
      } else {
        routePath.lineTo(projected.dx, projected.dy);
      }
    }

    final routePaint = Paint()
      ..color = const Color(0xFF72B63E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.8, min(size.width, size.height) * 0.055)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routePaint);

    final start = bounds.project(usablePoints.first, size, padding);
    final end = bounds.project(usablePoints.last, size, padding);
    canvas.drawCircle(
      start,
      max(3.5, min(size.width, size.height) * 0.07),
      Paint()..color = const Color(0xFF72B63E),
    );
    canvas.drawCircle(
      end,
      max(3.5, min(size.width, size.height) * 0.07),
      Paint()..color = const Color(0xFF111111),
    );

    if (overlayOpacity > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white.withValues(alpha: overlayOpacity),
      );
    }
  }

  List<LatLng> _fallbackRoute() {
    return const <LatLng>[
      LatLng(27.7174, 85.3238),
      LatLng(27.7178, 85.3242),
      LatLng(27.7180, 85.3249),
      LatLng(27.7175, 85.3256),
      LatLng(27.7171, 85.3259),
    ];
  }

  @override
  bool shouldRepaint(covariant _RoutePreviewPainter oldDelegate) {
    return oldDelegate.overlayOpacity != overlayOpacity ||
        oldDelegate.routePoints.length != routePoints.length ||
        !_samePoints(oldDelegate.routePoints, routePoints);
  }

  bool _samePoints(List<LatLng> a, List<LatLng> b) {
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index].latitude != b[index].latitude ||
          a[index].longitude != b[index].longitude) {
        return false;
      }
    }
    return true;
  }
}

class _Bounds {
  const _Bounds({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  factory _Bounds.fromPoints(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return _Bounds(
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
    );
  }

  Offset project(LatLng point, Size size, double padding) {
    final width = max(1.0, size.width - (padding * 2));
    final height = max(1.0, size.height - (padding * 2));
    final lngRange = max(0.000001, maxLng - minLng);
    final latRange = max(0.000001, maxLat - minLat);
    final x = ((point.longitude - minLng) / lngRange) * width + padding;
    final y = ((maxLat - point.latitude) / latRange) * height + padding;
    return Offset(x, y);
  }
}
