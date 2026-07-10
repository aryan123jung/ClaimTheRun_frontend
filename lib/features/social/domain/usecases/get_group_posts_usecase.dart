import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/social/data/repositories/social_repository.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/domain/repositories/social_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getGroupPostsUsecaseProvider = Provider<GetGroupPostsUsecase>((ref) {
  return GetGroupPostsUsecase(repository: ref.read(socialRepositoryProvider));
});

class GetGroupPostsUsecase {
  GetGroupPostsUsecase({required ISocialRepository repository})
    : _repository = repository;

  final ISocialRepository _repository;

  Future<Either<Failure, List<PostEntity>>> call(String groupId) {
    return _repository.fetchGroupPosts(groupId: groupId);
  }
}
