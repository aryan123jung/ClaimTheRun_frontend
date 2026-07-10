import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:dartz/dartz.dart';

abstract interface class IMessageRepository {
  Future<Either<Failure, List<MessageConversationEntity>>> getConversations();
  Future<Either<Failure, MessageConversationEntity>> getOrCreateConversation(
    String otherUserId,
  );
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  );
  Future<Either<Failure, MessageEntity>> sendMessage(
    String conversationId,
    String text,
  );
  Future<Either<Failure, void>> markConversationRead(String conversationId);
}
