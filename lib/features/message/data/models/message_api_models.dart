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

class GroupSenderApiModel {
  const GroupSenderApiModel({
    required this.id,
    required this.fullname,
    required this.username,
    this.profileUrl,
  });

  final String id;
  final String fullname;
  final String username;
  final String? profileUrl;

  factory GroupSenderApiModel.fromJson(Map<String, dynamic> json) {
    return GroupSenderApiModel(
      id: json['id']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? 'Runner',
      username: json['username']?.toString() ?? '',
      profileUrl: json['profileUrl']?.toString(),
    );
  }

  GroupSenderEntity toEntity() => GroupSenderEntity(
    id: id,
    fullname: fullname,
    username: username,
    profileUrl: profileUrl,
  );
}

class GroupMessageApiModel {
  const GroupMessageApiModel({
    required this.id,
    required this.communityId,
    required this.text,
    required this.createdAt,
    required this.sender,
    required this.isMine,
  });

  final String id;
  final String communityId;
  final String text;
  final DateTime createdAt;
  final GroupSenderApiModel sender;
  final bool isMine;

  factory GroupMessageApiModel.fromJson(Map<String, dynamic> json) {
    return GroupMessageApiModel(
      id: json['id']?.toString() ?? '',
      communityId: json['communityId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      sender: GroupSenderApiModel.fromJson(
        Map<String, dynamic>.from(json['sender'] as Map? ?? const {}),
      ),
      isMine: json['isMine'] == true,
    );
  }

  GroupMessageEntity toEntity() => GroupMessageEntity(
    id: id,
    communityId: communityId,
    text: text,
    createdAt: createdAt,
    sender: sender.toEntity(),
    isMine: isMine,
  );
}
