import 'dart:async';
import 'dart:math';

import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/map/data/datasources/run_api_service.dart';
import 'package:clain_the_run/features/message/data/services/message_socket_service.dart';
import 'package:clain_the_run/features/message/presentation/pages/group_message_screen.dart';
import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/presentation/pages/group_profile_screen.dart';
import 'package:clain_the_run/features/social/presentation/state/social_state.dart';
import 'package:clain_the_run/features/social/presentation/view_model/social_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';

enum _GroupRunState { ready, joinable, active }

class GroupRunDashboardScreen extends ConsumerStatefulWidget {
  const GroupRunDashboardScreen({super.key});

  @override
  ConsumerState<GroupRunDashboardScreen> createState() =>
      _GroupRunDashboardScreenState();
}

class _GroupRunDashboardScreenState
    extends ConsumerState<GroupRunDashboardScreen> {
  GroupEntity? _selectedGroup;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(socialViewModelProvider.notifier).loadGroups(force: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(socialViewModelProvider);
    final groups = state.groups;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedGroup == null && groups.isNotEmpty) {
      _selectedGroup = groups.first;
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF07111A)
          : const Color(0xFFF8FBF6),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: isDark ? Colors.white : const Color(0xFF202320),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group Run',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF101410),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Start from a separate dashboard with your crew.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF8EA1B0)
                                : const Color(0xFF7B847D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(socialViewModelProvider.notifier)
                      .loadGroups(force: true);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  children: [
                    const _GroupRunHeroMap(),
                    const SizedBox(height: 18),
                    _ModeHintCard(isDark: isDark),
                    const SizedBox(height: 18),
                    Text(
                      'Choose Group',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (state.status == SocialStatus.loading && groups.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (groups.isEmpty)
                      _EmptyGroupsCard(isDark: isDark)
                    else
                      ...groups.map(
                        (group) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _GroupRunSelectionCard(
                            group: group,
                            isSelected: _selectedGroup?.id == group.id,
                            onTap: () {
                              setState(() {
                                _selectedGroup = group;
                              });
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _selectedGroup == null
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GroupRunLiveScreen(
                                      group: _selectedGroup!,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF31C861),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFB9D6B9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 22),
                        label: Text(
                          _selectedGroup == null
                              ? 'Join a group first'
                              : 'Start group run',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupRunLiveScreen extends ConsumerStatefulWidget {
  const GroupRunLiveScreen({super.key, required this.group});

  final GroupEntity group;

  @override
  ConsumerState<GroupRunLiveScreen> createState() => _GroupRunLiveScreenState();
}

class _GroupRunLiveScreenState extends ConsumerState<GroupRunLiveScreen> {
  static const _mapCenter = LatLng(27.7172, 85.3240);
  static const _idleZoom = 15.0;
  static const _runningZoom = 17.0;
  static const _idleTilt = 20.0;
  static const _runningTilt = 46.0;
  static const _idleBearing = -10.0;
  static const _runningBearing = -24.0;

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

  final RunApiService _runApiService = RunApiService();
  late final MessageSocketService _messageSocketService;
  MapLibreMapController? _mapController;
  bool _isMapStyleReady = false;
  bool _hasLocationPermission = false;
  _GroupRunState _runState = _GroupRunState.ready;
  LatLng? _currentUserLocation;
  Circle? _userLocationCircle;
  Circle? _userLocationGlowCircle;
  Line? _routeLine;
  final Map<String, GroupRunParticipantSocketPayload> _activeParticipants =
      <String, GroupRunParticipantSocketPayload>{};
  final Map<String, Circle> _memberCircles = <String, Circle>{};
  List<_ParticipantLabelPosition> _participantLabelPositions =
      const <_ParticipantLabelPosition>[];
  StreamSubscription<Position>? _positionSubscription;
  Timer? _elapsedTimer;
  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  double _distanceMeters = 0;
  final List<LatLng> _routePoints = <LatLng>[];
  GroupRunSessionSocketPayload? _activeSession;
  bool _isFinishingRun = false;
  bool _hasJoinedPresence = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(socialViewModelProvider.notifier).loadGroups(force: true),
    );
    _messageSocketService = ref.read(messageSocketServiceProvider);
    _messageSocketService.setOnGroupRunParticipants(_handleRunParticipants);
    _messageSocketService.setOnGroupRunUserJoined(_handleRunParticipantJoined);
    _messageSocketService.setOnGroupRunUserUpdated(
      _handleRunParticipantUpdated,
    );
    _messageSocketService.setOnGroupRunUserLeft(_handleRunParticipantLeft);
    _messageSocketService.setOnGroupRunStarted(_handleRunStarted);
    _messageSocketService.setOnGroupRunStopped(_handleRunStopped);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLocationPermission();
    });
  }

  Future<void> _ensureLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (!mounted) return;
    setState(() {
      _hasLocationPermission = status.isGranted;
    });
    if (!_hasLocationPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required.')),
      );
      return;
    }
    await _loadCurrentLocation();
  }

  Future<bool> _loadCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return false;
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      return false;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      if (!mounted) return false;
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentUserLocation = point;
      });
      await _syncUserMarker();
      await _joinRunPresence(point);
      await _animateToUser(
        point,
        isRunning: _isActive,
        duration: const Duration(milliseconds: 650),
      );
      return true;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get your live location.')),
      );
      return false;
    }
  }

  Future<void> _syncUserMarker() async {
    final controller = _mapController;
    final location = _currentUserLocation;
    if (!_isMapStyleReady || controller == null || location == null) return;

    if (_userLocationCircle == null) {
      _userLocationGlowCircle = await controller.addCircle(
        CircleOptions(
          geometry: location,
          circleRadius: 18,
          circleColor: '#31C861',
          circleOpacity: 0.20,
          circleBlur: 0.65,
        ),
      );
      _userLocationCircle = await controller.addCircle(
        CircleOptions(
          geometry: location,
          circleRadius: 10,
          circleColor: '#31C861',
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 4,
        ),
      );
      return;
    }

    if (_userLocationGlowCircle != null) {
      await controller.updateCircle(
        _userLocationGlowCircle!,
        CircleOptions(geometry: location),
      );
    }
    await controller.updateCircle(
      _userLocationCircle!,
      CircleOptions(geometry: location),
    );
  }

  Future<void> _startTracking() async {
    await _positionSubscription?.cancel();
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) async {
            final point = LatLng(position.latitude, position.longitude);
            if (!mounted) return;
            setState(() {
              _currentUserLocation = point;
            });
            await _syncUserMarker();
            await _updateRunPresence(point);
            if (_isActive) {
              await _recordPoint(point);
            }
            await _animateToUser(point, isRunning: _isActive);
          },
        );
  }

  Future<void> _recordPoint(LatLng point) async {
    if (_routePoints.isNotEmpty) {
      final previous = _routePoints.last;
      final segmentMeters = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        point.latitude,
        point.longitude,
      );
      if (segmentMeters < 3) return;
      _distanceMeters += segmentMeters;
    }

    _routePoints.add(point);
    if (mounted) {
      setState(() {});
    }
    await _syncRouteLine();
  }

  Future<void> _syncRouteLine() async {
    final controller = _mapController;
    if (!_isMapStyleReady || controller == null || _routePoints.length < 2) {
      return;
    }

    final options = LineOptions(
      geometry: List<LatLng>.from(_routePoints),
      lineColor: '#31C861',
      lineWidth: 5,
      lineOpacity: 0.94,
      lineJoin: 'round',
      lineBlur: 0.35,
    );

    if (_routeLine == null) {
      _routeLine = await controller.addLine(options);
      return;
    }

    await controller.updateLine(_routeLine!, options);
  }

  Future<void> _syncRemoteParticipantMarkers() async {
    final controller = _mapController;
    if (!_isMapStyleReady || controller == null) return;

    final authState = ref.read(authViewModelProvider);
    final selfId = authState.authEntity?.id ?? '';
    final desiredIds = _activeParticipants.keys
        .where((id) => id.isNotEmpty && id != selfId)
        .toSet();

    final staleIds = _memberCircles.keys
        .where((id) => !desiredIds.contains(id))
        .toList();
    for (final id in staleIds) {
      final circle = _memberCircles.remove(id);
      if (circle != null) {
        await controller.removeCircle(circle);
      }
    }

    for (final entry in _activeParticipants.entries) {
      if (entry.key == selfId) continue;
      final participant = entry.value;
      final existing = _memberCircles[entry.key];
      final options = CircleOptions(
        geometry: participant.location,
        circleRadius: 9,
        circleColor: '#4F7DFF',
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 3,
        circleOpacity: 0.95,
      );
      if (existing == null) {
        _memberCircles[entry.key] = await controller.addCircle(options);
      } else {
        await controller.updateCircle(existing, options);
      }
    }
  }

  Future<void> _joinRunPresence(LatLng point) async {
    final authState = ref.read(authViewModelProvider);
    final self = authState.authEntity;
    final selfId = self?.id ?? '';
    if (selfId.isEmpty) return;

    debugPrint(
      '[GroupRun ${widget.group.id}] join presence user=$selfId point=${point.latitude},${point.longitude}',
    );
    await _messageSocketService.connect();
    _messageSocketService.joinGroupRun(
      communityId: widget.group.id,
      userId: selfId,
      name: self?.fullname ?? 'Runner',
      username: self?.username ?? 'runner',
      avatarUrl: self?.profileUrl,
      location: point,
    );
    if (!mounted) return;
    setState(() {
      _hasJoinedPresence = true;
    });
  }

  Future<void> _updateRunPresence(LatLng point) async {
    final authState = ref.read(authViewModelProvider);
    final selfId = authState.authEntity?.id ?? '';
    if (selfId.isEmpty) return;

    debugPrint(
      '[GroupRun ${widget.group.id}] update presence user=$selfId point=${point.latitude},${point.longitude}',
    );
    _messageSocketService.updateGroupRunLocation(
      communityId: widget.group.id,
      userId: selfId,
      location: point,
    );
  }

  bool get _isActive => _runState == _GroupRunState.active;

  bool get _isJoinable => _runState == _GroupRunState.joinable;

  void _handleRunParticipants(
    String communityId,
    List<GroupRunParticipantSocketPayload> participants,
  ) {
    if (communityId != widget.group.id || !mounted) return;
    debugPrint(
      '[GroupRun ${widget.group.id}] participants=${participants.map((p) => p.userId).join(",")}',
    );
    setState(() {
      _activeParticipants.removeWhere(
        (userId, _) => participants.every((item) => item.userId != userId),
      );
      for (final participant in participants) {
        _activeParticipants[participant.userId] = participant;
      }
    });
    _syncRemoteParticipantMarkers();
    _updateParticipantLabelPositions();
  }

  void _handleRunParticipantJoined(
    String communityId,
    GroupRunParticipantSocketPayload participant,
  ) {
    if (communityId != widget.group.id || !mounted) return;
    debugPrint(
      '[GroupRun ${widget.group.id}] user joined=${participant.userId}',
    );
    setState(() {
      _activeParticipants[participant.userId] = participant;
    });
    _syncRemoteParticipantMarkers();
    _updateParticipantLabelPositions();
  }

  void _handleRunParticipantUpdated(
    String communityId,
    GroupRunParticipantSocketPayload participant,
  ) {
    if (communityId != widget.group.id || !mounted) return;
    debugPrint(
      '[GroupRun ${widget.group.id}] user updated=${participant.userId}',
    );
    setState(() {
      _activeParticipants[participant.userId] = participant;
    });
    _syncRemoteParticipantMarkers();
    _updateParticipantLabelPositions();
  }

  void _handleRunParticipantLeft(String communityId, String userId) {
    if (communityId != widget.group.id || !mounted) return;
    debugPrint('[GroupRun ${widget.group.id}] user left=$userId');
    setState(() {
      _activeParticipants.remove(userId);
    });
    _syncRemoteParticipantMarkers();
    _updateParticipantLabelPositions();
  }

  void _handleRunStarted(GroupRunSessionSocketPayload session) {
    if (session.communityId != widget.group.id || !mounted) return;
    final authState = ref.read(authViewModelProvider);
    final selfId = authState.authEntity?.id ?? '';
    debugPrint(
      '[GroupRun ${widget.group.id}] started by=${session.startedByUserId} self=$selfId',
    );
    setState(() {
      _activeSession = session;
      if (!_isActive) {
        _runState = session.startedByUserId == selfId
            ? _GroupRunState.active
            : _GroupRunState.joinable;
      }
    });
  }

  void _handleRunStopped(String communityId, String stoppedByUserId) {
    if (communityId != widget.group.id || !mounted) return;
    if (_isFinishingRun) return;
    _elapsedTimer?.cancel();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    setState(() {
      _activeSession = null;
      _hasJoinedPresence = false;
      _runState = _GroupRunState.ready;
      _elapsed = Duration.zero;
    });
  }

  int get _activeMemberCount =>
      _activeParticipants.length + (_hasJoinedPresence ? 1 : 0);

  Future<void> _updateParticipantLabelPositions() async {
    final controller = _mapController;
    if (!_isMapStyleReady || controller == null || !mounted) return;

    final authState = ref.read(authViewModelProvider);
    final selfId = authState.authEntity?.id ?? '';
    final others = _activeParticipants.values
        .where((participant) => participant.userId != selfId)
        .toList();

    if (others.isEmpty) {
      if (_participantLabelPositions.isNotEmpty) {
        setState(() {
          _participantLabelPositions = const <_ParticipantLabelPosition>[];
        });
      }
      return;
    }

    try {
      final points = await controller.toScreenLocationBatch(
        others.map((participant) => participant.location),
      );
      if (!mounted) return;
      setState(() {
        _participantLabelPositions = [
          for (var index = 0; index < others.length; index++)
            _ParticipantLabelPosition(
              participant: others[index],
              point: points[index],
            ),
        ];
      });
    } catch (_) {
      // Ignore projection failures and keep the last rendered labels.
    }
  }

  Future<void> _animateToUser(
    LatLng point, {
    required bool isRunning,
    Duration duration = const Duration(milliseconds: 900),
  }) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: point,
          zoom: isRunning ? _runningZoom : _idleZoom,
          tilt: isRunning ? _runningTilt : _idleTilt,
          bearing: isRunning ? _runningBearing : _idleBearing,
        ),
      ),
      duration: duration,
    );
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _startedAt ??= DateTime.now();
    _elapsed = Duration.zero;
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final startedAt = _startedAt;
      if (!mounted || startedAt == null) return;
      setState(() {
        _elapsed = DateTime.now().difference(startedAt);
      });
    });
  }

  Future<void> _startRun() async {
    if (!_hasLocationPermission) {
      await _ensureLocationPermission();
      if (!_hasLocationPermission) return;
    }

    if (_currentUserLocation == null) {
      final loaded = await _loadCurrentLocation();
      if (!loaded) return;
    }

    _routePoints.clear();
    _distanceMeters = 0;
    _elapsed = Duration.zero;
    _startedAt = null;
    if (!mounted) return;
    setState(() {
      _runState = _GroupRunState.active;
    });
    _messageSocketService.startGroupRun(widget.group.id);
    if (_currentUserLocation != null) {
      await _recordPoint(_currentUserLocation!);
    }
    _startElapsedTimer();
    await _startTracking();
    if (_currentUserLocation != null) {
      await _joinRunPresence(_currentUserLocation!);
    }
  }

  Future<void> _joinStartedRun() async {
    if (_isActive) return;

    if (!_hasLocationPermission) {
      await _ensureLocationPermission();
      if (!_hasLocationPermission) return;
    }

    if (_currentUserLocation == null) {
      final loaded = await _loadCurrentLocation();
      if (!loaded) return;
    }

    if (!mounted) return;
    setState(() {
      _runState = _GroupRunState.active;
      _elapsed = Duration.zero;
      _startedAt = _activeSession?.startedAt ?? DateTime.now();
    });
    if (_currentUserLocation != null) {
      await _joinRunPresence(_currentUserLocation!);
    }
    if (_currentUserLocation != null) {
      await _recordPoint(_currentUserLocation!);
    }
    _startElapsedTimer();
    await _startTracking();
  }

  Future<void> _finishRun() async {
    _isFinishingRun = true;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _elapsedTimer?.cancel();
    _messageSocketService.stopGroupRun(widget.group.id);
    _messageSocketService.leaveGroupRun(widget.group.id);
    if (!mounted) return;
    setState(() {
      _activeSession = null;
      _hasJoinedPresence = false;
      _runState = _GroupRunState.ready;
    });

    if (_routePoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Move a bit more to save this group run.'),
        ),
      );
      _isFinishingRun = false;
      return;
    }

    try {
      await _runApiService.createRun(
        title: '${widget.group.name} Group Run',
        routePoints: List<LatLng>.from(_routePoints),
        territoryPoints: const <LatLng>[],
        distanceMeters: _distanceMeters,
        durationSeconds: _elapsed.inSeconds,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group run saved successfully.')),
      );
      _isFinishingRun = false;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      _isFinishingRun = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_runApiService.extractErrorMessage(error))),
      );
    }
  }

  @override
  void dispose() {
    _messageSocketService.setOnGroupRunParticipants(null);
    _messageSocketService.setOnGroupRunUserJoined(null);
    _messageSocketService.setOnGroupRunUserUpdated(null);
    _messageSocketService.setOnGroupRunUserLeft(null);
    _messageSocketService.setOnGroupRunStarted(null);
    _messageSocketService.setOnGroupRunStopped(null);
    _messageSocketService.leaveGroupRun(widget.group.id);
    _positionSubscription?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableGroups = ref.watch(
      socialViewModelProvider.select((state) => state.groups),
    );
    final groupImage =
        widget.group.imageUrl != null && widget.group.imageUrl!.isNotEmpty
        ? ApiEndpoints.uploadUrl(widget.group.imageUrl!)
        : null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07111A) : Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MapLibreMap(
            styleString: _mapStyle,
            initialCameraPosition: const CameraPosition(
              target: _mapCenter,
              zoom: _idleZoom,
              tilt: _idleTilt,
              bearing: _idleBearing,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onStyleLoadedCallback: () async {
              _isMapStyleReady = true;
              await _syncUserMarker();
              await _syncRouteLine();
              await _syncRemoteParticipantMarkers();
              await _updateParticipantLabelPositions();
            },
            compassEnabled: false,
            myLocationEnabled: false,
            scrollGesturesEnabled: !_isActive,
            zoomGesturesEnabled: !_isActive,
            dragEnabled: !_isActive,
            rotateGesturesEnabled: !_isActive,
            tiltGesturesEnabled: !_isActive,
            onCameraMove: (_) {
              _updateParticipantLabelPositions();
            },
            onCameraIdle: () {
              _updateParticipantLabelPositions();
            },
            attributionButtonMargins: const Point(-1000, -1000),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      for (final label in _participantLabelPositions)
                        Positioned(
                          left: _participantChipLeft(
                            label.point.x.toDouble(),
                            constraints.maxWidth,
                          ),
                          top: _participantChipTop(
                            label.point.y.toDouble(),
                            constraints.maxHeight,
                          ),
                          child: _ParticipantUsernameChip(
                            username: '@${label.participant.username}',
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                18,
                MediaQuery.of(context).padding.top + 10,
                18,
                20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [
                          Color(0xFF07111A),
                          Color(0xEA07111A),
                          Color(0x0007111A),
                        ]
                      : const [
                          Color(0xFFFFFFFF),
                          Color(0xEAFFFFFF),
                          Color(0x00FFFFFF),
                        ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : const Color(0xFF1B1F1C),
                    ),
                  ),
                  const SizedBox(width: 2),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFE4F4DA),
                    backgroundImage: groupImage != null
                        ? NetworkImage(groupImage)
                        : null,
                    child: groupImage == null
                        ? Text(
                            widget.group.name.isEmpty
                                ? 'G'
                                : widget.group.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF3B6D11),
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isActive
                              ? 'Group run in progress'
                              : _isJoinable
                              ? 'A member has started this run. Join when ready.'
                              : 'Live dashboard for your shared run',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF93A7B6)
                                : const Color(0xFF75807A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  _HeaderIconButton(
                    icon: Icons.swap_horiz_rounded,
                    onTap: availableGroups.isEmpty
                        ? null
                        : () => _openGroupSelector(availableGroups),
                  ),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: Icons.info_outline_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              GroupProfileScreen(group: widget.group),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GroupMessageScreen(
                            communityId: widget.group.id,
                            groupName: widget.group.name,
                            groupAvatarUrl:
                                groupImage ??
                                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.group.name)}&background=E6F3DC&color=3B6D11',
                            memberCount: widget.group.memberCount,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: MediaQuery.of(context).padding.top + 92,
            child: SafeArea(
              bottom: false,
              child: _SelectedGroupBar(
                group: widget.group,
                activeCount: _activeMemberCount,
                onChangeGroup: availableGroups.isEmpty
                    ? null
                    : () => _openGroupSelector(availableGroups),
              ),
            ),
          ),
          if (_activeParticipants.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 218,
              child: SafeArea(
                top: false,
                child: _ActiveGroupMembersCard(
                  participants: _activeParticipants.values.toList(),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: _GroupRunBottomCard(
                isRunning: _isActive,
                isJoinable: _isJoinable,
                distanceKm: _distanceMeters / 1000,
                elapsed: _elapsed,
                memberCount: widget.group.memberCount,
                onStartPressed: _startRun,
                onJoinPressed: _joinStartedRun,
                onFinishPressed: _finishRun,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGroupSelector(List<GroupEntity> groups) async {
    final selected = await showModalBottomSheet<GroupEntity>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _GroupSelectorSheet(groups: groups, currentGroupId: widget.group.id),
    );

    if (selected == null || !mounted || selected.id == widget.group.id) {
      return;
    }

    _messageSocketService.leaveGroupRun(widget.group.id);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GroupRunLiveScreen(group: selected)),
    );
  }

  double _participantChipLeft(double rawLeft, double maxWidth) {
    const chipWidth = 108.0;
    final shifted = rawLeft - (chipWidth / 2);
    return shifted.clamp(8.0, max(8.0, maxWidth - chipWidth - 8.0));
  }

  double _participantChipTop(double rawTop, double maxHeight) {
    const chipHeight = 30.0;
    final shifted = rawTop - 42;
    return shifted.clamp(8.0, max(8.0, maxHeight - chipHeight - 8.0));
  }
}

class _GroupRunHeroMap extends StatelessWidget {
  const _GroupRunHeroMap();

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
      height: 208,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MapLibreMap(
              styleString: _mapStyle,
              initialCameraPosition: const CameraPosition(
                target: _mapCenter,
                zoom: 13.6,
                tilt: 38,
                bearing: -18,
              ),
              compassEnabled: false,
              myLocationEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              dragEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              attributionButtonMargins: const Point(-1000, -1000),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x101F9F4B), Color(0x661EAA59)],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: const Color(0xE919221C),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0x335FD46F)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.groups_2_rounded,
                      color: Color(0xFF7DF48A),
                      size: 26,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Separate Group Run Map',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Crew-focused dashboard with its own live tracker',
                            style: TextStyle(
                              color: Color(0xFFD8E8DA),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeHintCard extends StatelessWidget {
  const _ModeHintCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101B25) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE1E9DE),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF31C861).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.route_rounded,
              color: Color(0xFF31C861),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Solo run stays on the normal map. Group run now uses a dedicated dashboard and a separate live tracking screen.',
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: isDark
                    ? const Color(0xFF93A7B6)
                    : const Color(0xFF64706B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGroupsCard extends StatelessWidget {
  const _EmptyGroupsCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101B25) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE1E9DE),
        ),
      ),
      child: Text(
        'No joined groups yet. Join a group from Social first, then come back here to start a group run.',
        style: TextStyle(
          fontSize: 14,
          height: 1.35,
          color: isDark ? const Color(0xFF93A7B6) : const Color(0xFF6E7771),
        ),
      ),
    );
  }
}

class _GroupRunSelectionCard extends StatelessWidget {
  const _GroupRunSelectionCard({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  final GroupEntity group;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = group.imageUrl != null && group.imageUrl!.isNotEmpty
        ? ApiEndpoints.uploadUrl(group.imageUrl!)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF132331) : const Color(0xFFF1FAEE))
                : (isDark ? const Color(0xFF101B25) : Colors.white),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF31C861)
                  : (isDark
                        ? const Color(0xFF233241)
                        : const Color(0xFFE1E9DE)),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFE4F4DA),
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null
                    ? Text(
                        group.name.isEmpty ? 'G' : group.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF3B6D11),
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.memberCount} members',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF93A7B6)
                            : const Color(0xFF707A74),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected
                    ? const Color(0xFF31C861)
                    : (isDark
                          ? const Color(0xFF6B8191)
                          : const Color(0xFF97A09A)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupRunBottomCard extends StatelessWidget {
  const _GroupRunBottomCard({
    required this.isRunning,
    required this.isJoinable,
    required this.distanceKm,
    required this.elapsed,
    required this.memberCount,
    required this.onStartPressed,
    required this.onJoinPressed,
    required this.onFinishPressed,
  });

  final bool isRunning;
  final bool isJoinable;
  final double distanceKm;
  final Duration elapsed;
  final int memberCount;
  final VoidCallback onStartPressed;
  final VoidCallback onJoinPressed;
  final VoidCallback onFinishPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101B25) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF223545) : const Color(0xFFE2EADF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF31C861).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.groups_2_rounded,
                  color: Color(0xFF31C861),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRunning
                          ? 'Group Run Active'
                          : isJoinable
                          ? 'Group Run Joinable'
                          : 'Group Run Ready',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isJoinable
                          ? 'A teammate already started this session'
                          : '$memberCount members in this group',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF93A7B6)
                            : const Color(0xFF6E7771),
                      ),
                    ),
                  ],
                ),
              ),
              if (isRunning)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF31C861).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Color(0xFF31C861),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _GroupMetricTile(
                  label: 'Distance',
                  value: distanceKm.toStringAsFixed(2),
                  suffix: 'km',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GroupMetricTile(
                  label: 'Time',
                  value: _formatDuration(elapsed),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: isRunning
                  ? onFinishPressed
                  : isJoinable
                  ? onJoinPressed
                  : onStartPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning
                    ? const Color(0xFF151C1B)
                    : const Color(0xFF31C861),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: Icon(
                isRunning
                    ? Icons.stop_circle_outlined
                    : isJoinable
                    ? Icons.login_rounded
                    : Icons.play_arrow_rounded,
                size: 20,
              ),
              label: Text(
                isRunning
                    ? 'Finish group run'
                    : isJoinable
                    ? 'Join run'
                    : 'Start group run',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupMetricTile extends StatelessWidget {
  const _GroupMetricTile({
    required this.label,
    required this.value,
    required this.isDark,
    this.suffix,
  });

  final String label;
  final String value;
  final bool isDark;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13212D) : const Color(0xFFF3F7EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF8EA1B0) : const Color(0xFF6F7872),
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF111111),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: value),
                if (suffix != null)
                  TextSpan(
                    text: ' $suffix',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF8EA1B0)
                          : const Color(0xFF6F7872),
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

class _ActiveGroupMembersCard extends StatelessWidget {
  const _ActiveGroupMembersCard({required this.participants});

  final List<GroupRunParticipantSocketPayload> participants;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visible = participants.take(5).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE6101B25) : const Color(0xF8FFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE2EADF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Members on Map',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final participant in visible)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF13212D)
                        : const Color(0xFFF3F7EE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4F7DFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '@${participant.username}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1B241D),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParticipantLabelPosition {
  const _ParticipantLabelPosition({
    required this.participant,
    required this.point,
  });

  final GroupRunParticipantSocketPayload participant;
  final Point<num> point;
}

class _ParticipantUsernameChip extends StatelessWidget {
  const _ParticipantUsernameChip({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xEE111111),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x334F7DFF)),
      ),
      child: Text(
        username,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SelectedGroupBar extends StatelessWidget {
  const _SelectedGroupBar({
    required this.group,
    required this.activeCount,
    this.onChangeGroup,
  });

  final GroupEntity group;
  final int activeCount;
  final VoidCallback? onChangeGroup;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE6101B25) : const Color(0xF8FFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE2EADF),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Group',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF93A7B6)
                        : const Color(0xFF6E7771),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF31C861).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$activeCount active',
              style: const TextStyle(
                color: Color(0xFF31C861),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (onChangeGroup != null) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: onChangeGroup,
              child: const Text(
                'Change',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF13212D) : const Color(0xFFF2F6EE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF233241) : const Color(0xFFE2EADF),
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: isDark ? Colors.white : const Color(0xFF1B241D),
          ),
        ),
      ),
    );
  }
}

class _GroupSelectorSheet extends StatelessWidget {
  const _GroupSelectorSheet({
    required this.groups,
    required this.currentGroupId,
  });

  final List<GroupEntity> groups;
  final String currentGroupId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C151D) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF31424F) : const Color(0xFFD3DAD1),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select Group Run',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final group = groups[index];
                final selected = group.id == currentGroupId;
                return InkWell(
                  onTap: () => Navigator.of(context).pop(group),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? (isDark
                                ? const Color(0xFF132331)
                                : const Color(0xFFF1FAEE))
                          : (isDark
                                ? const Color(0xFF101B25)
                                : const Color(0xFFF8FBF6)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF31C861)
                            : (isDark
                                  ? const Color(0xFF233241)
                                  : const Color(0xFFE2EADF)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${group.memberCount} members',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xFF93A7B6)
                                      : const Color(0xFF6E7771),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.chevron_right_rounded,
                          color: selected
                              ? const Color(0xFF31C861)
                              : (isDark
                                    ? const Color(0xFF93A7B6)
                                    : const Color(0xFF6E7771)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
