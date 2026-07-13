import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/map/presentation/pages/group_run_dashboard_screen.dart';
import 'package:clain_the_run/features/message/data/services/message_socket_service.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:clain_the_run/features/message/presentation/state/group_message_state.dart';
import 'package:clain_the_run/features/message/presentation/view_model/group_message_view_model.dart';
import 'package:clain_the_run/features/message/presentation/widgets/chatbubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

enum GroupMessageMode { chat, voice }

class GroupMessageScreen extends ConsumerStatefulWidget {
  const GroupMessageScreen({
    super.key,
    required this.communityId,
    required this.groupName,
    required this.groupAvatarUrl,
    this.memberCount = 0,
  });

  final String communityId;
  final String groupName;
  final String groupAvatarUrl;
  final int memberCount;

  @override
  ConsumerState<GroupMessageScreen> createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends ConsumerState<GroupMessageScreen> {
  static const _iceServers = <String, dynamic>{
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
  };

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, _VoiceParticipant> _voiceParticipants =
      <String, _VoiceParticipant>{};
  final Map<String, RTCPeerConnection> _voiceConnections =
      <String, RTCPeerConnection>{};
  final Map<String, RTCVideoRenderer> _voiceRenderers =
      <String, RTCVideoRenderer>{};
  final Map<String, MediaStream> _remoteVoiceStreams = <String, MediaStream>{};
  final Map<String, Future<RTCPeerConnection>> _voiceConnectionTasks =
      <String, Future<RTCPeerConnection>>{};
  final Map<String, List<Map<String, dynamic>>> _pendingVoiceCandidates =
      <String, List<Map<String, dynamic>>>{};
  final Set<String> _voiceOfferedPeers = <String>{};
  final Set<String> _voiceOfferingPeers = <String>{};
  final Set<String> _voiceRemoteDescriptionReady = <String>{};

  late final MessageSocketService _messageSocketService;
  GroupMessageMode _mode = GroupMessageMode.chat;
  MediaStream? _localVoiceStream;
  bool _isVoiceJoined = false;
  bool _isVoiceConnecting = false;
  bool _isTalking = false;
  String? _voiceError;

  void _logVoice(String message) {
    debugPrint('[GroupVoice ${widget.communityId}] $message');
  }

  void _announceVoicePresence() {
    final authState = ref.read(authViewModelProvider);
    final self = authState.authEntity;
    final selfId = self?.id ?? '';
    if (selfId.isEmpty) {
      _logVoice('Skipped voice join announce because self id is missing');
      return;
    }

    _messageSocketService.joinGroupVoice(
      communityId: widget.communityId,
      userId: selfId,
      name: self?.fullname ?? 'Runner',
      avatarUrl: self?.profileUrl,
    );
    _logVoice('Announced voice presence for user=$selfId');
  }

  @override
  void initState() {
    super.initState();
    _messageSocketService = ref.read(messageSocketServiceProvider);
    _messageSocketService.setOnGroupVoiceParticipants(_handleVoiceParticipants);
    _messageSocketService.setOnGroupVoiceUserJoined(_handleVoiceUserJoined);
    _messageSocketService.setOnGroupVoiceUserLeft(_handleVoiceUserLeft);
    _messageSocketService.setOnGroupVoiceSignal(_handleVoiceSignal);

    Future.microtask(() async {
      final notifier = ref.read(groupMessageViewModelProvider.notifier);
      await notifier.joinGroup(widget.communityId);
      await notifier.loadMessages(widget.communityId, force: true);
    });
  }

  @override
  void dispose() {
    ref
        .read(groupMessageViewModelProvider.notifier)
        .leaveGroup(widget.communityId);
    _messageSocketService.setOnGroupVoiceParticipants(null);
    _messageSocketService.setOnGroupVoiceUserJoined(null);
    _messageSocketService.setOnGroupVoiceUserLeft(null);
    _messageSocketService.setOnGroupVoiceSignal(null);
    _messageSocketService.leaveGroupVoice(widget.communityId);
    _disposeVoiceResources();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final error = await ref
        .read(groupMessageViewModelProvider.notifier)
        .sendMessage(widget.communityId, text);
    if (!mounted) return;

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    _controller.clear();
    _scrollToBottom();
  }

  Future<void> _ensureVoiceMode() async {
    if (_isVoiceJoined || _isVoiceConnecting) return;

    final microphoneStatus = await Permission.microphone.request();
    if (!microphoneStatus.isGranted) {
      if (!mounted) return;
      setState(() {
        _voiceError = 'Microphone permission is required for walkie talkie.';
      });
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final self = authState.authEntity;
    final selfId = self?.id ?? '';
    if (selfId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _voiceError = 'Could not identify the current user.';
      });
      return;
    }

    setState(() {
      _isVoiceConnecting = true;
      _voiceError = null;
    });

    try {
      _logVoice('Joining voice room');
      await _messageSocketService.connect();
      _localVoiceStream ??= await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });
      for (final track in _localVoiceStream?.getAudioTracks() ?? const []) {
        track.enabled = false;
        try {
          await Helper.setMicrophoneMute(true, track);
        } catch (_) {}
      }
      try {
        await Helper.setSpeakerphoneOnButPreferBluetooth();
      } catch (_) {
        await Helper.setSpeakerphoneOn(true);
      }

      _announceVoicePresence();
      _logVoice('Local voice stream ready for user=$selfId');

      if (!mounted) return;
      setState(() {
        _isVoiceJoined = true;
        _isVoiceConnecting = false;
        _voiceParticipants[selfId] = _VoiceParticipant(
          userId: selfId,
          name: self?.fullname ?? 'Runner',
          avatarUrl: self?.profileUrl,
          isSelf: true,
          isConnected: true,
        );
      });
    } catch (error) {
      _logVoice('Failed to start voice mode: $error');
      if (!mounted) return;
      setState(() {
        _isVoiceConnecting = false;
        _voiceError = 'Could not start walkie talkie. ${error.toString()}';
      });
    }
  }

  Future<void> _disposeVoiceResources() async {
    _isTalking = false;
    for (final track in _localVoiceStream?.getAudioTracks() ?? const []) {
      track.enabled = false;
      try {
        await Helper.setMicrophoneMute(true, track);
      } catch (_) {}
      track.stop();
    }
    for (final connection in _voiceConnections.values) {
      await connection.close();
    }
    for (final renderer in _voiceRenderers.values) {
      renderer.srcObject = null;
      await renderer.dispose();
    }
    for (final stream in _remoteVoiceStreams.values) {
      for (final track in stream.getTracks()) {
        track.stop();
      }
      await stream.dispose();
    }
    await _localVoiceStream?.dispose();
    _localVoiceStream = null;
    _voiceConnections.clear();
    _voiceRenderers.clear();
    _remoteVoiceStreams.clear();
    _voiceConnectionTasks.clear();
    _pendingVoiceCandidates.clear();
    _voiceOfferedPeers.clear();
    _voiceOfferingPeers.clear();
    _voiceRemoteDescriptionReady.clear();
    _voiceParticipants.clear();
    _isVoiceJoined = false;
    _isVoiceConnecting = false;
    try {
      await Helper.setSpeakerphoneOn(false);
    } catch (_) {}
  }

  Future<void> _setTalking(bool enabled) async {
    if (!_isVoiceJoined || _localVoiceStream == null) {
      if (!_isVoiceConnecting) {
        await _ensureVoiceMode();
      }
      return;
    }

    if (_voiceConnections.isEmpty && _voiceParticipants.length <= 1) {
      _logVoice(
        'No active peer connections detected, re-announcing voice presence',
      );
      _announceVoicePresence();
    }

    _logVoice('Push-to-talk ${enabled ? 'started' : 'stopped'}');
    for (final track in _localVoiceStream?.getAudioTracks() ?? const []) {
      track.enabled = enabled;
      try {
        await Helper.setMicrophoneMute(!enabled, track);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _isTalking = enabled;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleVoiceParticipants(
    String communityId,
    List<GroupVoiceParticipantSocketPayload> participants,
  ) {
    if (communityId != widget.communityId || !mounted) return;

    _logVoice(
      'Received participants: ${participants.map((p) => p.userId).join(', ')}',
    );
    for (final participant in participants) {
      _upsertVoiceParticipant(participant);
      if (_shouldCreateVoiceOffer(participant.userId)) {
        _createVoiceOffer(participant);
      }
    }
    setState(() {});
  }

  void _handleVoiceUserJoined(
    String communityId,
    GroupVoiceParticipantSocketPayload participant,
  ) {
    if (communityId != widget.communityId || !mounted) return;
    _logVoice('User joined voice room: ${participant.userId}');
    _upsertVoiceParticipant(participant);
    if (_shouldCreateVoiceOffer(participant.userId)) {
      Future<void>.microtask(() => _createVoiceOffer(participant));
    }
    setState(() {});
  }

  void _handleVoiceUserLeft(String communityId, String userId) {
    if (communityId != widget.communityId) return;
    _logVoice('User left voice room: $userId');
    _voiceParticipants.remove(userId);
    final connection = _voiceConnections.remove(userId);
    _voiceConnectionTasks.remove(userId);
    final renderer = _voiceRenderers.remove(userId);
    final candidates = _pendingVoiceCandidates.remove(userId);
    _voiceOfferedPeers.remove(userId);
    _voiceOfferingPeers.remove(userId);
    _voiceRemoteDescriptionReady.remove(userId);
    if (candidates != null) {
      candidates.clear();
    }
    connection?.close();
    if (renderer != null) {
      renderer.srcObject = null;
      renderer.dispose();
    }
    final remoteStream = _remoteVoiceStreams.remove(userId);
    if (remoteStream != null) {
      for (final track in remoteStream.getTracks()) {
        track.stop();
      }
      remoteStream.dispose();
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _handleVoiceSignal(Map<String, dynamic> payload) async {
    if (payload['communityId']?.toString() != widget.communityId) return;

    if (!_isVoiceJoined && !_isVoiceConnecting) {
      await _ensureVoiceMode();
    }
    if (!_isVoiceJoined) {
      _logVoice('Ignoring voice signal because voice mode is not ready yet');
      return;
    }

    final senderUserId = payload['senderUserId']?.toString() ?? '';
    if (senderUserId.isEmpty) return;

    final authState = ref.read(authViewModelProvider);
    if (senderUserId == authState.authEntity?.id) return;

    final participant = GroupVoiceParticipantSocketPayload(
      userId: senderUserId,
      name: payload['senderName']?.toString() ?? 'Runner',
      avatarUrl: payload['senderAvatarUrl']?.toString(),
    );
    _upsertVoiceParticipant(participant);
    final data = payload['data'];
    if (data is! Map) return;
    final signal = Map<String, dynamic>.from(data);
    final type = signal['type']?.toString();
    _logVoice('Received signal type=$type from=$senderUserId');

    if (type == 'offer') {
      final connection = await _getOrCreateVoiceConnection(participant);
      final sdp = signal['sdp']?.toString();
      if (sdp == null) return;
      await connection.setRemoteDescription(
        RTCSessionDescription(sdp, 'offer'),
      );
      _logVoice('Remote offer description set for $senderUserId');
      _voiceRemoteDescriptionReady.add(senderUserId);
      final answer = await connection.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      await connection.setLocalDescription(answer);
      _logVoice('Created local answer for $senderUserId');
      _messageSocketService.signalGroupVoice({
        'communityId': widget.communityId,
        'targetUserId': senderUserId,
        'senderUserId': authState.authEntity?.id,
        'senderName': authState.authEntity?.fullname ?? 'Runner',
        'senderAvatarUrl': authState.authEntity?.profileUrl,
        'data': {'type': 'answer', 'sdp': answer.sdp},
      });
      await _flushPendingVoiceCandidates(senderUserId);
      return;
    }

    if (type == 'answer') {
      final connection = _voiceConnections[senderUserId];
      final sdp = signal['sdp']?.toString();
      if (connection == null || sdp == null) return;
      await connection.setRemoteDescription(
        RTCSessionDescription(sdp, 'answer'),
      );
      _logVoice('Remote answer description set for $senderUserId');
      _voiceRemoteDescriptionReady.add(senderUserId);
      await _flushPendingVoiceCandidates(senderUserId);
      return;
    }

    if (type == 'candidate') {
      final connection = _voiceConnections[senderUserId];
      if (connection == null ||
          !_voiceRemoteDescriptionReady.contains(senderUserId)) {
        _logVoice(
          'Queueing ICE candidate from $senderUserId '
          '(connection=${connection != null}, remoteReady=${_voiceRemoteDescriptionReady.contains(senderUserId)})',
        );
        _pendingVoiceCandidates.putIfAbsent(senderUserId, () => []).add(signal);
        return;
      }
      await _addVoiceCandidate(connection, signal);
    }
  }

  void _upsertVoiceParticipant(GroupVoiceParticipantSocketPayload participant) {
    final authState = ref.read(authViewModelProvider);
    final isSelf = participant.userId == authState.authEntity?.id;
    _voiceParticipants[participant.userId] = _VoiceParticipant(
      userId: participant.userId,
      name: participant.name,
      avatarUrl: participant.avatarUrl,
      isSelf: isSelf,
      isConnected:
          _voiceParticipants[participant.userId]?.isConnected ?? isSelf,
    );
  }

  bool _shouldCreateVoiceOffer(String participantUserId) {
    final selfId = ref.read(authViewModelProvider).authEntity?.id ?? '';
    if (selfId.isEmpty) return false;
    return selfId.compareTo(participantUserId) > 0;
  }

  Future<void> _createVoiceOffer(
    GroupVoiceParticipantSocketPayload participant,
  ) async {
    if (_voiceOfferedPeers.contains(participant.userId) ||
        _voiceOfferingPeers.contains(participant.userId)) {
      return;
    }
    _voiceOfferingPeers.add(participant.userId);
    _logVoice('Creating offer for ${participant.userId}');
    try {
      final connection = await _getOrCreateVoiceConnection(participant);
      final signalingState = await connection.getSignalingState();
      if (signalingState != RTCSignalingState.RTCSignalingStateStable) {
        _logVoice(
          'Skipped offer for ${participant.userId} because signalingState=$signalingState',
        );
        return;
      }

      final offer = await connection.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      await connection.setLocalDescription(offer);
      _logVoice('Local offer created for ${participant.userId}');
      _voiceOfferedPeers.add(participant.userId);

      final authState = ref.read(authViewModelProvider);
      _messageSocketService.signalGroupVoice({
        'communityId': widget.communityId,
        'targetUserId': participant.userId,
        'senderUserId': authState.authEntity?.id,
        'senderName': authState.authEntity?.fullname ?? 'Runner',
        'senderAvatarUrl': authState.authEntity?.profileUrl,
        'data': {'type': 'offer', 'sdp': offer.sdp},
      });
    } finally {
      _voiceOfferingPeers.remove(participant.userId);
    }
  }

  Future<RTCPeerConnection> _getOrCreateVoiceConnection(
    GroupVoiceParticipantSocketPayload participant,
  ) async {
    final existing = _voiceConnections[participant.userId];
    if (existing != null) return existing;

    final existingTask = _voiceConnectionTasks[participant.userId];
    if (existingTask != null) {
      return existingTask;
    }

    final task = _buildVoiceConnection(participant);
    _voiceConnectionTasks[participant.userId] = task;
    try {
      final connection = await task;
      _voiceConnections[participant.userId] = connection;
      return connection;
    } finally {
      _voiceConnectionTasks.remove(participant.userId);
    }
  }

  Future<RTCPeerConnection> _buildVoiceConnection(
    GroupVoiceParticipantSocketPayload participant,
  ) async {
    _logVoice('Creating peer connection for ${participant.userId}');
    final connection = await createPeerConnection(_iceServers);
    final localStream = _localVoiceStream;
    if (localStream != null) {
      for (final track in localStream.getTracks()) {
        await connection.addTrack(track, localStream);
      }
    }

    connection.onTrack = (event) {
      _logVoice(
        'onTrack for ${participant.userId}: '
        'kind=${event.track.kind}, streams=${event.streams.length}',
      );
      _attachRemoteVoiceStream(participant.userId, event);
      final current = _voiceParticipants[participant.userId];
      if (current == null || !mounted) return;
      setState(() {
        _voiceParticipants[participant.userId] = current.copyWith(
          isConnected: true,
        );
      });
    };

    connection.onAddStream = (stream) {
      _logVoice(
        'onAddStream for ${participant.userId}: '
        'audioTracks=${stream.getAudioTracks().length}',
      );
      _attachLegacyRemoteVoiceStream(participant.userId, stream);
      final current = _voiceParticipants[participant.userId];
      if (current == null || !mounted) return;
      setState(() {
        _voiceParticipants[participant.userId] = current.copyWith(
          isConnected: true,
        );
      });
    };

    connection.onConnectionState = (connectionState) {
      _logVoice('Connection state for ${participant.userId}: $connectionState');
      final current = _voiceParticipants[participant.userId];
      if (current == null || !mounted) return;
      if (connectionState ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        setState(() {
          _voiceParticipants[participant.userId] = current.copyWith(
            isConnected: true,
          );
        });
      } else if (connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        setState(() {
          _voiceParticipants[participant.userId] = current.copyWith(
            isConnected: false,
          );
        });
      }
    };

    connection.onIceCandidate = (candidate) {
      if (candidate.candidate == null) return;
      _logVoice('Sending ICE candidate to ${participant.userId}');
      final authState = ref.read(authViewModelProvider);
      _messageSocketService.signalGroupVoice({
        'communityId': widget.communityId,
        'targetUserId': participant.userId,
        'senderUserId': authState.authEntity?.id,
        'senderName': authState.authEntity?.fullname ?? 'Runner',
        'senderAvatarUrl': authState.authEntity?.profileUrl,
        'data': {
          'type': 'candidate',
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      });
    };

    return connection;
  }

  Future<void> _attachRemoteVoiceStream(
    String userId,
    RTCTrackEvent event,
  ) async {
    final MediaStream stream;
    if (event.streams.isNotEmpty) {
      stream = event.streams.first;
    } else {
      stream =
          _remoteVoiceStreams[userId] ??
          await createLocalMediaStream('group_voice_remote_$userId');
      if (!_remoteVoiceStreams.containsKey(userId)) {
        _remoteVoiceStreams[userId] = stream;
      }

      final remoteTrack = event.track;
      remoteTrack.enabled = true;
      final existingTrackIds = stream
          .getTracks()
          .map((track) => track.id)
          .toSet();
      if (!existingTrackIds.contains(remoteTrack.id)) {
        await stream.addTrack(remoteTrack);
      }
    }

    final renderer =
        _voiceRenderers[userId] ?? await _createVoiceRenderer(userId);
    renderer.srcObject = stream;
    _logVoice(
      'Attached remote stream for $userId '
      'with audioTracks=${stream.getAudioTracks().length}',
    );
    for (final track in stream.getAudioTracks()) {
      track.enabled = true;
      try {
        await Helper.setVolume(1.0, track);
      } catch (_) {}
    }
    try {
      await Helper.setSpeakerphoneOnButPreferBluetooth();
    } catch (_) {}
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _attachLegacyRemoteVoiceStream(
    String userId,
    MediaStream stream,
  ) async {
    _remoteVoiceStreams[userId] = stream;
    final renderer =
        _voiceRenderers[userId] ?? await _createVoiceRenderer(userId);
    renderer.srcObject = stream;
    _logVoice(
      'Attached legacy remote stream for $userId '
      'with audioTracks=${stream.getAudioTracks().length}',
    );
    for (final track in stream.getAudioTracks()) {
      track.enabled = true;
      try {
        await Helper.setVolume(1.0, track);
      } catch (_) {}
    }
    try {
      await Helper.setSpeakerphoneOnButPreferBluetooth();
    } catch (_) {}
    if (!mounted) return;
    setState(() {});
  }

  Future<RTCVideoRenderer> _createVoiceRenderer(String userId) async {
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    _voiceRenderers[userId] = renderer;
    return renderer;
  }

  Future<void> _flushPendingVoiceCandidates(String userId) async {
    final connection = _voiceConnections[userId];
    final queued = _pendingVoiceCandidates.remove(userId);
    if (connection == null ||
        queued == null ||
        !_voiceRemoteDescriptionReady.contains(userId)) {
      return;
    }
    _logVoice('Flushing ${queued.length} queued ICE candidates for $userId');
    for (final signal in queued) {
      await _addVoiceCandidate(connection, signal);
    }
  }

  Future<void> _addVoiceCandidate(
    RTCPeerConnection connection,
    Map<String, dynamic> signal,
  ) async {
    final candidate = signal['candidate']?.toString();
    if (candidate == null) return;
    _logVoice('Applying ICE candidate');
    await connection.addCandidate(
      RTCIceCandidate(
        candidate,
        signal['sdpMid']?.toString(),
        signal['sdpMLineIndex'] as int?,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(groupMessageViewModelProvider);
    final messages = state.messagesFor(widget.communityId);

    ref.listen(groupMessageViewModelProvider, (previous, next) {
      if (next.messagesFor(widget.communityId).length != messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07111A) : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _GroupMessageHeader(
                  groupName: widget.groupName,
                  groupAvatarUrl: widget.groupAvatarUrl,
                  memberCount: widget.memberCount,
                  selectedMode: _mode,
                  onBack: () => Navigator.of(context).pop(),
                  onRunTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GroupRunDashboardScreen(
                          initialGroupId: widget.communityId,
                          autoOpenSelectedGroup: true,
                        ),
                      ),
                    );
                  },
                  onModeChanged: (mode) {
                    setState(() {
                      _mode = mode;
                    });
                    if (mode == GroupMessageMode.voice) {
                      Future<void>.microtask(_ensureVoiceMode);
                    }
                  },
                ),
                Expanded(
                  child: _mode == GroupMessageMode.chat
                      ? Builder(
                          builder: (context) {
                            if (state.status == GroupMessageStatus.loading &&
                                messages.isEmpty) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state.errorMessage != null &&
                                messages.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    state.errorMessage!,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            if (messages.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'No group messages yet. Start the conversation.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () => ref
                                  .read(groupMessageViewModelProvider.notifier)
                                  .loadMessages(
                                    widget.communityId,
                                    force: true,
                                  ),
                              child: ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  16,
                                ),
                                itemCount: messages.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  return _GroupMessageBubble(message: message);
                                },
                              ),
                            );
                          },
                        )
                      : _WalkieTalkiePanel(
                          isConnecting: _isVoiceConnecting,
                          isJoined: _isVoiceJoined,
                          isTalking: _isTalking,
                          errorMessage: _voiceError,
                          participants: _voiceParticipants.values.toList()
                            ..sort(
                              (a, b) => a.isSelf
                                  ? -1
                                  : b.isSelf
                                  ? 1
                                  : a.name.compareTo(b.name),
                            ),
                          onPressStart: () => _setTalking(true),
                          onPressEnd: () => _setTalking(false),
                          onRetry: _ensureVoiceMode,
                        ),
                ),
                if (_mode == GroupMessageMode.chat)
                  _GroupMessageInputBar(
                    controller: _controller,
                    onSend: _sendMessage,
                  ),
              ],
            ),
            if (_voiceRenderers.isNotEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: SizedBox(
                    width: 1,
                    height: 1,
                    child: OverflowBox(
                      maxWidth: 1,
                      maxHeight: 1,
                      child: Column(
                        children: [
                          for (final renderer in _voiceRenderers.values)
                            SizedBox(
                              width: 1,
                              height: 1,
                              child: RTCVideoView(
                                renderer,
                                objectFit: RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitContain,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VoiceParticipant {
  const _VoiceParticipant({
    required this.userId,
    required this.name,
    required this.isSelf,
    this.avatarUrl,
    this.isConnected = false,
  });

  final String userId;
  final String name;
  final String? avatarUrl;
  final bool isSelf;
  final bool isConnected;

  _VoiceParticipant copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    bool? isSelf,
    bool? isConnected,
  }) {
    return _VoiceParticipant(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSelf: isSelf ?? this.isSelf,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class _GroupMessageBubble extends StatelessWidget {
  const _GroupMessageBubble({required this.message});

  final GroupMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarUrl =
        message.sender.profileUrl != null &&
            message.sender.profileUrl!.isNotEmpty
        ? ApiEndpoints.profileImageUrl(message.sender.profileUrl!)
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(message.sender.fullname)}&background=E6F3DC&color=3B6D11';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: message.isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!message.isMine) ...[
          CircleAvatar(radius: 15, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: message.isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!message.isMine)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    message.sender.fullname,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFB3BEC8)
                          : const Color(0xFF5A5A5A),
                    ),
                  ),
                ),
              ChatBubble(
                text: message.text,
                timestamp: _formatTime(message.createdAt),
                isMine: message.isMine,
                isRead: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class _GroupMessageHeader extends StatelessWidget {
  const _GroupMessageHeader({
    required this.groupName,
    required this.groupAvatarUrl,
    required this.memberCount,
    required this.selectedMode,
    required this.onBack,
    required this.onRunTap,
    required this.onModeChanged,
  });

  final String groupName;
  final String groupAvatarUrl;
  final int memberCount;
  final GroupMessageMode selectedMode;
  final VoidCallback onBack;
  final VoidCallback onRunTap;
  final ValueChanged<GroupMessageMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF07111A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF233241) : const Color(0xFFEDEDEA),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(groupAvatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    Text(
                      '$memberCount members',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF9BA8B4)
                            : const Color(0xFF8B8B8B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onRunTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B6D11),
                  side: const BorderSide(color: Color(0xFFCFE4BF)),
                  backgroundColor: isDark
                      ? const Color(0xFF111C26)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.directions_run_rounded, size: 18),
                label: const Text(
                  'Join Run',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ModeSwitch(selectedMode: selectedMode, onModeChanged: onModeChanged),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.selectedMode, required this.onModeChanged});

  final GroupMessageMode selectedMode;
  final ValueChanged<GroupMessageMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : const Color(0xFFF4F5F2),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: 'Chat',
              icon: Icons.chat_bubble_rounded,
              isSelected: selectedMode == GroupMessageMode.chat,
              onTap: () => onModeChanged(GroupMessageMode.chat),
            ),
          ),
          Expanded(
            child: _ModeChip(
              label: 'Voice',
              icon: Icons.mic_rounded,
              isSelected: selectedMode == GroupMessageMode.voice,
              onTap: () => onModeChanged(GroupMessageMode.voice),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isSelected ? const Color(0xFF72B63E) : Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white : const Color(0xFF4A4A4A)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF4A4A4A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupMessageInputBar extends StatelessWidget {
  const _GroupMessageInputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF07111A) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF233241) : const Color(0xFFEDEDEA),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF111C26)
                      : const Color(0xFFF4F5F2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type a message...',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: const Color(0xFF72B63E),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onSend,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkieTalkiePanel extends StatelessWidget {
  const _WalkieTalkiePanel({
    required this.isConnecting,
    required this.isJoined,
    required this.isTalking,
    required this.participants,
    required this.onPressStart,
    required this.onPressEnd,
    this.errorMessage,
    this.onRetry,
  });

  final bool isConnecting;
  final bool isJoined;
  final bool isTalking;
  final List<_VoiceParticipant> participants;
  final String? errorMessage;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111C26) : const Color(0xFFF6F7F3),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF233241)
                    : const Color(0xFFE3E6DE),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  isTalking ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                  size: 52,
                  color: const Color(0xFF72B63E),
                ),
                const SizedBox(height: 12),
                Text(
                  isConnecting
                      ? 'Connecting to walkie talkie...'
                      : isTalking
                      ? 'Broadcasting to the group'
                      : isJoined
                      ? 'Hold to talk'
                      : 'Join the voice room',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ??
                      (isJoined
                          ? 'Press and hold the button below to speak to connected group members.'
                          : 'Open voice mode and the app will connect you to the group walkie talkie room.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF9BA8B4)
                        : const Color(0xFF6E6E6E),
                  ),
                ),
                if (errorMessage != null && onRetry != null) ...[
                  const SizedBox(height: 12),
                  TextButton(onPressed: onRetry, child: const Text('Retry')),
                ],
                const SizedBox(height: 18),
                GestureDetector(
                  onLongPressStart: (_) => onPressStart(),
                  onLongPressEnd: (_) => onPressEnd(),
                  onLongPressCancel: onPressEnd,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isTalking
                          ? const Color(0xFF5FA52F)
                          : const Color(0xFF72B63E),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF72B63E,
                          ).withValues(alpha: isTalking ? 0.45 : 0.24),
                          blurRadius: isTalking ? 28 : 14,
                          spreadRadius: isTalking ? 6 : 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.mic_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isTalking ? 'Talking...' : 'Hold',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Connected Participants',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: participants.isEmpty
                ? Center(
                    child: Text(
                      'No one else is in the voice room yet.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF9BA8B4)
                            : const Color(0xFF6E6E6E),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: participants.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final participant = participants[index];
                      final avatarUrl =
                          participant.avatarUrl != null &&
                              participant.avatarUrl!.isNotEmpty
                          ? ApiEndpoints.profileImageUrl(participant.avatarUrl!)
                          : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(participant.name)}&background=E6F3DC&color=3B6D11';
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF111C26)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF233241)
                                : const Color(0xFFE3E6DE),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(avatarUrl),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    participant.isSelf
                                        ? '${participant.name} (You)'
                                        : participant.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF111111),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    participant.isConnected
                                        ? 'Connected'
                                        : 'Connecting...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: participant.isConnected
                                          ? const Color(0xFF72B63E)
                                          : const Color(0xFFE08A2E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: participant.isConnected
                                    ? const Color(0xFF72B63E)
                                    : const Color(0xFFB0B0B0),
                              ),
                            ),
                          ],
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
