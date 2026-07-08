import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/social/data/repositories/social_repository.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/domain/repositories/social_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getMyPostsUsecaseProvider = Provider<GetMyPostsUsecase>((ref) {
  return GetMyPostsUsecase(repository: ref.read(socialRepositoryProvider));
});

class GetMyPostsUsecase implements UsecaseWithoutParams<List<PostEntity>> {
  GetMyPostsUsecase({required ISocialRepository repository})
    : _repository = repository;

  final ISocialRepository _repository;

  @override
  Future<Either<Failure, List<PostEntity>>> call() {
    return _repository.fetchMyPosts();
  }
}
