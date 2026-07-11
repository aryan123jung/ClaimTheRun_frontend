import 'package:clain_the_run/core/api/api_client.dart';
import 'package:clain_the_run/features/leaderboard/map/data/models/run_record.dart';
import 'package:dio/dio.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class RunApiService {
  RunApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<RunRecord> createRun({
    String? title,
    required List<LatLng> routePoints,
    required List<LatLng> territoryPoints,
    required double distanceMeters,
    required int durationSeconds,
  }) async {
    final response = await _client.post(
      '/runs',
      data: {
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        'routePoints': routePoints
            .map(
              (point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              },
            )
            .toList(),
        'territoryPoints': territoryPoints
            .map(
              (point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              },
            )
            .toList(),
        'distanceMeters': distanceMeters,
        'durationSeconds': durationSeconds,
      },
    );

    return RunRecord.fromJson(
      (response.data['data'] as Map).cast<String, dynamic>(),
    );
  }

  Future<List<RunRecord>> fetchMyRuns() async {
    final response = await _client.get('/runs/me');
    final raw = response.data['data'];
    if (raw is! List) return const <RunRecord>[];
    return raw
        .whereType<Map>()
        .map((item) => RunRecord.fromJson(item.cast<String, dynamic>()))
        .toList();
  }

  Future<List<RunRecord>> fetchRunsByUserId(String userId) async {
    final response = await _client.get('/runs/user/$userId');
    final raw = response.data['data'];
    if (raw is! List) return const <RunRecord>[];
    return raw
        .whereType<Map>()
        .map((item) => RunRecord.fromJson(item.cast<String, dynamic>()))
        .toList();
  }

  Future<List<RunRecord>> fetchTerritories() async {
    final response = await _client.get('/runs/territories');
    final raw = response.data['data'];
    if (raw is! List) return const <RunRecord>[];
    return raw
        .whereType<Map>()
        .map((item) => RunRecord.fromJson(item.cast<String, dynamic>()))
        .toList();
  }

  Future<void> deleteRun(String runId) async {
    await _client.delete('/runs/$runId');
  }

  String extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return error.message ?? 'Something went wrong';
    }
    return error.toString();
  }
}
