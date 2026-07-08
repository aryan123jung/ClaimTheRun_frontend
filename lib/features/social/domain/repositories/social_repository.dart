import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ISocialRepository {
  Future<Either<Failure, List<PostEntity>>> fetchPosts();
  Future<Either<Failure, List<PostEntity>>> fetchMyPosts();
  Future<Either<Failure, PostEntity>> createPost({
    required String caption,
    String? imageUrl,
  });
  Future<Either<Failure, PostEntity>> toggleLike({required String postId});
}
