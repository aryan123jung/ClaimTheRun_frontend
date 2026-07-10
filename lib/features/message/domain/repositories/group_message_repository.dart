import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:dartz/dartz.dart';

abstract interface class IGroupMessageRepository {
  Future<Either<Failure, List<GroupMessageEntity>>> getGroupMessages(
    String communityId,
  );
  Future<Either<Failure, GroupMessageEntity>> sendGroupMessage(
    String communityId,
    String text,
  );
}
