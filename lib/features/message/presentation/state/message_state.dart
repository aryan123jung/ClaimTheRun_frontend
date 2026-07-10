import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';

enum MessageStatus { initial, loading, loaded, sending, error }

class MessageState {
  const MessageState({
    required this.status,
    required this.conversations,
    required this.messagesByConversation,
    this.activeConversation,
    this.errorMessage,
  });

  const MessageState.initial()
    : status = MessageStatus.initial,
      conversations = const [],
      messagesByConversation = const {},
      activeConversation = null,
      errorMessage = null;

  final MessageStatus status;
  final List<MessageConversationEntity> conversations;
  final Map<String, List<MessageEntity>> messagesByConversation;
  final MessageConversationEntity? activeConversation;
  final String? errorMessage;

  List<MessageEntity> messagesFor(String conversationId) =>
      messagesByConversation[conversationId] ?? const [];

  MessageState copyWith({
    MessageStatus? status,
    List<MessageConversationEntity>? conversations,
    Map<String, List<MessageEntity>>? messagesByConversation,
    MessageConversationEntity? activeConversation,
    String? errorMessage,
    bool clearError = false,
    bool clearActiveConversation = false,
  }) {
    return MessageState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      messagesByConversation:
          messagesByConversation ?? this.messagesByConversation,
      activeConversation: clearActiveConversation
          ? null
          : activeConversation ?? this.activeConversation,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
