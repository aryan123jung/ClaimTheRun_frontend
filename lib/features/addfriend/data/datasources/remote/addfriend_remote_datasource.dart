import 'package:clain_the_run/core/api/api_client.dart';
import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/addfriend/data/datasources/addfriend_datasource.dart';
import 'package:clain_the_run/features/addfriend/data/models/friend_request_api_model.dart';
import 'package:clain_the_run/features/addfriend/data/models/friend_user_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addFriendRemoteDatasourceProvider = Provider<IAddFriendDatasource>((ref) {
  return AddFriendRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class AddFriendRemoteDatasource implements IAddFriendDatasource {
  AddFriendRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    await _apiClient.post(ApiEndpoints.acceptFriendRequest(requestId));
  }

  @override
  Future<void> cancelFriendRequest(String userId) async {
    await _apiClient.delete(ApiEndpoints.cancelFriendRequest(userId));
  }

  @override
  Future<List<FriendRequestApiModel>> getIncomingRequests() async {
    final response = await _apiClient.get(ApiEndpoints.incomingFriendRequests);
    final data = (response.data['data'] as List?) ?? const [];
    return data
        .map(
          (e) => FriendRequestApiModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    await _apiClient.post(ApiEndpoints.rejectFriendRequest(requestId));
  }

  @override
  Future<List<FriendUserApiModel>> searchUsers(String search) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.friendsBase}/search',
      queryParameters: search.trim().isEmpty ? null : {'search': search.trim()},
    );
    final data = (response.data['data'] as List?) ?? const [];
    return data
        .map(
          (e) =>
              FriendUserApiModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  @override
  Future<void> sendFriendRequest(String userId) async {
    await _apiClient.post(ApiEndpoints.sendFriendRequest(userId));
  }

  @override
  Future<void> unfriend(String userId) async {
    await _apiClient.delete(ApiEndpoints.unfriend(userId));
  }
}
