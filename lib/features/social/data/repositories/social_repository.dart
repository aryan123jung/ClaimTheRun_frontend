import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/social/data/datasources/remote/social_remote_datasource.dart';
import 'package:clain_the_run/features/social/data/datasources/social_datasource.dart';
import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/domain/repositories/social_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socialRepositoryProvider = Provider<ISocialRepository>((ref) {
  return SocialRepository(
    socialDatasource: ref.read(socialRemoteDatasourceProvider),
  );
});

class SocialRepository implements ISocialRepository {
  SocialRepository({required ISocialDatasource socialDatasource})
    : _socialDatasource = socialDatasource;

  final ISocialDatasource _socialDatasource;

  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String caption,
    String? imagePath,
    String? communityId,
  }) async {
    try {
      final post = await _socialDatasource.createPost(
        caption: caption,
        imagePath: imagePath,
        communityId: communityId,
      );
      if (post == null) {
        return const Left(ApiFailure(message: 'Unable to create post'));
      }
      return Right(post.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Unable to create post',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    required String description,
    String? imagePath,
  }) async {
    try {
      final group = await _socialDatasource.createGroup(
        name: name,
        description: description,
        imagePath: imagePath,
      );
      if (group == null) {
        return const Left(ApiFailure(message: 'Unable to create group'));
      }
      return Right(group.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Unable to create group',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupEntity>>> fetchGroups({String? search}) async {
    try {
      final groups = await _socialDatasource.fetchGroups(search: search);
      return Right(groups.map((group) => group.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Unable to load groups',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> fetchGroupPosts({
    required String groupId,
  }) async {
    try {
      final posts = await _socialDatasource.fetchGroupPosts(groupId: groupId);
      return Right(posts.map((post) => post.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Unable to load group posts',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> joinGroup({required String groupId}) async {
    try {
      final group = await _socialDatasource.joinGroup(groupId: groupId);
      if (group == null) {
        return const Left(ApiFailure(message: 'Unable to join group'));
      }
      return Right(group.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Unable to join group',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> leaveGroup({
    required String groupId,
  }) async {
    try {
      final group = await _socialDatasource.leaveGroup(groupId: groupId);
      if (group == null) {
        return const Left(ApiFailure(message: 'Unable to leave group'));
      }
      return Right(group.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Unable to leave group',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> fetchPosts() async {
    try {
      final posts = await _socialDatasource.fetchPosts();
      return Right(posts.map((post) => post.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Unable to load posts',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> fetchMyPosts() async {
    try {
      final posts = await _socialDatasource.fetchMyPosts();
      return Right(posts.map((post) => post.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Unable to load my posts',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> toggleLike({
    required String postId,
  }) async {
    try {
      final post = await _socialDatasource.toggleLike(postId: postId);
      if (post == null) {
        return const Left(ApiFailure(message: 'Unable to update post'));
      }
      return Right(post.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Unable to update post',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  String? _extractErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}
