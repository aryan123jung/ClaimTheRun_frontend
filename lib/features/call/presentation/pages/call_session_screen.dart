import 'dart:async';

import 'package:clain_the_run/features/call/presentation/state/call_state.dart';
import 'package:clain_the_run/features/call/presentation/view_model/call_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                      backgroundImage: participant.avatarUrl.isNotEmpty
                          ? NetworkImage(participant.avatarUrl)
                          : null,
                      child: participant.avatarUrl.isEmpty
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
            : Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
                child: Column(
                  children: [
                    const Spacer(),
                    CircleAvatar(
                      radius: 58,
                      backgroundImage: participant.avatarUrl.isNotEmpty
                          ? NetworkImage(participant.avatarUrl)
                          : null,
                      child: participant.avatarUrl.isEmpty
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
        return 'Incoming voice call...';
      case CallStatus.outgoing:
        return 'Calling...';
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.connected:
        return 'Voice call in progress';
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
