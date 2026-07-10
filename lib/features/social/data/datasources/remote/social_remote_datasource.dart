import 'package:clain_the_run/core/api/api_client.dart';
import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/social/data/datasources/social_datasource.dart';
import 'package:clain_the_run/features/social/data/models/group_api_model.dart';
import 'package:clain_the_run/features/social/data/models/post_api_model.dart';
import 'package:dio/dio.dart';
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
    String? imagePath,
    String? communityId,
  }) async {
    final payload = <String, dynamic>{'caption': caption};
    if (communityId != null && communityId.isNotEmpty) {
      payload['communityId'] = communityId;
    }
    if (imagePath != null && imagePath.isNotEmpty) {
      payload['postImage'] = await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      );
    }

    final response = await _apiClient.post(
      ApiEndpoints.posts,
      data: FormData.fromMap(payload),
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      return PostApiModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    }

    return null;
  }

  @override
  Future<GroupApiModel?> createGroup({
    required String name,
    required String description,
    String? imagePath,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'description': description,
    };
    if (imagePath != null && imagePath.isNotEmpty) {
      payload['groupImage'] = await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      );
    }

    final response = await _apiClient.post(
      ApiEndpoints.groupsBase,
      data: FormData.fromMap(payload),
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      return GroupApiModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    }

    return null;
  }

  @override
  Future<List<PostApiModel>> fetchGroupPosts({required String groupId}) async {
    final response = await _apiClient.get(ApiEndpoints.groupPosts(groupId));
    final rawPosts = (response.data['data'] as List?) ?? const [];
    return rawPosts
        .map(
          (item) =>
              PostApiModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<List<GroupApiModel>> fetchGroups({String? search}) async {
    final response = await _apiClient.get(
      ApiEndpoints.searchGroups,
      queryParameters: search == null || search.trim().isEmpty
          ? null
          : {'search': search.trim()},
    );
    final rawGroups = (response.data['data'] as List?) ?? const [];
    return rawGroups
        .map(
          (item) =>
              GroupApiModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<GroupApiModel?> joinGroup({required String groupId}) async {
    final response = await _apiClient.post(ApiEndpoints.joinGroup(groupId));
    if (response.data['success'] == true) {
      return GroupApiModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    }
    return null;
  }

  @override
  Future<GroupApiModel?> leaveGroup({required String groupId}) async {
    final response = await _apiClient.post(ApiEndpoints.leaveGroup(groupId));
    if (response.data['success'] == true) {
      return GroupApiModel.fromJson(
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
