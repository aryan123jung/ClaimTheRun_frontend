import 'package:clain_the_run/features/message/data/services/message_socket_service.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:clain_the_run/features/message/domain/usecases/group_message_usecases.dart';
import 'package:clain_the_run/features/message/presentation/state/group_message_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupMessageViewModelProvider =
    NotifierProvider<GroupMessageViewModel, GroupMessageState>(
      GroupMessageViewModel.new,
    );

class GroupMessageViewModel extends Notifier<GroupMessageState> {
  late final GetGroupMessagesUsecase _getGroupMessagesUsecase;
  late final SendGroupMessageUsecase _sendGroupMessageUsecase;
  late final MessageSocketService _messageSocketService;

  @override
  GroupMessageState build() {
    _getGroupMessagesUsecase = ref.read(getGroupMessagesUsecaseProvider);
    _sendGroupMessageUsecase = ref.read(sendGroupMessageUsecaseProvider);
    _messageSocketService = ref.read(messageSocketServiceProvider);
    _messageSocketService.setOnGroupMessage(_handleIncomingGroupMessage);
    Future<void>.microtask(_messageSocketService.connect);
    ref.onDispose(() {
      _messageSocketService.setOnGroupMessage(null);
    });
    return const GroupMessageState.initial();
  }

  Future<void> joinGroup(String communityId) async {
    _messageSocketService.joinGroup(communityId);
  }

  void leaveGroup(String communityId) {
    _messageSocketService.leaveGroup(communityId);
  }

  Future<void> loadMessages(String communityId, {bool force = false}) async {
    if (!force && state.messagesFor(communityId).isNotEmpty) {
      return;
    }

    state = state.copyWith(
      status: GroupMessageStatus.loading,
      clearError: true,
    );
    final result = await _getGroupMessagesUsecase(
      CommunityIdParams(communityId: communityId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: GroupMessageStatus.error,
        errorMessage: failure.message,
      ),
      (messages) => state = state.copyWith(
        status: GroupMessageStatus.loaded,
        messagesByCommunity: {
          ...state.messagesByCommunity,
          communityId: messages,
        },
        clearError: true,
      ),
    );
  }

  Future<String?> sendMessage(String communityId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'Message cannot be empty.';

    state = state.copyWith(
      status: GroupMessageStatus.sending,
      clearError: true,
    );
    final result = await _sendGroupMessageUsecase(
      SendGroupMessageParams(communityId: communityId, text: trimmed),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: GroupMessageStatus.error,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (message) {
        final updatedMessages = _appendUniqueMessage(
          state.messagesFor(communityId),
          message,
        );
        state = state.copyWith(
          status: GroupMessageStatus.loaded,
          messagesByCommunity: {
            ...state.messagesByCommunity,
            communityId: updatedMessages,
          },
          clearError: true,
        );
        return null;
      },
    );
  }

  void _handleIncomingGroupMessage(GroupMessageEntity message) {
    final communityId = message.communityId;
    final updatedMessages = _appendUniqueMessage(
      state.messagesFor(communityId),
      message,
    );
    state = state.copyWith(
      status: GroupMessageStatus.loaded,
      messagesByCommunity: {
        ...state.messagesByCommunity,
        communityId: updatedMessages,
      },
      clearError: true,
    );
  }

  List<GroupMessageEntity> _appendUniqueMessage(
    List<GroupMessageEntity> items,
    GroupMessageEntity message,
  ) {
    final exists = items.any((item) => item.id == message.id);
    if (exists) {
      return [
        for (final item in items)
          if (item.id == message.id) message else item,
      ];
    }
    return [...items, message];
  }
}
