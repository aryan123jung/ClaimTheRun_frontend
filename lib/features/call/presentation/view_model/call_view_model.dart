import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/call/data/services/call_socket_service.dart';
import 'package:clain_the_run/features/call/presentation/state/call_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

final callViewModelProvider = NotifierProvider<CallViewModel, CallState>(
  CallViewModel.new,
);

class CallViewModel extends Notifier<CallState> {
  static const _incomingCallSound = 'sounds/incoming-call.mp3';
  static const _outgoingCallSound = 'sounds/outgoing-call.mp3';
  static const _iceServers = <String, dynamic>{
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
  };

  late final CallSocketService _socketService;
  final _uuid = const Uuid();
  final AudioPlayer _ringtonePlayer = AudioPlayer();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  bool _listenersBound = false;
  Map<String, dynamic>? _pendingOffer;
  final List<Map<String, dynamic>> _pendingCandidates = [];

  @override
  CallState build() {
    _socketService = ref.read(callSocketServiceProvider);
    _bindSocketListeners();
    Future<void>.microtask(() async {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      await _socketService.connect();
    });
    ref.onDispose(() async {
      await _stopRingtone();
      await _disposeCallResources();
      await _localRenderer.dispose();
      await _remoteRenderer.dispose();
      await _ringtonePlayer.dispose();
    });
    return const CallState();
  }

  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> ensureReady() async {
    final selfId = ref.read(authViewModelProvider).authEntity?.id;
    if (selfId != null && selfId.isNotEmpty && state.selfId != selfId) {
      state = state.copyWith(selfId: selfId);
    }
    await _socketService.connect();
  }

  Future<bool> startAudioCall({
    required String friendId,
    required String friendName,
    required String avatarUrl,
  }) async {
    return _startCall(
      friendId: friendId,
      friendName: friendName,
      avatarUrl: avatarUrl,
      isVideo: false,
    );
  }

  Future<bool> startVideoCall({
    required String friendId,
    required String friendName,
    required String avatarUrl,
  }) async {
    return _startCall(
      friendId: friendId,
      friendName: friendName,
      avatarUrl: avatarUrl,
      isVideo: true,
    );
  }

  Future<bool> _startCall({
    required String friendId,
    required String friendName,
    required String avatarUrl,
    required bool isVideo,
  }) async {
    try {
      await ensureReady();

      final selfId = state.selfId;
      if (selfId == null || selfId.isEmpty) {
        state = state.copyWith(
          status: CallStatus.error,
          errorMessage: 'Could not identify the current user for calling.',
        );
        return false;
      }

      final hasPermission = await _requestPermissions(isVideo: isVideo);
      if (!hasPermission) {
        state = state.copyWith(
          status: CallStatus.error,
          errorMessage: isVideo
              ? 'Microphone and camera permissions are required for video calls.'
              : 'Microphone permission is required for audio calls.',
        );
        return false;
      }

      await _disposeCallResources();

      final callerName =
          ref.read(authViewModelProvider).authEntity?.fullname ?? 'Runner';
      final callerAvatarUrl =
          ref.read(authViewModelProvider).authEntity?.profileUrl ?? '';
      final callId = _uuid.v4();

      state = CallState(
        status: CallStatus.outgoing,
        callId: callId,
        selfId: selfId,
        participant: CallParticipant(
          id: friendId,
          name: friendName,
          avatarUrl: avatarUrl,
        ),
        isVideo: isVideo,
      );
      await _playOutgoingRingtone();

      await _createPeerConnection(isCaller: true);
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': isVideo,
      });
      await _peerConnection!.setLocalDescription(offer);

      _socketService.invite({
        'callId': callId,
        'callerId': selfId,
        'callerName': callerName,
        'callerAvatarUrl': callerAvatarUrl,
        'receiverId': friendId,
        'isVideo': isVideo,
        'createdAt': DateTime.now().toIso8601String(),
      });

      _socketService.signal({
        'callId': callId,
        'fromUserId': selfId,
        'toUserId': friendId,
        'data': {'type': 'offer', 'sdp': offer.sdp},
      });
      return true;
    } catch (error) {
      await _stopRingtone();
      await _disposeCallResources();
      state = CallState(
        status: CallStatus.error,
        selfId: state.selfId,
        errorMessage:
            'Could not start the ${isVideo ? 'video' : 'audio'} call. ${error.toString()}',
      );
      return false;
    }
  }

  Future<void> acceptIncomingCall() async {
    final participant = state.participant;
    final callId = state.callId;
    final selfId = state.selfId;
    if (participant == null || callId == null || selfId == null) return;

    final hasPermission = await _requestPermissions(isVideo: state.isVideo);
    if (!hasPermission) {
      state = state.copyWith(
        status: CallStatus.error,
        errorMessage: state.isVideo
            ? 'Microphone and camera permissions are required for video calls.'
            : 'Microphone permission is required for audio calls.',
      );
      return;
    }

    await _createPeerConnection(isCaller: false);
    state = state.copyWith(status: CallStatus.connecting, clearError: true);
    await _stopRingtone();
    await _updateSpeakerRoute(enabled: state.isVideo);

    await _applyPendingOffer();
    await _flushPendingCandidates();
    _socketService.accept({'callId': callId, 'callerId': participant.id});
  }

  Future<void> declineIncomingCall() async {
    final participant = state.participant;
    final callId = state.callId;
    if (participant != null && callId != null) {
      _socketService.decline({'callId': callId, 'callerId': participant.id});
    }
    await _endLocally(status: CallStatus.declined);
  }

  Future<void> endCurrentCall() async {
    final participant = state.participant;
    final callId = state.callId;
    if (participant != null && callId != null) {
      _socketService.end({'callId': callId, 'otherUserId': participant.id});
    }
    await _endLocally();
  }

  Future<void> toggleMute() async {
    final enabled = !state.isMuted;
    final audioTracks = _localStream?.getAudioTracks() ?? const [];
    for (final track in audioTracks) {
      track.enabled = !enabled;
    }
    state = state.copyWith(isMuted: enabled);
  }

  Future<void> toggleCamera() async {
    if (!state.isVideo) return;
    final enabled = !state.isCameraEnabled;
    final videoTracks = _localStream?.getVideoTracks() ?? const [];
    for (final track in videoTracks) {
      track.enabled = enabled;
    }
    state = state.copyWith(isCameraEnabled: enabled);
  }

  void _bindSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;
    _socketService.onIncomingCall = _handleIncomingCall;
    _socketService.onAccepted = _handleAccepted;
    _socketService.onDeclined = _handleDeclined;
    _socketService.onEnded = _handleEnded;
    _socketService.onSignal = _handleSignal;
  }

  void _handleIncomingCall(Map<String, dynamic> payload) {
    _pendingOffer = null;
    _pendingCandidates.clear();
    final selfId =
        ref.read(authViewModelProvider).authEntity?.id ?? state.selfId;
    state = CallState(
      status: CallStatus.incoming,
      callId: payload['callId']?.toString(),
      selfId: selfId,
      participant: CallParticipant(
        id: payload['callerId']?.toString() ?? '',
        name: payload['callerName']?.toString() ?? 'Runner',
        avatarUrl: payload['callerAvatarUrl']?.toString() ?? '',
      ),
      isVideo: payload['isVideo'] == true,
    );
    unawaited(_playIncomingRingtone());
  }

  void _handleAccepted(Map<String, dynamic> payload) {
    if (payload['callId']?.toString() != state.callId) return;
    unawaited(_stopRingtone());
    state = state.copyWith(status: CallStatus.connecting, clearError: true);
  }

  void _handleDeclined(Map<String, dynamic> payload) {
    if (payload['callId']?.toString() != state.callId) return;
    unawaited(_endLocally(status: CallStatus.declined));
  }

  void _handleEnded(Map<String, dynamic> payload) {
    if (payload['callId']?.toString() != state.callId) return;
    unawaited(_endLocally(status: CallStatus.ended));
  }

  Future<void> _handleSignal(Map<String, dynamic> payload) async {
    final callId = payload['callId']?.toString();
    if (callId == null || callId != state.callId) return;

    final data = payload['data'];
    if (data is! Map) return;
    final signal = Map<String, dynamic>.from(data);
    final type = signal['type']?.toString();

    if (type == 'offer') {
      final sdp = signal['sdp']?.toString();
      if (sdp == null) return;
      _pendingOffer = signal;
      if (state.status != CallStatus.incoming || _peerConnection == null) {
        return;
      }

      await _applyPendingOffer();
      await _flushPendingCandidates();
      return;
    }

    if (type == 'answer') {
      final sdp = signal['sdp']?.toString();
      if (sdp == null || _peerConnection == null) return;
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp, 'answer'),
      );
      await _stopRingtone();
      state = state.copyWith(status: CallStatus.connected, clearError: true);
      return;
    }

    if (type == 'candidate') {
      if (_peerConnection == null) {
        _pendingCandidates.add(signal);
        return;
      }
      await _addIceCandidate(signal);
    }
  }

  Future<void> _createPeerConnection({required bool isCaller}) async {
    if (_peerConnection != null) return;

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': state.isVideo
          ? {
              'facingMode': 'user',
              'width': 1280,
              'height': 720,
              'frameRate': 30,
            }
          : false,
    });
    _localRenderer.srcObject = _localStream;

    final connection = await createPeerConnection(_iceServers);
    for (final track in _localStream!.getTracks()) {
      await connection.addTrack(track, _localStream!);
    }

    connection.onAddStream = (stream) {
      _attachRemoteStream(stream);
    };

    connection.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _attachRemoteStream(event.streams.first);
      }
    };

    connection.onIceCandidate = (candidate) {
      final callId = state.callId;
      final selfId = state.selfId;
      final participantId = state.participant?.id;
      if (callId == null ||
          selfId == null ||
          participantId == null ||
          candidate.candidate == null) {
        return;
      }

      _socketService.signal({
        'callId': callId,
        'fromUserId': selfId,
        'toUserId': participantId,
        'data': {
          'type': 'candidate',
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      });
    };

    connection.onConnectionState = (connectionState) {
      if (connectionState ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        unawaited(_stopRingtone());
        state = state.copyWith(status: CallStatus.connected, clearError: true);
      } else if (connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        unawaited(_endLocally(status: CallStatus.ended));
      }
    };

    _peerConnection = connection;
    await _updateSpeakerRoute(enabled: state.isVideo);
    if (isCaller) {
      state = state.copyWith(status: CallStatus.outgoing, clearError: true);
    }
    state = state.copyWith(videoRevision: state.videoRevision + 1);
  }

  Future<bool> _requestPermissions({required bool isVideo}) async {
    final microphoneStatus = await Permission.microphone.request();
    if (!microphoneStatus.isGranted) return false;
    if (!isVideo) return true;
    final cameraStatus = await Permission.camera.request();
    return cameraStatus.isGranted;
  }

  Future<void> _endLocally({CallStatus status = CallStatus.ended}) async {
    final previousState = state;
    await _stopRingtone();
    await _disposeCallResources();
    state = CallState(
      status: status,
      callId: previousState.callId,
      selfId: previousState.selfId,
      participant: previousState.participant,
      isVideo: previousState.isVideo,
      isCameraEnabled: previousState.isCameraEnabled,
      videoRevision: previousState.videoRevision + 1,
      errorMessage: status == CallStatus.error
          ? previousState.errorMessage
          : null,
    );
  }

  Future<void> _disposeCallResources() async {
    _pendingOffer = null;
    _pendingCandidates.clear();
    await _updateSpeakerRoute(enabled: false);
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    final stream = _localStream;
    final remoteStream = _remoteStream;
    _localStream = null;
    _remoteStream = null;
    for (final track in stream?.getTracks() ?? const []) {
      track.stop();
    }
    for (final track in remoteStream?.getTracks() ?? const []) {
      track.stop();
    }
    await stream?.dispose();
    await remoteStream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;
  }

  Future<void> _playIncomingRingtone() async {
    await _playLoopingAsset(_incomingCallSound);
  }

  Future<void> _playOutgoingRingtone() async {
    await _playLoopingAsset(_outgoingCallSound);
  }

  Future<void> _playLoopingAsset(String assetPath) async {
    await _ringtonePlayer.stop();
    await _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
    await _ringtonePlayer.play(AssetSource(assetPath));
  }

  Future<void> _stopRingtone() async {
    await _ringtonePlayer.stop();
  }

  Future<void> _applyPendingOffer() async {
    final offer = _pendingOffer;
    final peerConnection = _peerConnection;
    if (offer == null || peerConnection == null) return;

    final sdp = offer['sdp']?.toString();
    if (sdp == null) return;

    await peerConnection.setRemoteDescription(
      RTCSessionDescription(sdp, 'offer'),
    );
    final answer = await peerConnection.createAnswer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': state.isVideo,
    });
    await peerConnection.setLocalDescription(answer);

    final selfId = state.selfId;
    final participantId = state.participant?.id;
    if (selfId != null && participantId != null) {
      _socketService.signal({
        'callId': state.callId,
        'fromUserId': selfId,
        'toUserId': participantId,
        'data': {'type': 'answer', 'sdp': answer.sdp},
      });
    }

    _pendingOffer = null;
  }

  Future<void> _flushPendingCandidates() async {
    if (_peerConnection == null || _pendingCandidates.isEmpty) return;
    final queued = List<Map<String, dynamic>>.from(_pendingCandidates);
    _pendingCandidates.clear();
    for (final candidate in queued) {
      await _addIceCandidate(candidate);
    }
  }

  Future<void> _addIceCandidate(Map<String, dynamic> signal) async {
    final candidate = signal['candidate']?.toString();
    final peerConnection = _peerConnection;
    if (candidate == null || peerConnection == null) return;
    await peerConnection.addCandidate(
      RTCIceCandidate(
        candidate,
        signal['sdpMid']?.toString(),
        signal['sdpMLineIndex'] as int?,
      ),
    );
  }

  void _attachRemoteStream(MediaStream stream) {
    _remoteStream = stream;
    _remoteRenderer.srcObject = stream;
    state = state.copyWith(videoRevision: state.videoRevision + 1);
  }

  Future<void> _updateSpeakerRoute({required bool enabled}) async {
    try {
      await Helper.setSpeakerphoneOn(enabled);
    } catch (_) {}
  }
}
