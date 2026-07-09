import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_request_entity.dart';
import 'package:clain_the_run/features/addfriend/presentation/state/addfriend_state.dart';
import 'package:clain_the_run/features/addfriend/presentation/view_model/addfriend_view_model.dart';
import 'package:clain_the_run/features/addfriend/presentation/widgets/add_friend_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendRequestsScreen extends ConsumerStatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  ConsumerState<FriendRequestsScreen> createState() =>
      _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends ConsumerState<FriendRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(addFriendViewModelProvider.notifier).loadIncomingRequests(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addFriendViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 18, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Expanded(
                    child: Text(
                      'Friend Requests',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'See everyone waiting to connect with you.',
                style: TextStyle(fontSize: 13, color: Color(0xFF707070)),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _RequestBody(
                state: state,
                onRetry: () {
                  ref
                      .read(addFriendViewModelProvider.notifier)
                      .loadIncomingRequests();
                },
                onAccept: (request) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final message = await ref
                      .read(addFriendViewModelProvider.notifier)
                      .acceptRequest(request);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(message ?? 'Friend request accepted.'),
                    ),
                  );
                },
                onReject: (request) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final message = await ref
                      .read(addFriendViewModelProvider.notifier)
                      .rejectRequest(request);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(message ?? 'Friend request deleted.'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestBody extends StatelessWidget {
  const _RequestBody({
    required this.state,
    required this.onRetry,
    required this.onAccept,
    required this.onReject,
  });

  final AddFriendState state;
  final VoidCallback onRetry;
  final Future<void> Function(FriendRequestEntity request) onAccept;
  final Future<void> Function(FriendRequestEntity request) onReject;

  @override
  Widget build(BuildContext context) {
    if (state.status == AddFriendStatus.loading &&
        state.incomingRequests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.incomingRequests.isEmpty) {
      return Center(
        child: TextButton(onPressed: onRetry, child: Text(state.errorMessage!)),
      );
    }
    if (state.incomingRequests.isEmpty) {
      return const Center(child: Text('No friend requests right now.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: state.incomingRequests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = state.incomingRequests[index];
        return AddFriendUserCard(
          user: AddFriendUserModel(
            name: request.fullname,
            avatarUrl:
                (request.profileUrl != null && request.profileUrl!.isNotEmpty)
                ? ApiEndpoints.profileImageUrl(request.profileUrl!)
                : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(request.fullname)}&background=E6F3DC&color=3B6D11',
            mutualFriends: 0,
            subtitle: '@${request.username}',
            isIncomingRequest: true,
          ),
          primaryLabel: 'Accept',
          secondaryLabel: 'Delete',
          onPrimaryTap: () {
            onAccept(request);
          },
          onSecondaryTap: () {
            onReject(request);
          },
        );
      },
    );
  }
}
