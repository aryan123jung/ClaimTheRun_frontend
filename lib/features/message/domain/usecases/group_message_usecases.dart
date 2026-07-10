import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/message/data/repositories/group_message_repository.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:clain_the_run/features/message/domain/repositories/group_message_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getGroupMessagesUsecaseProvider = Provider<GetGroupMessagesUsecase>((
  ref,
) {
  return GetGroupMessagesUsecase(
    repository: ref.read(groupMessageRepositoryProvider),
  );
});

final sendGroupMessageUsecaseProvider = Provider<SendGroupMessageUsecase>((
  ref,
) {
  return SendGroupMessageUsecase(
    repository: ref.read(groupMessageRepositoryProvider),
  );
});

class GetGroupMessagesUsecase
    implements UsecaseWithParams<List<GroupMessageEntity>, CommunityIdParams> {
  GetGroupMessagesUsecase({required IGroupMessageRepository repository})
    : _repository = repository;

  final IGroupMessageRepository _repository;

  @override
  Future<Either<Failure, List<GroupMessageEntity>>> call(
    CommunityIdParams params,
  ) {
    return _repository.getGroupMessages(params.communityId);
  }
}

class SendGroupMessageUsecase
    implements UsecaseWithParams<GroupMessageEntity, SendGroupMessageParams> {
  SendGroupMessageUsecase({required IGroupMessageRepository repository})
    : _repository = repository;

  final IGroupMessageRepository _repository;

  @override
  Future<Either<Failure, GroupMessageEntity>> call(
    SendGroupMessageParams params,
  ) {
    return _repository.sendGroupMessage(params.communityId, params.text);
  }
}

class CommunityIdParams extends Equatable {
  const CommunityIdParams({required this.communityId});

  final String communityId;

  @override
  List<Object?> get props => [communityId];
}

class SendGroupMessageParams extends Equatable {
  const SendGroupMessageParams({required this.communityId, required this.text});

  final String communityId;
  final String text;

  @override
  List<Object?> get props => [communityId, text];
}
