import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';
import 'package:clain_the_run/features/call/presentation/pages/call_session_screen.dart';
import 'package:clain_the_run/features/call/presentation/view_model/call_view_model.dart';
import 'package:clain_the_run/features/message/presentation/state/message_state.dart';
import 'package:clain_the_run/features/message/presentation/view_model/message_view_model.dart';
import 'package:clain_the_run/features/message/presentation/widgets/chatbubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.friendUsername,
    required this.avatarUrl,
    this.initialConversationId,
  });

  final String friendId;
  final String friendName;
  final String friendUsername;
  final String avatarUrl;
  final String? initialConversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final MessageViewModel _messageNotifier;
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _messageNotifier = ref.read(messageViewModelProvider.notifier);
    Future.microtask(_bootstrapConversation);
  }

  @override
  void dispose() {
    final conversationId = _conversationId;
    if (conversationId != null) {
      _messageNotifier.leaveConversation(conversationId);
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapConversation() async {
    final notifier = _messageNotifier;
    final conversationId = widget.initialConversationId;

    if (conversationId != null && conversationId.isNotEmpty) {
      setState(() {
        _conversationId = conversationId;
      });
      await notifier.ensureConversationJoined(conversationId);
      await notifier.loadMessages(conversationId);
      _jumpToBottom();
      return;
    }

    final conversation = await notifier.openConversationWithFriend(
      FriendUserEntity(
        id: widget.friendId,
        fullname: widget.friendName,
        username: widget.friendUsername,
        profileUrl: widget.avatarUrl,
        mutualFriends: 0,
        friendStatus: 'FRIEND',
      ),
    );
    if (!mounted || conversation == null) return;

    setState(() {
      _conversationId = conversation.id;
    });

    await notifier.loadMessages(conversation.id);
    _jumpToBottom();
  }

  Future<void> _sendMessage() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    _controller.clear();

    final error = await ref
        .read(messageViewModelProvider.notifier)
        .sendMessage(conversationId, text);

    if (!mounted) return;

    if (error != null) {
      _controller.text = text;
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    _jumpToBottom(animated: true);
  }

  void _jumpToBottom({bool animated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _startCall({required bool isVideo}) async {
    if (isVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video calling will be added next.')),
      );
      return;
    }

    final notifier = ref.read(callViewModelProvider.notifier);
    final started = await notifier.startAudioCall(
      friendId: widget.friendId,
      friendName: widget.friendName,
      avatarUrl: widget.avatarUrl,
    );

    if (!mounted) return;

    if (!started) {
      final message =
          ref.read(callViewModelProvider).errorMessage ??
          'Could not start the audio call.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CallSessionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(messageViewModelProvider);
    final conversationId = _conversationId;
    final messages = conversationId == null
        ? const []
        : state.messagesFor(conversationId);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(
              name: widget.friendName,
              avatarUrl: widget.avatarUrl,
              onBack: () => Navigator.of(context).pop(),
              onVoiceCall: () => _startCall(isVideo: false),
              onVideoCall: () => _startCall(isVideo: true),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final id = _conversationId;
                  if (id != null) {
                    await ref
                        .read(messageViewModelProvider.notifier)
                        .loadMessages(id, force: true);
                  }
                },
                child: Builder(
                  builder: (context) {
                    if (conversationId == null &&
                        state.status == MessageStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage != null && messages.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 80,
                            ),
                            child: Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }

                    if (messages.isEmpty) {
                      return ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'Say hello and start the conversation.',
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: messages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ChatBubble(
                          text: message.text,
                          timestamp: DateFormat(
                            'h:mm a',
                          ).format(message.createdAt),
                          isMine: message.isMine,
                          isRead: message.isReadByOtherUser,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            _MessageInputBar(controller: _controller, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.name,
    required this.avatarUrl,
    required this.onBack,
    required this.onVoiceCall,
    required this.onVideoCall,
  });

  final String name;
  final String avatarUrl;
  final VoidCallback onBack;
  final VoidCallback onVoiceCall;
  final VoidCallback onVideoCall;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF233241) : const Color(0xFFEDEDEA),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          CircleAvatar(radius: 19, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ),
          ),
          _HeaderIconButton(icon: Icons.call_rounded, onTap: onVoiceCall),
          const SizedBox(width: 6),
          _HeaderIconButton(icon: Icons.videocam_rounded, onTap: onVideoCall),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? const Color(0xFF1B2732)
          : _brandGreen.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 18, color: _brandGreen),
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final Future<void> Function() onSend;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C1721) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF233241) : const Color(0xFFEDEDEA),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF111C26)
                      : const Color(0xFFF5F5F2),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: _brandGreen,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onSend,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
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
