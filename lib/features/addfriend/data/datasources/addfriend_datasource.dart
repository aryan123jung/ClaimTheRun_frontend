import 'package:clain_the_run/features/addfriend/data/models/friend_request_api_model.dart';
import 'package:clain_the_run/features/addfriend/data/models/friend_user_api_model.dart';

abstract interface class IAddFriendDatasource {
  Future<List<FriendUserApiModel>> searchUsers(String search);
  Future<List<FriendRequestApiModel>> getIncomingRequests();
  Future<void> sendFriendRequest(String userId);
  Future<void> cancelFriendRequest(String userId);
  Future<void> unfriend(String userId);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
}
