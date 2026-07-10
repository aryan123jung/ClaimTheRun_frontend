import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/social/data/repositories/social_repository.dart';
import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/domain/repositories/social_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final joinGroupUsecaseProvider = Provider<JoinGroupUsecase>((ref) {
  return JoinGroupUsecase(repository: ref.read(socialRepositoryProvider));
});

class JoinGroupUsecase {
  JoinGroupUsecase({required ISocialRepository repository})
    : _repository = repository;

  final ISocialRepository _repository;

  Future<Either<Failure, GroupEntity>> call(String groupId) {
    return _repository.joinGroup(groupId: groupId);
  }
}
