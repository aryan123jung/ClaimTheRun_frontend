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
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _listenersBound = false;

  @override
  CallState build() {
    _socketService = ref.read(callSocketServiceProvider);
    _bindSocketListeners();
    Future<void>.microtask(_socketService.connect);
    ref.onDispose(() async {
      await _stopRingtone();
      await _disposeCallResources();
      await _ringtonePlayer.dispose();
    });
    return const CallState();
  }

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

      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) {
        state = state.copyWith(
          status: CallStatus.error,
          errorMessage: 'Microphone permission is required for audio calls.',
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
        isVideo: false,
      );
      await _playOutgoingRingtone();

      await _createPeerConnection(isCaller: true);
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      await _peerConnection!.setLocalDescription(offer);

      _socketService.invite({
        'callId': callId,
        'callerId': selfId,
        'callerName': callerName,
        'callerAvatarUrl': callerAvatarUrl,
        'receiverId': friendId,
        'isVideo': false,
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
        errorMessage: 'Could not start the audio call. ${error.toString()}',
      );
      return false;
    }
  }

  Future<void> acceptIncomingCall() async {
    final participant = state.participant;
    final callId = state.callId;
    final selfId = state.selfId;
    if (participant == null || callId == null || selfId == null) return;

    final hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) {
      state = state.copyWith(
        status: CallStatus.error,
        errorMessage: 'Microphone permission is required for audio calls.',
      );
      return;
    }

    await _createPeerConnection(isCaller: false);
    state = state.copyWith(status: CallStatus.connecting, clearError: true);
    await _stopRingtone();

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
      await _createPeerConnection(isCaller: false);
      final sdp = signal['sdp']?.toString();
      if (sdp == null) return;
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp, 'offer'),
      );
      final answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      await _peerConnection!.setLocalDescription(answer);

      final selfId = state.selfId;
      final participantId = state.participant?.id;
      if (selfId == null || participantId == null) return;
      _socketService.signal({
        'callId': callId,
        'fromUserId': selfId,
        'toUserId': participantId,
        'data': {'type': 'answer', 'sdp': answer.sdp},
      });
      await _stopRingtone();
      state = state.copyWith(status: CallStatus.connecting, clearError: true);
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
      final candidate = signal['candidate']?.toString();
      if (candidate == null || _peerConnection == null) return;
      await _peerConnection!.addCandidate(
        RTCIceCandidate(
          candidate,
          signal['sdpMid']?.toString(),
          signal['sdpMLineIndex'] as int?,
        ),
      );
    }
  }

  Future<void> _createPeerConnection({required bool isCaller}) async {
    if (_peerConnection != null) return;

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    final connection = await createPeerConnection(_iceServers);
    for (final track in _localStream!.getTracks()) {
      await connection.addTrack(track, _localStream!);
    }

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
    if (isCaller) {
      state = state.copyWith(status: CallStatus.outgoing, clearError: true);
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _endLocally({CallStatus status = CallStatus.ended}) async {
    await _stopRingtone();
    await _disposeCallResources();
    state = CallState(
      status: status,
      selfId: state.selfId,
      errorMessage: status == CallStatus.error ? state.errorMessage : null,
    );
  }

  Future<void> _disposeCallResources() async {
    final stream = _localStream;
    _localStream = null;
    for (final track in stream?.getTracks() ?? const []) {
      track.stop();
    }
    await stream?.dispose();
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
}
