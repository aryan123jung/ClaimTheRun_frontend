class CallParticipant {
  const CallParticipant({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String avatarUrl;
}

enum CallStatus {
  idle,
  incoming,
  outgoing,
  connecting,
  connected,
  ended,
  declined,
  error,
}

class CallState {
  const CallState({
    this.status = CallStatus.idle,
    this.callId,
    this.selfId,
    this.participant,
    this.isVideo = false,
    this.isMuted = false,
    this.isCameraEnabled = true,
    this.videoRevision = 0,
    this.errorMessage,
  });

  final CallStatus status;
  final String? callId;
  final String? selfId;
  final CallParticipant? participant;
  final bool isVideo;
  final bool isMuted;
  final bool isCameraEnabled;
  final int videoRevision;
  final String? errorMessage;

  bool get hasActiveCall =>
      status == CallStatus.incoming ||
      status == CallStatus.outgoing ||
      status == CallStatus.connecting ||
      status == CallStatus.connected;

  CallState copyWith({
    CallStatus? status,
    String? callId,
    String? selfId,
    CallParticipant? participant,
    bool? isVideo,
    bool? isMuted,
    bool? isCameraEnabled,
    int? videoRevision,
    String? errorMessage,
    bool clearCallId = false,
    bool clearParticipant = false,
    bool clearError = false,
  }) {
    return CallState(
      status: status ?? this.status,
      callId: clearCallId ? null : (callId ?? this.callId),
      selfId: selfId ?? this.selfId,
      participant: clearParticipant ? null : (participant ?? this.participant),
      isVideo: isVideo ?? this.isVideo,
      isMuted: isMuted ?? this.isMuted,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
      videoRevision: videoRevision ?? this.videoRevision,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
