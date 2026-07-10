import 'package:clain_the_run/features/message/presentation/widgets/chatbubble.dart';
import 'package:flutter/material.dart';

enum GroupMessageMode { chat, voice }

class GroupMessageScreen extends StatefulWidget {
  const GroupMessageScreen({
    super.key,
    required this.groupName,
    required this.groupAvatarUrl,
    this.memberCount = 8,
  });

  final String groupName;
  final String groupAvatarUrl;
  final int memberCount;

  @override
  State<GroupMessageScreen> createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  GroupMessageMode _mode = GroupMessageMode.chat;

  final List<_GroupChatMessage> _messages = [
    const _GroupChatMessage(
      text: 'Morning team. Are we still doing the 6 AM group run?',
      timestamp: '6:42 AM',
      isMine: false,
    ),
    const _GroupChatMessage(
      text: 'Yes, meeting at the usual spot near the gate.',
      timestamp: '6:44 AM',
      isMine: true,
      isRead: true,
    ),
    const _GroupChatMessage(
      text: 'Perfect. I’ll bring the new route for everyone to try.',
      timestamp: '6:45 AM',
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
        _GroupChatMessage(text: text, timestamp: 'Now', isMine: true),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  ? ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: _messages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return ChatBubble(
                          text: message.text,
                          timestamp: message.timestamp,
                          isMine: message.isMine,
                          isRead: message.isRead,
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

class _GroupChatMessage {
  const _GroupChatMessage({
    required this.text,
    required this.timestamp,
    required this.isMine,
    this.isRead = false,
  });

  final String text;
  final String timestamp;
  final bool isMine;
  final bool isRead;
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

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isSelected
          ? (isDark ? const Color(0xFF16222E) : Colors.white)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? _brandGreen : const Color(0xFF8B8B8B),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? _brandGreen : const Color(0xFF8B8B8B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkieTalkiePanel extends StatelessWidget {
  const _WalkieTalkiePanel();

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 138,
            height: 138,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _brandGreen.withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _brandGreen,
              ),
              child: const Icon(
                Icons.mic_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Hold to talk',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Use walkie-talkie mode for quick live voice updates with your group.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: isDark ? const Color(0xFF9BA8B4) : const Color(0xFF7D7D7D),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111C26) : const Color(0xFFF7F8F5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF233241)
                    : const Color(0xFFE6E6E2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Last Voice Activity',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF8FA0AE)
                        : const Color(0xFF8A8A8A),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Ram Khadka spoke 2m ago',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupMessageInputBar extends StatelessWidget {
  const _GroupMessageInputBar({required this.controller, required this.onSend});

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
        color: isDark ? const Color(0xFF07111A) : Colors.white,
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
              color: isDark ? const Color(0xFF111C26) : const Color(0xFFF7F7F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 22,
              color: isDark ? const Color(0xFF8FA0AE) : const Color(0xFF6E6E6E),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 42, maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF111C26)
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
                  hintText: 'Message the group...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF8FA0AE)
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
                  size: 20,
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
