import 'package:clain_the_run/features/social/data/models/post_api_model.dart';

abstract interface class ISocialDatasource {
  Future<List<PostApiModel>> fetchPosts();
  Future<List<PostApiModel>> fetchMyPosts();
  Future<PostApiModel?> createPost({required String caption, String? imageUrl});
  Future<PostApiModel?> toggleLike({required String postId});
}
