import 'package:clain_the_run/core/api/api_client.dart';
import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/social/data/datasources/social_datasource.dart';
import 'package:clain_the_run/features/social/data/models/post_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socialRemoteDatasourceProvider = Provider<ISocialDatasource>((ref) {
  return SocialRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class SocialRemoteDatasource implements ISocialDatasource {
  SocialRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<PostApiModel?> createPost({
    required String caption,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.posts,
      data: {
        'caption': caption,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      },
    );

    if (response.data['success'] == true) {
      return PostApiModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    }

    return null;
  }

  @override
  Future<List<PostApiModel>> fetchPosts() async {
    final response = await _apiClient.get(ApiEndpoints.posts);
    final rawPosts = (response.data['data'] as List?) ?? const [];
    return rawPosts
        .map(
          (item) =>
              PostApiModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<List<PostApiModel>> fetchMyPosts() async {
    final response = await _apiClient.get(ApiEndpoints.myPosts);
    final rawPosts = (response.data['data'] as List?) ?? const [];
    return rawPosts
        .map(
          (item) =>
              PostApiModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<PostApiModel?> toggleLike({required String postId}) async {
    final response = await _apiClient.patch(ApiEndpoints.likePost(postId));

    if (response.data['success'] == true) {
      return PostApiModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    }

    return null;
  }
}
