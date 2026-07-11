import 'package:maplibre_gl/maplibre_gl.dart';

class RunUserSummary {
  const RunUserSummary({
    required this.id,
    required this.fullname,
    required this.username,
    required this.profileUrl,
  });

  final String id;
  final String fullname;
  final String username;
  final String? profileUrl;

  factory RunUserSummary.fromJson(Map<String, dynamic> json) {
    return RunUserSummary(
      id: json['id']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? 'Unknown Runner',
      username: json['username']?.toString() ?? '',
      profileUrl: json['profileUrl']?.toString(),
    );
  }
}

class RunRecord {
  const RunRecord({
    required this.id,
    required this.title,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.routePoints,
    required this.territoryPoints,
    required this.createdAt,
    required this.user,
  });

  final String id;
  final String? title;
  final double distanceMeters;
  final int durationSeconds;
  final List<LatLng> routePoints;
  final List<LatLng> territoryPoints;
  final DateTime? createdAt;
  final RunUserSummary user;

  bool get hasTerritory => territoryPoints.length >= 3;

  factory RunRecord.fromJson(Map<String, dynamic> json) {
    List<LatLng> parsePoints(dynamic raw) {
      if (raw is! List) return const <LatLng>[];
      return raw
          .whereType<Map>()
          .map(
            (point) => LatLng(
              (point['latitude'] as num).toDouble(),
              (point['longitude'] as num).toDouble(),
            ),
          )
          .toList();
    }

    return RunRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      routePoints: parsePoints(json['routePoints']),
      territoryPoints: parsePoints(json['territoryPoints']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      user: RunUserSummary.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}
