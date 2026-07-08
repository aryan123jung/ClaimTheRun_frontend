import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class RunRouteMapPreview extends StatelessWidget {
  const RunRouteMapPreview({
    super.key,
    this.zoom = 13.2,
    this.showLightOverlay = false,
  });

  final double zoom;
  final bool showLightOverlay;

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
    return Stack(
      fit: StackFit.expand,
      children: [
        MapLibreMap(
          styleString: _mapStyle,
          initialCameraPosition: CameraPosition(target: _mapCenter, zoom: zoom),
          compassEnabled: false,
          myLocationEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          attributionButtonMargins: const Point(-1000, -1000),
        ),
        if (showLightOverlay)
          Container(color: Colors.white.withValues(alpha: 0.22)),
      ],
    );
  }
}
