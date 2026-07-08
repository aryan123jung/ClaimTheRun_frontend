import 'package:clain_the_run/features/message/presentation/widgets/chatbubble.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.isOnline = false,
  });

  final String name;
  final String avatarUrl;
  final bool isOnline;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // static const _brandGreen = Color(0xFF72B63E);

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Placeholder data — replace with real messages from your
  // backend/provider, keyed by conversation id.
  final List<ChatMessageModel> _messages = [
    const ChatMessageModel(
      text: 'Hey! Are we still on for the run tomorrow?',
      timestamp: '7:02 AM',
      isMine: false,
    ),
    const ChatMessageModel(
      text: 'Yes definitely, same route as last time?',
      timestamp: '7:04 AM',
      isMine: true,
      isRead: true,
    ),
    const ChatMessageModel(
      text:
          "Let's try the lake trail instead, heard it's nice this time of year",
      timestamp: '7:05 AM',
      isMine: false,
    ),
    const ChatMessageModel(
      text: 'Sounds good, what time?',
      timestamp: '7:06 AM',
      isMine: true,
      isRead: true,
    ),
    const ChatMessageModel(
      text: 'Nice run today! Let\'s go again tomorrow morning',
      timestamp: '7:15 AM',
      isMine: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessageModel(text: text, timestamp: 'Now', isMine: true),
      );
      _controller.clear();
    });

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

  void _startCall({required bool isVideo}) {
    // Wire this up to your actual calling integration (e.g. Agora,
    // Twilio, or a native platform channel).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting ${isVideo ? 'video' : 'voice'} call with ${widget.name}...',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(
              name: widget.name,
              avatarUrl: widget.avatarUrl,
              isOnline: widget.isOnline,
              onBack: () => Navigator.of(context).pop(),
              onVoiceCall: () => _startCall(isVideo: false),
              onVideoCall: () => _startCall(isVideo: true),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount: _messages.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return ChatBubble(message: _messages[index]);
                },
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
    required this.isOnline,
    required this.onBack,
    required this.onVoiceCall,
    required this.onVideoCall,
  });

  final String name;
  final String avatarUrl;
  final bool isOnline;
  final VoidCallback onBack;
  final VoidCallback onVoiceCall;
  final VoidCallback onVideoCall;

  static const _brandGreen = Color(0xFF72B63E);

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
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              if (isOnline)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: _brandGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF111C26) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),
                Text(
                  isOnline ? 'Active now' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? _brandGreen : const Color(0xFF9A9A9A),
                  ),
                ),
              ],
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
  final VoidCallback onSend;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        10,
        14,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF233241) : const Color(0xFFEDEDEA),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2732) : const Color(0xFFF7F7F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 22,
              color: isDark ? const Color(0xFF9BA8B4) : const Color(0xFF6E6E6E),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 42, maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1B2732)
                    : const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(21),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Message...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF9BA8B4)
                        : const Color(0xFF9A9A9A),
                  ),
                  isCollapsed: true,
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF111111),
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
                padding: EdgeInsets.all(11),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
