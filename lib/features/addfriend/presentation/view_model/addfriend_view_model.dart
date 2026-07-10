import 'package:clain_the_run/features/addfriend/domain/entities/friend_request_entity.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';
import 'package:clain_the_run/features/addfriend/domain/usecases/friend_request_actions_usecase.dart';
import 'package:clain_the_run/features/addfriend/domain/usecases/get_incoming_requests_usecase.dart';
import 'package:clain_the_run/features/addfriend/domain/usecases/search_users_usecase.dart';
import 'package:clain_the_run/features/addfriend/presentation/state/addfriend_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addFriendViewModelProvider =
    NotifierProvider<AddFriendViewModel, AddFriendState>(
      AddFriendViewModel.new,
    );

class AddFriendViewModel extends Notifier<AddFriendState> {
  late final SearchUsersUsecase _searchUsersUsecase;
  late final GetIncomingRequestsUsecase _getIncomingRequestsUsecase;
  late final SendFriendRequestUsecase _sendFriendRequestUsecase;
  late final CancelFriendRequestUsecase _cancelFriendRequestUsecase;
  late final AcceptFriendRequestUsecase _acceptFriendRequestUsecase;
  late final RejectFriendRequestUsecase _rejectFriendRequestUsecase;
  late final UnfriendUsecase _unfriendUsecase;

  @override
  AddFriendState build() {
    _searchUsersUsecase = ref.read(searchUsersUsecaseProvider);
    _getIncomingRequestsUsecase = ref.read(getIncomingRequestsUsecaseProvider);
    _sendFriendRequestUsecase = ref.read(sendFriendRequestUsecaseProvider);
    _cancelFriendRequestUsecase = ref.read(cancelFriendRequestUsecaseProvider);
    _acceptFriendRequestUsecase = ref.read(acceptFriendRequestUsecaseProvider);
    _rejectFriendRequestUsecase = ref.read(rejectFriendRequestUsecaseProvider);
    _unfriendUsecase = ref.read(unfriendUsecaseProvider);
    return const AddFriendState.initial();
  }

  Future<void> searchUsers([String search = '']) async {
    state = state.copyWith(
      status: AddFriendStatus.loading,
      searchText: search,
      clearError: true,
    );
    final result = await _searchUsersUsecase(SearchUsersParams(search: search));
    result.fold(
      (failure) => state = state.copyWith(
        status: AddFriendStatus.error,
        errorMessage: failure.message,
      ),
      (users) => state = state.copyWith(
        status: AddFriendStatus.loaded,
        searchResults: users,
        clearError: true,
      ),
    );
  }

  Future<void> loadFriends({bool showLoader = true}) async {
    state = state.copyWith(
      status: showLoader ? AddFriendStatus.loading : state.status,
      clearError: true,
    );
    final result = await _searchUsersUsecase(
      const SearchUsersParams(search: ''),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AddFriendStatus.error,
        errorMessage: failure.message,
      ),
      (users) => state = state.copyWith(
        status: AddFriendStatus.loaded,
        friends: users.where((user) => user.friendStatus == 'FRIEND').toList(),
        clearError: true,
      ),
    );
  }

  Future<void> loadIncomingRequests() async {
    state = state.copyWith(status: AddFriendStatus.loading, clearError: true);
    final result = await _getIncomingRequestsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: AddFriendStatus.error,
        errorMessage: failure.message,
      ),
      (items) => state = state.copyWith(
        status: AddFriendStatus.loaded,
        incomingRequests: items,
        clearError: true,
      ),
    );
  }

  Future<String?> sendRequest(FriendUserEntity user) async {
    state = state.copyWith(status: AddFriendStatus.action, clearError: true);
    final result = await _sendFriendRequestUsecase(
      FriendTargetParams(id: user.id),
    );
    String? message;
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AddFriendStatus.error,
          errorMessage: failure.message,
        );
        message = failure.message;
      },
      (_) {
        final updatedUser = user.copyWith(friendStatus: 'PENDING_OUTGOING');
        state = state.copyWith(
          status: AddFriendStatus.loaded,
          searchResults: _replaceUser(updatedUser),
          friends: _replaceFriend(updatedUser),
        );
      },
    );

    if (message != null) {
      await _reconcileRemoteState(user.id);
      return message;
    }

    await loadFriends(showLoader: false);
    await _refreshSearchIfNeeded();
    return null;
  }

  Future<String?> cancelRequest(FriendUserEntity user) async {
    state = state.copyWith(status: AddFriendStatus.action, clearError: true);
    final result = await _cancelFriendRequestUsecase(
      FriendTargetParams(id: user.id),
    );
    String? message;
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AddFriendStatus.error,
          errorMessage: failure.message,
        );
        message = failure.message;
      },
      (_) {
        final updatedUser = user.copyWith(friendStatus: 'NONE');
        state = state.copyWith(
          status: AddFriendStatus.loaded,
          searchResults: _replaceUser(updatedUser),
          friends: _replaceFriend(updatedUser),
        );
      },
    );

    if (message != null) {
      await _reconcileRemoteState(user.id);
      return message;
    }

    await loadFriends(showLoader: false);
    await _refreshSearchIfNeeded();
    return null;
  }

  Future<String?> acceptRequest(FriendRequestEntity request) async {
    state = state.copyWith(status: AddFriendStatus.action, clearError: true);
    final result = await _acceptFriendRequestUsecase(
      FriendTargetParams(id: request.id),
    );
    String? message;
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AddFriendStatus.error,
          errorMessage: failure.message,
        );
        message = failure.message;
      },
      (_) {
        final updatedFriends = [
          ...state.friends.where((item) => item.id != request.userId),
          ...state.searchResults
              .where((item) => item.id == request.userId)
              .map((item) => item.copyWith(friendStatus: 'FRIEND')),
        ];
        state = state.copyWith(
          status: AddFriendStatus.loaded,
          friends: updatedFriends,
          incomingRequests: state.incomingRequests
              .where((e) => e.id != request.id)
              .toList(),
          searchResults: _patchUserStatus(request.userId, 'FRIEND'),
        );
      },
    );

    if (message != null) {
      return message;
    }

    await loadFriends(showLoader: false);
    await _refreshSearchIfNeeded();
    return null;
  }

  Future<String?> rejectRequest(FriendRequestEntity request) async {
    state = state.copyWith(status: AddFriendStatus.action, clearError: true);
    final result = await _rejectFriendRequestUsecase(
      FriendTargetParams(id: request.id),
    );
    String? message;
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AddFriendStatus.error,
          errorMessage: failure.message,
        );
        message = failure.message;
      },
      (_) {
        state = state.copyWith(
          status: AddFriendStatus.loaded,
          incomingRequests: state.incomingRequests
              .where((e) => e.id != request.id)
              .toList(),
          searchResults: _patchUserStatus(request.userId, 'NONE'),
        );
      },
    );

    if (message != null) {
      return message;
    }

    await loadFriends(showLoader: false);
    await _refreshSearchIfNeeded();
    return null;
  }

  Future<String?> unfriend(FriendUserEntity user) async {
    state = state.copyWith(status: AddFriendStatus.action, clearError: true);
    final result = await _unfriendUsecase(FriendTargetParams(id: user.id));
    String? message;
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AddFriendStatus.error,
          errorMessage: failure.message,
        );
        message = failure.message;
      },
      (_) {
        final updatedUser = user.copyWith(friendStatus: 'NONE');
        state = state.copyWith(
          status: AddFriendStatus.loaded,
          searchResults: _replaceUser(updatedUser),
          friends: state.friends.where((item) => item.id != user.id).toList(),
        );
      },
    );

    if (message != null) {
      await _reconcileRemoteState(user.id);
      return message;
    }

    await loadFriends(showLoader: false);
    await _refreshSearchIfNeeded();
    return null;
  }

  Future<void> _refreshSearchIfNeeded() async {
    final currentSearch = state.searchText.trim();
    if (currentSearch.isEmpty) {
      return;
    }

    final result = await _searchUsersUsecase(
      SearchUsersParams(search: currentSearch),
    );
    result.fold(
      (_) {},
      (users) => state = state.copyWith(
        status: AddFriendStatus.loaded,
        searchResults: users,
        clearError: true,
      ),
    );
  }

  Future<void> _reconcileRemoteState(String userId) async {
    final currentSearch = state.searchText.trim();
    if (currentSearch.isNotEmpty) {
      await _refreshSearchIfNeeded();
    } else {
      await loadFriends(showLoader: false);
    }

    final refreshed = [
      ...state.searchResults,
      ...state.friends,
    ].where((item) => item.id == userId);

    if (refreshed.isEmpty) return;
    final item = refreshed.first;
    state = state.copyWith(
      status: AddFriendStatus.loaded,
      searchResults: _replaceUser(item),
      friends: _replaceFriend(item),
      clearError: true,
    );
  }

  List<FriendUserEntity> _replaceUser(FriendUserEntity updated) {
    return [
      for (final item in state.searchResults)
        if (item.id == updated.id) updated else item,
    ];
  }

  List<FriendUserEntity> _patchUserStatus(String userId, String status) {
    return [
      for (final item in state.searchResults)
        if (item.id == userId) item.copyWith(friendStatus: status) else item,
    ];
  }

  List<FriendUserEntity> _replaceFriend(FriendUserEntity updated) {
    if (updated.friendStatus != 'FRIEND') {
      return state.friends.where((item) => item.id != updated.id).toList();
    }

    final exists = state.friends.any((item) => item.id == updated.id);
    if (!exists) {
      return [...state.friends, updated];
    }

    return [
      for (final item in state.friends)
        if (item.id == updated.id) updated else item,
    ];
  }
}
