import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ISocialRepository {
  Future<Either<Failure, List<PostEntity>>> fetchPosts();
  Future<Either<Failure, List<PostEntity>>> fetchMyPosts();
  Future<Either<Failure, List<GroupEntity>>> fetchGroups({String? search});
  Future<Either<Failure, List<GroupEntity>>> fetchMyGroups();
  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    required String description,
    String? imagePath,
  });
  Future<Either<Failure, GroupEntity>> joinGroup({required String groupId});
  Future<Either<Failure, GroupEntity>> leaveGroup({required String groupId});
  Future<Either<Failure, List<PostEntity>>> fetchGroupPosts({
    required String groupId,
  });
  Future<Either<Failure, PostEntity>> createPost({
    required String caption,
    String? imagePath,
    String? communityId,
  });
  Future<Either<Failure, PostEntity>> toggleLike({required String postId});
}
