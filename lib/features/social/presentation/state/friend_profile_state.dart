class FriendProfileState {
  const FriendProfileState({this.actionLabel, this.isSubmitting = false});

  final String? actionLabel;
  final bool isSubmitting;

  FriendProfileState copyWith({
    String? actionLabel,
    bool? isSubmitting,
    bool clearActionLabel = false,
  }) {
    return FriendProfileState(
      actionLabel: clearActionLabel ? null : (actionLabel ?? this.actionLabel),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
