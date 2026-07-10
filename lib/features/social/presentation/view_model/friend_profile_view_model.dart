import 'package:clain_the_run/features/social/presentation/state/friend_profile_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendProfileViewModelProvider =
    NotifierProvider<FriendProfileViewModel, FriendProfileState>(
      FriendProfileViewModel.new,
    );

class FriendProfileViewModel extends Notifier<FriendProfileState> {
  String? _friendId;

  @override
  FriendProfileState build() {
    return const FriendProfileState();
  }

  void ensureInitialized({
    required String friendId,
    required String? actionLabel,
  }) {
    if (_friendId == friendId && state.actionLabel == actionLabel) {
      return;
    }

    _friendId = friendId;
    state = FriendProfileState(actionLabel: actionLabel);
  }

  Future<String> submitAction(
    Future<String?> Function(String currentLabel) handler,
  ) async {
    final label = state.actionLabel;
    if (label == null || state.isSubmitting) {
      return 'Updated successfully.';
    }

    state = state.copyWith(isSubmitting: true);
    final message = await handler(label);
    state = state.copyWith(
      isSubmitting: false,
      actionLabel: _nextActionLabel(label),
    );

    return message ?? _defaultSuccessMessage(label);
  }

  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  String? _nextActionLabel(String currentLabel) {
    switch (currentLabel) {
      case 'Remove Friend':
        return 'Add Friend';
      case 'Add Friend':
        return 'Cancel Request';
      case 'Cancel Request':
        return 'Add Friend';
      default:
        return currentLabel;
    }
  }

  String _defaultSuccessMessage(String currentLabel) {
    switch (currentLabel) {
      case 'Remove Friend':
        return 'Friend removed successfully.';
      case 'Add Friend':
        return 'Friend request sent.';
      case 'Cancel Request':
        return 'Friend request cancelled.';
      default:
        return 'Updated successfully.';
    }
  }
}
