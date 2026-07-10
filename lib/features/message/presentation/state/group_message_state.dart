import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';

enum GroupMessageStatus { initial, loading, loaded, sending, error }

class GroupMessageState {
  const GroupMessageState({
    required this.status,
    required this.messagesByCommunity,
    this.errorMessage,
  });

  const GroupMessageState.initial()
    : status = GroupMessageStatus.initial,
      messagesByCommunity = const {},
      errorMessage = null;

  final GroupMessageStatus status;
  final Map<String, List<GroupMessageEntity>> messagesByCommunity;
  final String? errorMessage;

  List<GroupMessageEntity> messagesFor(String communityId) =>
      messagesByCommunity[communityId] ?? const [];

  GroupMessageState copyWith({
    GroupMessageStatus? status,
    Map<String, List<GroupMessageEntity>>? messagesByCommunity,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GroupMessageState(
      status: status ?? this.status,
      messagesByCommunity: messagesByCommunity ?? this.messagesByCommunity,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
