import 'package:clain_the_run/features/addfriend/data/models/friend_user_api_model.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';

class MessageConversationApiModel {
  const MessageConversationApiModel({
    required this.id,
    required this.otherUser,
    required this.updatedAt,
    required this.unreadCount,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageCreatedAt,
  });

  final String id;
  final FriendUserApiModel otherUser;
  final DateTime updatedAt;
  final int unreadCount;
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final DateTime? lastMessageCreatedAt;

  factory MessageConversationApiModel.fromJson(Map<String, dynamic> json) {
    final otherUser = Map<String, dynamic>.from(json['otherUser'] as Map);
    final lastMessage = json['lastMessage'];

    return MessageConversationApiModel(
      id: json['id']?.toString() ?? '',
      otherUser: FriendUserApiModel.fromJson(otherUser),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastMessageText: lastMessage is Map
          ? lastMessage['text']?.toString()
          : null,
      lastMessageSenderId: lastMessage is Map
          ? lastMessage['senderId']?.toString()
          : null,
      lastMessageCreatedAt: lastMessage is Map
          ? DateTime.tryParse(lastMessage['createdAt']?.toString() ?? '')
          : null,
    );
  }

  MessageConversationEntity toEntity() => MessageConversationEntity(
    id: id,
    otherUser: otherUser.toEntity(),
    updatedAt: updatedAt,
    unreadCount: unreadCount,
    lastMessageText: lastMessageText,
    lastMessageSenderId: lastMessageSenderId,
    lastMessageCreatedAt: lastMessageCreatedAt,
  );
}

class MessageApiModel {
  const MessageApiModel({
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

  factory MessageApiModel.fromJson(Map<String, dynamic> json) {
    return MessageApiModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isMine: json['isMine'] == true,
      isReadByOtherUser: json['isReadByOtherUser'] == true,
    );
  }

  MessageEntity toEntity() => MessageEntity(
    id: id,
    conversationId: conversationId,
    text: text,
    senderId: senderId,
    receiverId: receiverId,
    createdAt: createdAt,
    isMine: isMine,
    isReadByOtherUser: isReadByOtherUser,
  );
}
