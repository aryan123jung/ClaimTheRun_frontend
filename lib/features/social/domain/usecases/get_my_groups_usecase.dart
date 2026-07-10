import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/social/data/repositories/social_repository.dart';
import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/domain/repositories/social_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getMyGroupsUsecaseProvider = Provider<GetMyGroupsUsecase>((ref) {
  return GetMyGroupsUsecase(repository: ref.read(socialRepositoryProvider));
});

class GetMyGroupsUsecase {
  GetMyGroupsUsecase({required ISocialRepository repository})
    : _repository = repository;

  final ISocialRepository _repository;

  Future<Either<Failure, List<GroupEntity>>> call() {
    return _repository.fetchMyGroups();
  }
}
