import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/message/data/repositories/message_repository.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:clain_the_run/features/message/domain/repositories/message_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getConversationsUsecaseProvider = Provider<GetConversationsUsecase>((
  ref,
) {
  return GetConversationsUsecase(
    repository: ref.read(messageRepositoryProvider),
  );
});

final getOrCreateConversationUsecaseProvider =
    Provider<GetOrCreateConversationUsecase>((ref) {
      return GetOrCreateConversationUsecase(
        repository: ref.read(messageRepositoryProvider),
      );
    });

final getMessagesUsecaseProvider = Provider<GetMessagesUsecase>((ref) {
  return GetMessagesUsecase(repository: ref.read(messageRepositoryProvider));
});

final sendMessageUsecaseProvider = Provider<SendMessageUsecase>((ref) {
  return SendMessageUsecase(repository: ref.read(messageRepositoryProvider));
});

final markConversationReadUsecaseProvider =
    Provider<MarkConversationReadUsecase>((ref) {
      return MarkConversationReadUsecase(
        repository: ref.read(messageRepositoryProvider),
      );
    });

class GetConversationsUsecase
    implements UsecaseWithoutParams<List<MessageConversationEntity>> {
  GetConversationsUsecase({required IMessageRepository repository})
    : _repository = repository;

  final IMessageRepository _repository;

  @override
  Future<Either<Failure, List<MessageConversationEntity>>> call() {
    return _repository.getConversations();
  }
}

class GetOrCreateConversationUsecase
    implements UsecaseWithParams<MessageConversationEntity, UserIdParams> {
  GetOrCreateConversationUsecase({required IMessageRepository repository})
    : _repository = repository;

  final IMessageRepository _repository;

  @override
  Future<Either<Failure, MessageConversationEntity>> call(UserIdParams params) {
    return _repository.getOrCreateConversation(params.userId);
  }
}

class GetMessagesUsecase
    implements UsecaseWithParams<List<MessageEntity>, ConversationIdParams> {
  GetMessagesUsecase({required IMessageRepository repository})
    : _repository = repository;

  final IMessageRepository _repository;

  @override
  Future<Either<Failure, List<MessageEntity>>> call(
    ConversationIdParams params,
  ) {
    return _repository.getMessages(params.conversationId);
  }
}

class SendMessageUsecase
    implements UsecaseWithParams<MessageEntity, SendMessageParams> {
  SendMessageUsecase({required IMessageRepository repository})
    : _repository = repository;

  final IMessageRepository _repository;

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return _repository.sendMessage(params.conversationId, params.text);
  }
}

class MarkConversationReadUsecase
    implements UsecaseWithParams<void, ConversationIdParams> {
  MarkConversationReadUsecase({required IMessageRepository repository})
    : _repository = repository;

  final IMessageRepository _repository;

  @override
  Future<Either<Failure, void>> call(ConversationIdParams params) {
    return _repository.markConversationRead(params.conversationId);
  }
}

class UserIdParams extends Equatable {
  const UserIdParams({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class ConversationIdParams extends Equatable {
  const ConversationIdParams({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class SendMessageParams extends Equatable {
  const SendMessageParams({required this.conversationId, required this.text});

  final String conversationId;
  final String text;

  @override
  List<Object?> get props => [conversationId, text];
}
