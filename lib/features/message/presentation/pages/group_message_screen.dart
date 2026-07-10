import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:clain_the_run/features/message/presentation/state/group_message_state.dart';
import 'package:clain_the_run/features/message/presentation/view_model/group_message_view_model.dart';
import 'package:clain_the_run/features/message/presentation/widgets/chatbubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  GroupMessageMode _mode = GroupMessageMode.chat;

  @override
  void initState() {
    super.initState();
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
        child: Column(
          children: [
            _GroupMessageHeader(
              groupName: widget.groupName,
              groupAvatarUrl: widget.groupAvatarUrl,
              memberCount: widget.memberCount,
              selectedMode: _mode,
              onBack: () => Navigator.of(context).pop(),
              onModeChanged: (mode) {
                setState(() {
                  _mode = mode;
                });
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

                        if (state.errorMessage != null && messages.isEmpty) {
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
                              .loadMessages(widget.communityId, force: true),
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                  : const _WalkieTalkiePanel(),
            ),
            if (_mode == GroupMessageMode.chat)
              _GroupMessageInputBar(
                controller: _controller,
                onSend: _sendMessage,
              ),
          ],
        ),
      ),
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
    required this.onModeChanged,
  });

  final String groupName;
  final String groupAvatarUrl;
  final int memberCount;
  final GroupMessageMode selectedMode;
  final VoidCallback onBack;
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
  const _WalkieTalkiePanel();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic_rounded,
              size: 54,
              color: isDark ? Colors.white : const Color(0xFF3B6D11),
            ),
            const SizedBox(height: 16),
            Text(
              'Walkie talkie is next.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Group text messaging is now live. We can wire voice push-to-talk next.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF9BA8B4)
                    : const Color(0xFF6E6E6E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
