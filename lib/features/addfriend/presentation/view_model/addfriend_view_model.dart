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
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AddFriendStatus.error,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (_) {
        state = state.copyWith(
          status: AddFriendStatus.loaded,
          searchResults: _replaceUser(
            user.copyWith(friendStatus: 'PENDING_OUTGOING'),
          ),
        );
        return null;
      },
    );
  }

  Future<String?> cancelRequest(FriendUserEntity user) async {
    state = state.copyWith(status: AddFriendStatus.action, clearError: true);
    final result = await _cancelFriendRequestUsecase(
      FriendTargetParams(id: user.id),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AddFriendStatus.error,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (_) {
        state = state.copyWith(
          status: AddFriendStatus.loaded,
          searchResults: _replaceUser(user.copyWith(friendStatus: 'NONE')),
        );
        return null;
      },
    );
  }

  Future<String?> acceptRequest(FriendRequestEntity request) async {
    state = state.copyWith(status: AddFriendStatus.action, clearError: true);
    final result = await _acceptFriendRequestUsecase(
      FriendTargetParams(id: request.id),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AddFriendStatus.error,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (_) {
        state = state.copyWith(
          status: AddFriendStatus.loaded,
          incomingRequests: state.incomingRequests
              .where((e) => e.id != request.id)
              .toList(),
          searchResults: _patchUserStatus(request.userId, 'FRIEND'),
        );
        return null;
      },
    );
  }

  Future<String?> rejectRequest(FriendRequestEntity request) async {
    state = state.copyWith(status: AddFriendStatus.action, clearError: true);
    final result = await _rejectFriendRequestUsecase(
      FriendTargetParams(id: request.id),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AddFriendStatus.error,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (_) {
        state = state.copyWith(
          status: AddFriendStatus.loaded,
          incomingRequests: state.incomingRequests
              .where((e) => e.id != request.id)
              .toList(),
          searchResults: _patchUserStatus(request.userId, 'NONE'),
        );
        return null;
      },
    );
  }

  Future<String?> unfriend(FriendUserEntity user) async {
    state = state.copyWith(status: AddFriendStatus.action, clearError: true);
    final result = await _unfriendUsecase(FriendTargetParams(id: user.id));
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AddFriendStatus.error,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (_) {
        state = state.copyWith(
          status: AddFriendStatus.loaded,
          searchResults: _replaceUser(user.copyWith(friendStatus: 'NONE')),
        );
        return null;
      },
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
}
