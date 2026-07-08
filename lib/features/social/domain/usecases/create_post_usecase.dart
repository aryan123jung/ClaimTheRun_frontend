import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/social/data/repositories/social_repository.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/domain/repositories/social_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createPostUsecaseProvider = Provider<CreatePostUsecase>((ref) {
  return CreatePostUsecase(repository: ref.read(socialRepositoryProvider));
});

class CreatePostUsecase
    implements UsecaseWithParams<PostEntity, CreatePostUsecaseParams> {
  CreatePostUsecase({required ISocialRepository repository})
    : _repository = repository;

  final ISocialRepository _repository;

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostUsecaseParams params) {
    return _repository.createPost(
      caption: params.caption,
      imageUrl: params.imageUrl,
    );
  }
}

class CreatePostUsecaseParams extends Equatable {
  const CreatePostUsecaseParams({required this.caption, this.imageUrl});

  final String caption;
  final String? imageUrl;

  @override
  List<Object?> get props => [caption, imageUrl];
}
