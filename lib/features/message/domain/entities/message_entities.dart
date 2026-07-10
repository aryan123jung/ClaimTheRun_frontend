import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';
import 'package:equatable/equatable.dart';

class MessageConversationEntity extends Equatable {
  const MessageConversationEntity({
    required this.id,
    required this.otherUser,
    required this.updatedAt,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageCreatedAt,
    this.unreadCount = 0,
  });

  final String id;
  final FriendUserEntity otherUser;
  final DateTime updatedAt;
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final DateTime? lastMessageCreatedAt;
  final int unreadCount;

  @override
  List<Object?> get props => [
    id,
    otherUser,
    updatedAt,
    lastMessageText,
    lastMessageSenderId,
    lastMessageCreatedAt,
    unreadCount,
  ];
}

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.isMine,
    required this.isReadByOtherUser,
  });

  final String id;
  final String conversationId;
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final bool isMine;
  final bool isReadByOtherUser;

  @override
  List<Object?> get props => [
    id,
    conversationId,
    text,
    senderId,
    receiverId,
    createdAt,
    isMine,
    isReadByOtherUser,
  ];
}
