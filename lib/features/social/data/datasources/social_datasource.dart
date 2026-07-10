import 'package:clain_the_run/features/social/data/models/group_api_model.dart';
import 'package:clain_the_run/features/social/data/models/post_api_model.dart';

abstract interface class ISocialDatasource {
  Future<List<PostApiModel>> fetchPosts();
  Future<List<PostApiModel>> fetchMyPosts();
  Future<List<GroupApiModel>> fetchGroups({String? search});
  Future<List<GroupApiModel>> fetchMyGroups();
  Future<GroupApiModel?> createGroup({
    required String name,
    required String description,
    String? imagePath,
  });
  Future<GroupApiModel?> joinGroup({required String groupId});
  Future<GroupApiModel?> leaveGroup({required String groupId});
  Future<List<PostApiModel>> fetchGroupPosts({required String groupId});
  Future<PostApiModel?> createPost({
    required String caption,
    String? imagePath,
    String? communityId,
  });
  Future<PostApiModel?> toggleLike({required String postId});
}
