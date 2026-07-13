import 'dart:async';

import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/call/presentation/state/call_state.dart';
import 'package:clain_the_run/features/call/presentation/view_model/call_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallSessionScreen extends ConsumerStatefulWidget {
  const CallSessionScreen({super.key});

  @override
  ConsumerState<CallSessionScreen> createState() => _CallSessionScreenState();
}

class _CallSessionScreenState extends ConsumerState<CallSessionScreen> {
  Timer? _closeTimer;

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CallState>(callViewModelProvider, (previous, next) {
      if (next.status == CallStatus.ended) {
        _scheduleClose();
      } else {
        _closeTimer?.cancel();
      }
    });

    final state = ref.watch(callViewModelProvider);
    final notifier = ref.read(callViewModelProvider.notifier);
    final participant = state.participant;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111111);
    final secondaryTextColor = isDark
        ? const Color(0xFF9BA8B4)
        : const Color(0xFF6E6E6E);
    final avatarUrl = _resolvedAvatarUrl(participant?.avatarUrl);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF07111A)
          : const Color(0xFFF7F7F5),
      body: SafeArea(
        child: participant == null
            ? Center(
                child: Text(
                  _statusLabel(state.status),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              )
            : state.status == CallStatus.ended
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 58,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              participant.name.isNotEmpty
                                  ? participant.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(fontSize: 28),
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      participant.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Call ended',
                      style: TextStyle(fontSize: 16, color: secondaryTextColor),
                    ),
                  ],
                ),
              )
            : state.isVideo
            ? Stack(
                children: [
                  Positioned.fill(
                    child: _buildRemoteVideo(
                      participant: participant,
                      renderer: notifier.remoteRenderer,
                    ),
                  ),
                  Positioned(
                    top: 24,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                participant.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _statusLabel(state.status),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.errorMessage != null)
                    Positioned(
                      top: 92,
                      left: 20,
                      right: 20,
                      child: Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  Positioned(
                    top: 24,
                    right: 20,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 116,
                        height: 164,
                        child: _buildLocalVideo(
                          participant: participant,
                          renderer: notifier.localRenderer,
                          cameraEnabled: state.isCameraEnabled,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 34,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CallActionButton(
                          icon: state.isMuted ? Icons.mic_off : Icons.mic,
                          backgroundColor: const Color(0xCCFFFFFF),
                          iconColor: const Color(0xFF111111),
                          onTap: state.status == CallStatus.connected
                              ? notifier.toggleMute
                              : null,
                        ),
                        const SizedBox(width: 18),
                        _CallActionButton(
                          icon: state.isCameraEnabled
                              ? Icons.videocam
                              : Icons.videocam_off,
                          backgroundColor: const Color(0xCCFFFFFF),
                          iconColor: const Color(0xFF111111),
                          onTap:
                              state.status == CallStatus.connected ||
                                  state.status == CallStatus.connecting
                              ? notifier.toggleCamera
                              : null,
                        ),
                        const SizedBox(width: 18),
                        if (state.status == CallStatus.incoming) ...[
                          _CallActionButton(
                            icon: Icons.call_end,
                            backgroundColor: const Color(0xFFFFE3E3),
                            iconColor: const Color(0xFFD64545),
                            onTap: notifier.declineIncomingCall,
                          ),
                          const SizedBox(width: 18),
                          _CallActionButton(
                            icon: Icons.call,
                            backgroundColor: const Color(0xFFEAF5DF),
                            iconColor: const Color(0xFF72B63E),
                            onTap: notifier.acceptIncomingCall,
                          ),
                        ] else
                          _CallActionButton(
                            icon: Icons.call_end,
                            backgroundColor: const Color(0xFFFFE3E3),
                            iconColor: const Color(0xFFD64545),
                            onTap: notifier.endCurrentCall,
                          ),
                      ],
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
                child: Column(
                  children: [
                    const Spacer(),
                    CircleAvatar(
                      radius: 58,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              participant.name.isNotEmpty
                                  ? participant.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(fontSize: 28),
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      participant.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _statusLabel(state.status),
                      style: TextStyle(fontSize: 16, color: secondaryTextColor),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CallActionButton(
                          icon: state.isMuted ? Icons.mic_off : Icons.mic,
                          backgroundColor: const Color(0xFFEAF5DF),
                          iconColor: const Color(0xFF72B63E),
                          onTap: state.status == CallStatus.connected
                              ? notifier.toggleMute
                              : null,
                        ),
                        const SizedBox(width: 18),
                        if (state.status == CallStatus.incoming) ...[
                          _CallActionButton(
                            icon: Icons.call_end,
                            backgroundColor: const Color(0xFFFFE3E3),
                            iconColor: const Color(0xFFD64545),
                            onTap: notifier.declineIncomingCall,
                          ),
                          const SizedBox(width: 18),
                          _CallActionButton(
                            icon: Icons.call,
                            backgroundColor: const Color(0xFFEAF5DF),
                            iconColor: const Color(0xFF72B63E),
                            onTap: notifier.acceptIncomingCall,
                          ),
                        ] else
                          _CallActionButton(
                            icon: Icons.call_end,
                            backgroundColor: const Color(0xFFFFE3E3),
                            iconColor: const Color(0xFFD64545),
                            onTap: notifier.endCurrentCall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _scheduleClose() {
    if (_closeTimer?.isActive == true) return;
    _closeTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).maybePop();
    });
  }

  String _statusLabel(CallStatus status) {
    switch (status) {
      case CallStatus.incoming:
        return 'Incoming ${ref.read(callViewModelProvider).isVideo ? 'video' : 'voice'} call...';
      case CallStatus.outgoing:
        return 'Calling...';
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.connected:
        return '${ref.read(callViewModelProvider).isVideo ? 'Video' : 'Voice'} call in progress';
      case CallStatus.declined:
        return 'Call declined';
      case CallStatus.ended:
        return 'Call ended';
      case CallStatus.error:
        return 'Call unavailable';
      case CallStatus.idle:
        return 'Ready';
    }
  }

  Widget _buildRemoteVideo({
    required CallParticipant participant,
    required RTCVideoRenderer renderer,
  }) {
    final avatarUrl = _resolvedAvatarUrl(participant.avatarUrl);
    if (renderer.srcObject != null) {
      return RTCVideoView(
        key: ValueKey(
          'remote-${ref.watch(callViewModelProvider).videoRevision}',
        ),
        renderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: false,
      );
    }

    return Container(
      color: const Color(0xFF101820),
      child: Center(
        child: CircleAvatar(
          radius: 58,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  participant.name.isNotEmpty
                      ? participant.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 28),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLocalVideo({
    required CallParticipant participant,
    required RTCVideoRenderer renderer,
    required bool cameraEnabled,
  }) {
    if (renderer.srcObject != null && cameraEnabled) {
      return RTCVideoView(
        key: ValueKey(
          'local-${ref.watch(callViewModelProvider).videoRevision}',
        ),
        renderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: true,
      );
    }

    return Container(
      color: const Color(0xFF1F2937),
      child: const Center(
        child: Icon(Icons.videocam_off, color: Colors.white, size: 30),
      ),
    );
  }

  String? _resolvedAvatarUrl(String? rawAvatarUrl) {
    if (rawAvatarUrl == null || rawAvatarUrl.trim().isEmpty) {
      return null;
    }
    return ApiEndpoints.profileImageUrl(rawAvatarUrl.trim());
  }
}

class _CallActionButton extends StatelessWidget {
  const _CallActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Icon(icon, size: 28, color: iconColor),
        ),
      ),
    );
  }
}
