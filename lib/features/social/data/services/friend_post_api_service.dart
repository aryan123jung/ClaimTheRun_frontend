import 'package:clain_the_run/core/api/api_client.dart';
import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/social/data/models/post_api_model.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';

class FriendPostApiService {
  FriendPostApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<PostEntity>> fetchPostsByUserId(String userId) async {
    final response = await _client.get(ApiEndpoints.userPosts(userId));
    final rawPosts = (response.data['data'] as List?) ?? const [];
    return rawPosts
        .map(
          (item) => PostApiModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ).toEntity(),
        )
        .toList();
  }
}
