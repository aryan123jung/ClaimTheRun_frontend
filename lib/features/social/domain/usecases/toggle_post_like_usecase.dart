import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/social/data/repositories/social_repository.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/domain/repositories/social_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final togglePostLikeUsecaseProvider = Provider<TogglePostLikeUsecase>((ref) {
  return TogglePostLikeUsecase(repository: ref.read(socialRepositoryProvider));
});

class TogglePostLikeUsecase
    implements UsecaseWithParams<PostEntity, TogglePostLikeUsecaseParams> {
  TogglePostLikeUsecase({required ISocialRepository repository})
    : _repository = repository;

  final ISocialRepository _repository;

  @override
  Future<Either<Failure, PostEntity>> call(TogglePostLikeUsecaseParams params) {
    return _repository.toggleLike(postId: params.postId);
  }
}

class TogglePostLikeUsecaseParams extends Equatable {
  const TogglePostLikeUsecaseParams({required this.postId});

  final String postId;

  @override
  List<Object?> get props => [postId];
}
