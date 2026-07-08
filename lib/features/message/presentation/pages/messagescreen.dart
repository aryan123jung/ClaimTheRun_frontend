import 'package:clain_the_run/features/message/presentation/pages/chatscreen.dart';
import 'package:clain_the_run/features/message/presentation/widgets/messagecard.dart';
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  // Placeholder data — replace with real conversation data from your
  // backend/provider.
  static const _conversations = [
    ConversationModel(
      id: '1',
      name: 'Ram Khadka',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      lastMessage: 'Nice run today! Let\'s go again tomorrow morning',
      timestamp: '2m',
      unreadCount: 2,
      isOnline: true,
    ),
    ConversationModel(
      id: '2',
      name: 'Riya Kapoor',
      avatarUrl: 'https://i.pravatar.cc/150?img=25',
      lastMessage: 'Sent you the route for the lake trail',
      timestamp: '18m',
      unreadCount: 1,
      isOnline: true,
    ),
    ConversationModel(
      id: '3',
      name: 'Aarav Sharma',
      avatarUrl: 'https://i.pravatar.cc/150?img=13',
      lastMessage: 'You: See you at 6 AM at the park entrance',
      timestamp: '1h',
      isLastMessageMine: true,
    ),
    ConversationModel(
      id: '4',
      name: 'The Runners',
      avatarUrl: 'https://i.pravatar.cc/150?img=41',
      lastMessage: 'Kiran: Who\'s in for the weekend long run?',
      timestamp: '3h',
      unreadCount: 5,
    ),
    ConversationModel(
      id: '5',
      name: 'Anjali Rai',
      avatarUrl: 'https://i.pravatar.cc/150?img=27',
      lastMessage: 'You: Congrats on the new personal best!',
      timestamp: 'Yesterday',
      isLastMessageMine: true,
    ),
    ConversationModel(
      id: '6',
      name: 'Kiran Gurung',
      avatarUrl: 'https://i.pravatar.cc/150?img=14',
      lastMessage: 'Thanks for the tips on pacing',
      timestamp: 'Yesterday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Text(
                'Stay in touch with your running crew',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF9BA8B4)
                      : const Color(0xFF6E6E6E),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchField(),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: _conversations.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  return MessageCard(
                    conversation: conversation,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            name: conversation.name,
                            avatarUrl: conversation.avatarUrl,
                            isOnline: conversation.isOnline,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFD8D8D5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search messages...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF9BA8B4)
                      : const Color(0xFF9A9A9A),
                ),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ),
          ),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? const Color(0xFF9BA8B4) : const Color(0xFF9A9A9A),
          ),
        ],
      ),
    );
  }
}
