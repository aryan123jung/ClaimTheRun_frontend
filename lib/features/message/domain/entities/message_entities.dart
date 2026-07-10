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

class GroupSenderEntity extends Equatable {
  const GroupSenderEntity({
    required this.id,
    required this.fullname,
    required this.username,
    this.profileUrl,
  });

  final String id;
  final String fullname;
  final String username;
  final String? profileUrl;

  @override
  List<Object?> get props => [id, fullname, username, profileUrl];
}

class GroupMessageEntity extends Equatable {
  const GroupMessageEntity({
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
  final GroupSenderEntity sender;
  final bool isMine;

  @override
  List<Object?> get props => [id, communityId, text, createdAt, sender, isMine];
}
