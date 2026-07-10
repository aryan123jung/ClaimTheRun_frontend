import 'package:clain_the_run/features/call/presentation/state/call_state.dart';
import 'package:clain_the_run/features/call/presentation/view_model/call_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallSessionScreen extends ConsumerWidget {
  const CallSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callViewModelProvider);
    final notifier = ref.read(callViewModelProvider.notifier);
    final participant = state.participant;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF07111A)
          : const Color(0xFFF7F7F5),
      body: SafeArea(
        child: participant == null
            ? const Center(child: Text('No active call'))
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
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _statusLabel(state.status),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? const Color(0xFF9BA8B4)
                            : const Color(0xFF6E6E6E),
                      ),
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
                            onTap: () async {
                              await notifier.declineIncomingCall();
                              if (context.mounted) Navigator.of(context).pop();
                            },
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
                            onTap: () async {
                              await notifier.endCurrentCall();
                              if (context.mounted) Navigator.of(context).pop();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
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
