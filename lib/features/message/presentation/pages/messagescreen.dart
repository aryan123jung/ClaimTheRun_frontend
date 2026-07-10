import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:clain_the_run/features/message/presentation/pages/chatscreen.dart';
import 'package:clain_the_run/features/message/presentation/state/message_state.dart';
import 'package:clain_the_run/features/message/presentation/view_model/message_view_model.dart';
import 'package:clain_the_run/features/message/presentation/widgets/messagecard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(messageViewModelProvider.notifier).loadConversations(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(messageViewModelProvider);
    final currentUserId = ref.watch(
      authViewModelProvider.select((state) => state.authEntity?.id),
    );
    final conversations = state.conversations.where((conversation) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) return true;
      final name = conversation.otherUser.fullname.toLowerCase();
      final username = conversation.otherUser.username.toLowerCase();
      return name.contains(query) || username.contains(query);
    }).toList();

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
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Text(
                'Message your friends and keep the pace going.',
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
              child: _SearchField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(messageViewModelProvider.notifier)
                      .loadConversations(force: true);
                },
                child: Builder(
                  builder: (context) {
                    if (state.status == MessageStatus.loading &&
                        state.conversations.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage != null &&
                        state.conversations.isEmpty) {
                      return _InfoPanel(
                        message: state.errorMessage!,
                        actionLabel: 'Retry',
                        onTap: () {
                          ref
                              .read(messageViewModelProvider.notifier)
                              .loadConversations(force: true);
                        },
                      );
                    }

                    if (conversations.isEmpty) {
                      return _InfoPanel(
                        message: _query.trim().isEmpty
                            ? 'No conversations yet. Open a friend profile and start chatting.'
                            : 'No conversations match your search.',
                      );
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: conversations.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final avatarUrl =
                            (conversation.otherUser.profileUrl != null &&
                                conversation.otherUser.profileUrl!.isNotEmpty)
                            ? ApiEndpoints.profileImageUrl(
                                conversation.otherUser.profileUrl!,
                              )
                            : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(conversation.otherUser.fullname)}&background=E6F3DC&color=3B6D11';

                        return MessageCard(
                          name: conversation.otherUser.fullname,
                          avatarUrl: avatarUrl,
                          lastMessage:
                              conversation.lastMessageText ?? 'Start chatting',
                          timestamp: _formatConversationTime(conversation),
                          unreadCount: conversation.unreadCount,
                          isLastMessageMine:
                              conversation.lastMessageSenderId == currentUserId,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  initialConversationId: conversation.id,
                                  friendId: conversation.otherUser.id,
                                  friendName: conversation.otherUser.fullname,
                                  friendUsername:
                                      conversation.otherUser.username,
                                  avatarUrl: avatarUrl,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatConversationTime(MessageConversationEntity conversation) {
    final value = conversation.lastMessageCreatedAt ?? conversation.updatedAt;
    final now = DateTime.now();
    if (now.year == value.year &&
        now.month == value.month &&
        now.day == value.day) {
      return DateFormat('h:mm a').format(value);
    }
    if (now.difference(value).inDays < 7) {
      return DateFormat('EEE').format(value);
    }
    return DateFormat('d MMM').format(value);
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

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
              controller: controller,
              onChanged: onChanged,
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

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.message, this.actionLabel, this.onTap});

  final String message;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
          child: Column(
            children: [
              Text(message, textAlign: TextAlign.center),
              if (actionLabel != null && onTap != null) ...[
                const SizedBox(height: 14),
                OutlinedButton(onPressed: onTap, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
