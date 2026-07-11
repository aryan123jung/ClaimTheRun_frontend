import 'dart:math';

import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/leaderboard/map/data/datasources/run_api_service.dart';
import 'package:clain_the_run/features/leaderboard/map/data/models/run_record.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class TerritoriesOverviewScreen extends ConsumerStatefulWidget {
  const TerritoriesOverviewScreen({
    super.key,
    required this.currentUserTerritory,
    required this.currentUserRunId,
    required this.fallbackCenter,
  });

  final List<LatLng> currentUserTerritory;
  final String? currentUserRunId;
  final LatLng fallbackCenter;

  @override
  ConsumerState<TerritoriesOverviewScreen> createState() =>
      _TerritoriesOverviewScreenState();
}

class _TerritoriesOverviewScreenState
    extends ConsumerState<TerritoriesOverviewScreen> {
  final RunApiService _runApiService = RunApiService();
  bool _isLoading = true;
  bool _isDeleting = false;
  List<RunRecord> _territoryRuns = const <RunRecord>[];
  MapLibreMapController? _mapController;
  bool _isStyleLoaded = false;
  final List<Fill> _territoryFills = <Fill>[];
  List<_TerritoryChipPosition> _territoryChipPositions =
      const <_TerritoryChipPosition>[];
  int _chipProjectionRevision = 0;

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
  void initState() {
    super.initState();
    _loadTerritories();
  }

  Future<void> _loadTerritories() async {
    try {
      final runs = await _runApiService.fetchTerritories();
      if (!mounted) return;
      setState(() {
        _territoryRuns = runs.where((run) => run.hasTerritory).toList();
      });
      await _syncTerritoriesOnMap();
    } catch (_) {
      // Keep local fallback below if backend data is unavailable.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMyTerritory(String runId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete territory?'),
          content: const Text(
            'This will remove your saved run territory from the map.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _runApiService.deleteRun(runId);
      if (!mounted) return;
      setState(() {
        _territoryRuns = _territoryRuns
            .where((run) => run.id != runId)
            .toList();
      });
      await _syncTerritoriesOnMap();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Territory deleted successfully')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_runApiService.extractErrorMessage(error))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _clearMapTerritoryAnnotations() async {
    final controller = _mapController;
    if (controller == null) return;

    for (final fill in _territoryFills) {
      await controller.removeFill(fill);
    }

    _territoryFills.clear();
  }

  Future<void> _syncTerritoriesOnMap() async {
    final controller = _mapController;
    if (!_isStyleLoaded || controller == null || !mounted) return;

    final currentUser = ref.read(authViewModelProvider).authEntity;
    final currentUserName = (currentUser?.fullname.trim().isNotEmpty ?? false)
        ? currentUser!.fullname.trim()
        : 'You';
    final currentUserAvatar = (currentUser?.profileUrl?.isNotEmpty ?? false)
        ? ApiEndpoints.profileImageUrl(currentUser!.profileUrl!)
        : null;

    final territories = _territoryRuns.isNotEmpty
        ? _buildTerritoriesFromRuns(_territoryRuns, currentUser?.id)
        : _buildFallbackTerritories(
            currentUserName: currentUserName,
            currentUserAvatar: currentUserAvatar,
            currentUserTerritory: widget.currentUserTerritory,
            currentUserRunId: widget.currentUserRunId,
          );

    await _clearMapTerritoryAnnotations();

    for (final territory in territories) {
      if (territory.points.length < 3) continue;

      final closedLoop = List<LatLng>.from(territory.points);
      if (closedLoop.first != closedLoop.last) {
        closedLoop.add(closedLoop.first);
      }

      final fill = await controller.addFill(
        FillOptions(
          geometry: [closedLoop],
          fillColor: _colorHex(territory.fillColor),
          fillOpacity: territory.isMine ? 0.26 : 0.18,
          fillOutlineColor: _colorHex(territory.accentColor),
        ),
      );
      _territoryFills.add(fill);
    }

    await _updateTerritoryChipPositions(territories);
  }

  Future<void> _updateTerritoryChipPositions(
    List<_TerritoryZone> territories,
  ) async {
    final controller = _mapController;
    if (controller == null || !_isStyleLoaded || !mounted) return;
    final revision = ++_chipProjectionRevision;

    try {
      final points = await controller.toScreenLocationBatch(
        territories.map((territory) => territory.centroid),
      );
      if (!mounted || revision != _chipProjectionRevision) return;

      setState(() {
        _territoryChipPositions = [
          for (var index = 0; index < territories.length; index++)
            _TerritoryChipPosition(
              territory: territories[index],
              point: points[index],
            ),
        ];
      });
    } catch (_) {
      // Ignore projection failures and keep the last rendered chip positions.
    }
  }

  String _colorHex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authViewModelProvider);
    final currentUser = authState.authEntity;
    final currentUserName = (currentUser?.fullname.trim().isNotEmpty ?? false)
        ? currentUser!.fullname.trim()
        : 'You';
    final currentUserAvatar = (currentUser?.profileUrl?.isNotEmpty ?? false)
        ? ApiEndpoints.profileImageUrl(currentUser!.profileUrl!)
        : null;

    final territories = _territoryRuns.isNotEmpty
        ? _buildTerritoriesFromRuns(_territoryRuns, currentUser?.id)
        : _buildFallbackTerritories(
            currentUserName: currentUserName,
            currentUserAvatar: currentUserAvatar,
            currentUserTerritory: widget.currentUserTerritory,
            currentUserRunId: widget.currentUserRunId,
          );

    _TerritoryZone? myTerritory;
    for (final territory in territories) {
      if (territory.isMine) {
        myTerritory = territory;
        break;
      }
    }

    final mapCenter = _averagePoint(
      territories.expand((territory) => territory.points),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: MapLibreMap(
              styleString: _mapStyle,
              initialCameraPosition: CameraPosition(
                target: mapCenter,
                zoom: 15.6,
                tilt: 0,
                bearing: 0,
              ),
              onMapCreated: (controller) => _mapController = controller,
              onStyleLoadedCallback: () async {
                _isStyleLoaded = true;
                await _syncTerritoriesOnMap();
              },
              onCameraMove: (_) {
                _updateTerritoryChipPositions(territories);
              },
              onCameraIdle: () {
                _updateTerritoryChipPositions(territories);
              },
              compassEnabled: false,
              myLocationEnabled: false,
              attributionButtonMargins: const Point(-1000, -1000),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? const [
                            Color(0xD20A1117),
                            Color(0x420A1117),
                            Color(0x0009121A),
                            Color(0x7A0A1117),
                          ]
                        : const [
                            Color(0xE8FFFFFF),
                            Color(0x52FFFFFF),
                            Color(0x00FFFFFF),
                            Color(0xA6FFFFFF),
                          ],
                    stops: const [0, 0.18, 0.52, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      for (final chip in _territoryChipPositions)
                        Positioned(
                          left: _chipLeft(
                            chip.point.x.toDouble(),
                            constraints.maxWidth,
                          ),
                          top: _chipTop(
                            chip.point.y.toDouble(),
                            constraints.maxHeight,
                          ),
                          child: _TerritoryMapChip(
                            territory: chip.territory,
                            isDark: isDark,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xD9121B23)
                          : const Color(0xECFFFFFF),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF273744)
                            : const Color(0xE3E7ECE3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.22 : 0.10,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RoundHeaderButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Territories',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF121514),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLoading
                                    ? 'Loading saved territories...'
                                    : 'Explore recorded zones and reclaim your ground.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.25,
                                  color: isDark
                                      ? const Color(0xFFA5B8C5)
                                      : const Color(0xFF6D776F),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _InfoPill(
                                    icon: Icons.hexagon_outlined,
                                    label:
                                        '${territories.length} zone${territories.length == 1 ? '' : 's'}',
                                    isDark: isDark,
                                  ),
                                  _InfoPill(
                                    icon: Icons.layers_outlined,
                                    label: myTerritory != null
                                        ? 'Your territory active'
                                        : 'No personal territory',
                                    isDark: isDark,
                                    accent: myTerritory != null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(child: SizedBox.expand()),
                if (myTerritory != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xE9121B23)
                            : const Color(0xF7FFFFFF),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF273744)
                              : const Color(0xFFE5E9E3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.22 : 0.10,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Manage your territory',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF141817),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This removes your currently saved zone from the shared territory map.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: isDark
                                  ? const Color(0xFFA1B4C0)
                                  : const Color(0xFF6B756D),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isDeleting
                                  ? null
                                  : () => _deleteMyTerritory(myTerritory!.id),
                              style: FilledButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF3A1516)
                                    : const Color(0xFFFCE8E6),
                                foregroundColor: isDark
                                    ? const Color(0xFFFFB4AB)
                                    : const Color(0xFFB42318),
                                disabledBackgroundColor: isDark
                                    ? const Color(0xFF241718)
                                    : const Color(0xFFF4E7E5),
                                disabledForegroundColor: isDark
                                    ? const Color(0xFF896C69)
                                    : const Color(0xFFBC8C86),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: _isDeleting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.delete_sweep_rounded),
                              label: Text(
                                _isDeleting
                                    ? 'Deleting territory...'
                                    : 'Delete my saved territory',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (!_isLoading && territories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xE9121B23)
                            : const Color(0xF7FFFFFF),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF273744)
                              : const Color(0xFFE5E9E3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A2731)
                                  : const Color(0xFFF2F7ED),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.explore_off_rounded,
                              color: Color(0xFF72B63E),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No saved territories yet',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF141817),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Finish a run to record your first territory on the map.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    color: isDark
                                        ? const Color(0xFFA1B4C0)
                                        : const Color(0xFF6B756D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (widget.currentUserTerritory.length < 3 &&
                    myTerritory == null &&
                    !_isLoading)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: _HintCard(
                      icon: Icons.route_rounded,
                      title: 'Territory needs a closed path',
                      description:
                          'Complete a loop during your run so the app can generate a territory shape.',
                      isDark: isDark,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_TerritoryZone> _buildTerritoriesFromRuns(
    List<RunRecord> runs,
    String? currentUserId,
  ) {
    return runs
        .where((run) => run.territoryPoints.length >= 3)
        .map(
          (run) => _TerritoryZone(
            id: run.id,
            name: run.user.fullname,
            avatarUrl: (run.user.profileUrl?.isNotEmpty ?? false)
                ? ApiEndpoints.profileImageUrl(run.user.profileUrl!)
                : null,
            points: run.territoryPoints,
            fillColor: run.user.id == currentUserId
                ? const Color(0xFF72B63E)
                : const Color(0xFF4D7EF2),
            accentColor: run.user.id == currentUserId
                ? const Color(0xFF3B6D11)
                : const Color(0xFF2D5FD7),
            isMine: run.user.id == currentUserId,
          ),
        )
        .toList();
  }

  List<_TerritoryZone> _buildFallbackTerritories({
    required String currentUserName,
    required String? currentUserAvatar,
    required List<LatLng> currentUserTerritory,
    required String? currentUserRunId,
  }) {
    final zones = <_TerritoryZone>[];

    if (currentUserTerritory.length >= 3) {
      zones.insert(
        0,
        _TerritoryZone(
          id: currentUserRunId ?? 'mine',
          name: currentUserName,
          avatarUrl: currentUserAvatar,
          points: currentUserTerritory,
          fillColor: const Color(0xFF72B63E),
          accentColor: const Color(0xFF3B6D11),
          isMine: true,
        ),
      );
    }

    return zones;
  }

  LatLng _averagePoint(Iterable<LatLng> points) {
    final allPoints = points.toList();
    if (allPoints.isEmpty) return widget.fallbackCenter;

    final totalLat = allPoints.fold<double>(
      0,
      (sum, point) => sum + point.latitude,
    );
    final totalLng = allPoints.fold<double>(
      0,
      (sum, point) => sum + point.longitude,
    );
    return LatLng(totalLat / allPoints.length, totalLng / allPoints.length);
  }

  double _chipLeft(double anchorX, double screenWidth) {
    const chipWidth = 116.0;
    const horizontalMargin = 10.0;
    final rawLeft = anchorX - (chipWidth / 2);
    final maxLeft = max(
      horizontalMargin,
      screenWidth - chipWidth - horizontalMargin,
    );
    return rawLeft.clamp(horizontalMargin, maxLeft);
  }

  double _chipTop(double anchorY, double screenHeight) {
    const chipHeight = 58.0;
    const topMargin = 84.0;
    const bottomMargin = 120.0;
    final preferredTop = anchorY - (chipHeight / 2);
    final maxTop = max(topMargin, screenHeight - chipHeight - bottomMargin);
    return preferredTop.clamp(topMargin, maxTop);
  }

  @override
  void dispose() {
    _clearMapTerritoryAnnotations();
    super.dispose();
  }
}

class _RoundHeaderButton extends StatelessWidget {
  const _RoundHeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xCC16222C) : const Color(0xFFF7FBF4),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF314555) : const Color(0xFFE1E9DB),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF202521),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.isDark,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent
        ? const Color(0xFF72B63E)
        : (isDark ? const Color(0xFF9DB0BD) : const Color(0xFF738079));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17242E) : const Color(0xFFF5F8F2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent
              ? const Color(0x4072B63E)
              : (isDark ? const Color(0xFF263844) : const Color(0xFFE4EADF)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE9121B23) : const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF273744) : const Color(0xFFE5E9E3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2731) : const Color(0xFFF2F7ED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF72B63E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF141817),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark
                        ? const Color(0xFFA1B4C0)
                        : const Color(0xFF6B756D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TerritoryZone {
  const _TerritoryZone({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.points,
    required this.fillColor,
    required this.accentColor,
    this.isMine = false,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final List<LatLng> points;
  final Color fillColor;
  final Color accentColor;
  final bool isMine;

  LatLng get centroid {
    final totalLat = points.fold<double>(
      0,
      (sum, point) => sum + point.latitude,
    );
    final totalLng = points.fold<double>(
      0,
      (sum, point) => sum + point.longitude,
    );
    return LatLng(totalLat / points.length, totalLng / points.length);
  }
}

class _TerritoryChipPosition {
  const _TerritoryChipPosition({required this.territory, required this.point});

  final _TerritoryZone territory;
  final Point<num> point;
}

class _TerritoryMapChip extends StatelessWidget {
  const _TerritoryMapChip({required this.territory, required this.isDark});

  final _TerritoryZone territory;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderColor = territory.isMine
        ? const Color(0xFF72B63E)
        : const Color(0xFF2D5FD7);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 116),
          padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xEE10191F) : const Color(0xF8FFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withValues(alpha: 0.75)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TerritoryAvatar(
                imageUrl: territory.avatarUrl,
                initials: _initialsForName(territory.name),
                borderColor: borderColor,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  territory.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF162018),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: borderColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.4),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.28),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _initialsForName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _TerritoryAvatar extends StatelessWidget {
  const _TerritoryAvatar({
    required this.imageUrl,
    required this.initials,
    required this.borderColor,
  });

  final String? imageUrl;
  final String initials;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.4),
        color: borderColor.withValues(alpha: 0.16),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _TerritoryAvatarFallback(
                  initials: initials,
                  borderColor: borderColor,
                ),
              )
            : _TerritoryAvatarFallback(
                initials: initials,
                borderColor: borderColor,
              ),
      ),
    );
  }
}

class _TerritoryAvatarFallback extends StatelessWidget {
  const _TerritoryAvatarFallback({
    required this.initials,
    required this.borderColor,
  });

  final String initials;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: borderColor.withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: borderColor,
        ),
      ),
    );
  }
}
