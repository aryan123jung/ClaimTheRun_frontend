import 'package:clain_the_run/features/addfriend/domain/entities/friend_request_entity.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';

enum AddFriendStatus { initial, loading, loaded, action, error }

class AddFriendState {
  const AddFriendState({
    required this.status,
    required this.friends,
    required this.searchResults,
    required this.incomingRequests,
    required this.searchText,
    this.errorMessage,
  });

  const AddFriendState.initial()
    : status = AddFriendStatus.initial,
      friends = const [],
      searchResults = const [],
      incomingRequests = const [],
      searchText = '',
      errorMessage = null;

  final AddFriendStatus status;
  final List<FriendUserEntity> friends;
  final List<FriendUserEntity> searchResults;
  final List<FriendRequestEntity> incomingRequests;
  final String searchText;
  final String? errorMessage;

  AddFriendState copyWith({
    AddFriendStatus? status,
    List<FriendUserEntity>? friends,
    List<FriendUserEntity>? searchResults,
    List<FriendRequestEntity>? incomingRequests,
    String? searchText,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddFriendState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      searchResults: searchResults ?? this.searchResults,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      searchText: searchText ?? this.searchText,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
