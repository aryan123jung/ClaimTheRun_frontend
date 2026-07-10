import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';
import 'package:clain_the_run/features/message/data/services/message_socket_service.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:clain_the_run/features/message/domain/usecases/message_usecases.dart';
import 'package:clain_the_run/features/message/presentation/state/message_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageViewModelProvider =
    NotifierProvider<MessageViewModel, MessageState>(MessageViewModel.new);

class MessageViewModel extends Notifier<MessageState> {
  late final GetConversationsUsecase _getConversationsUsecase;
  late final GetOrCreateConversationUsecase _getOrCreateConversationUsecase;
  late final GetMessagesUsecase _getMessagesUsecase;
  late final SendMessageUsecase _sendMessageUsecase;
  late final MarkConversationReadUsecase _markConversationReadUsecase;
  late final MessageSocketService _messageSocketService;

  @override
  MessageState build() {
    _getConversationsUsecase = ref.read(getConversationsUsecaseProvider);
    _getOrCreateConversationUsecase = ref.read(
      getOrCreateConversationUsecaseProvider,
    );
    _getMessagesUsecase = ref.read(getMessagesUsecaseProvider);
    _sendMessageUsecase = ref.read(sendMessageUsecaseProvider);
    _markConversationReadUsecase = ref.read(
      markConversationReadUsecaseProvider,
    );
    _messageSocketService = ref.read(messageSocketServiceProvider);
    _messageSocketService.setOnMessage(_handleIncomingMessage);
    Future<void>.microtask(_messageSocketService.connect);
    ref.onDispose(() {
      _messageSocketService.setOnMessage(null);
    });
    return const MessageState.initial();
  }

  Future<void> loadConversations({bool force = false}) async {
    if (!force &&
        state.conversations.isNotEmpty &&
        state.status == MessageStatus.loaded) {
      return;
    }

    state = state.copyWith(
      status: state.conversations.isEmpty
          ? MessageStatus.loading
          : state.status,
      clearError: true,
    );

    final result = await _getConversationsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: MessageStatus.error,
        errorMessage: failure.message,
      ),
      (items) => state = state.copyWith(
        status: MessageStatus.loaded,
        conversations: items,
        clearError: true,
      ),
    );
  }

  Future<MessageConversationEntity?> openConversationWithFriend(
    FriendUserEntity friend,
  ) async {
    state = state.copyWith(status: MessageStatus.loading, clearError: true);
    final result = await _getOrCreateConversationUsecase(
      UserIdParams(userId: friend.id),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: MessageStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (conversation) {
        _messageSocketService.joinConversation(conversation.id);
        state = state.copyWith(
          status: MessageStatus.loaded,
          activeConversation: conversation,
          conversations: _upsertConversation(conversation),
          clearError: true,
        );
        return conversation;
      },
    );
  }

  Future<void> loadMessages(String conversationId, {bool force = false}) async {
    if (!force &&
        state.messagesByConversation.containsKey(conversationId) &&
        state.messagesFor(conversationId).isNotEmpty) {
      await markConversationRead(conversationId);
      return;
    }

    state = state.copyWith(status: MessageStatus.loading, clearError: true);
    final result = await _getMessagesUsecase(
      ConversationIdParams(conversationId: conversationId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: MessageStatus.error,
        errorMessage: failure.message,
      ),
      (messages) {
        state = state.copyWith(
          status: MessageStatus.loaded,
          messagesByConversation: {
            ...state.messagesByConversation,
            conversationId: messages,
          },
          clearError: true,
        );
      },
    );

    if (state.status == MessageStatus.loaded) {
      await markConversationRead(conversationId);
    }
  }

  Future<String?> sendMessage(String conversationId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'Message cannot be empty.';

    state = state.copyWith(status: MessageStatus.sending, clearError: true);
    final result = await _sendMessageUsecase(
      SendMessageParams(conversationId: conversationId, text: trimmed),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: MessageStatus.error,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (message) {
        final updatedMessages = _appendUniqueMessage(
          state.messagesFor(conversationId),
          message,
        );
        state = state.copyWith(
          status: MessageStatus.loaded,
          messagesByConversation: {
            ...state.messagesByConversation,
            conversationId: updatedMessages,
          },
          conversations: _bumpConversationWithMessage(message),
          clearError: true,
        );
        return null;
      },
    );
  }

  void leaveConversation(String conversationId) {
    _messageSocketService.leaveConversation(conversationId);
  }

  Future<void> markConversationRead(String conversationId) async {
    final result = await _markConversationReadUsecase(
      ConversationIdParams(conversationId: conversationId),
    );

    result.fold((_) {}, (_) {
      state = state.copyWith(
        conversations: [
          for (final conversation in state.conversations)
            if (conversation.id == conversationId)
              MessageConversationEntity(
                id: conversation.id,
                otherUser: conversation.otherUser,
                updatedAt: conversation.updatedAt,
                lastMessageText: conversation.lastMessageText,
                lastMessageSenderId: conversation.lastMessageSenderId,
                lastMessageCreatedAt: conversation.lastMessageCreatedAt,
                unreadCount: 0,
              )
            else
              conversation,
        ],
      );
    });
  }

  List<MessageConversationEntity> _upsertConversation(
    MessageConversationEntity conversation,
  ) {
    final items = [
      conversation,
      ...state.conversations.where((item) => item.id != conversation.id),
    ];
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  List<MessageConversationEntity> _bumpConversationWithMessage(
    MessageEntity message,
  ) {
    final existing = state.conversations.where(
      (item) => item.id == message.conversationId,
    );
    if (existing.isEmpty) return state.conversations;

    final current = existing.first;
    final updated = MessageConversationEntity(
      id: current.id,
      otherUser: current.otherUser,
      updatedAt: message.createdAt,
      lastMessageText: message.text,
      lastMessageSenderId: message.senderId,
      lastMessageCreatedAt: message.createdAt,
      unreadCount: 0,
    );

    return _upsertConversation(updated);
  }

  List<MessageEntity> _appendUniqueMessage(
    List<MessageEntity> items,
    MessageEntity message,
  ) {
    final exists = items.any((item) => item.id == message.id);
    if (exists) {
      return [
        for (final item in items)
          if (item.id == message.id) message else item,
      ];
    }
    return [...items, message];
  }

  void _handleIncomingMessage(MessageEntity message) {
    final conversationMessages = _appendUniqueMessage(
      state.messagesFor(message.conversationId),
      message,
    );

    final existing = state.conversations.where(
      (item) => item.id == message.conversationId,
    );
    final current = existing.isNotEmpty ? existing.first : null;
    if (current == null) {
      loadConversations(force: true);
      return;
    }

    final isActiveConversation =
        state.activeConversation?.id == message.conversationId;
    final updatedConversation = MessageConversationEntity(
      id: current.id,
      otherUser: current.otherUser,
      updatedAt: message.createdAt,
      lastMessageText: message.text,
      lastMessageSenderId: message.senderId,
      lastMessageCreatedAt: message.createdAt,
      unreadCount: isActiveConversation || message.isMine
          ? 0
          : current.unreadCount + 1,
    );

    state = state.copyWith(
      status: MessageStatus.loaded,
      messagesByConversation: {
        ...state.messagesByConversation,
        message.conversationId: conversationMessages,
      },
      conversations: _upsertConversation(updatedConversation),
      activeConversation: isActiveConversation ? updatedConversation : null,
      clearError: true,
    );

    if (isActiveConversation && !message.isMine) {
      markConversationRead(message.conversationId);
    }
  }
}
