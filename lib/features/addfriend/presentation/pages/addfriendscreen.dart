import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';
import 'package:clain_the_run/features/addfriend/presentation/pages/friend_requests_screen.dart';
import 'package:clain_the_run/features/addfriend/presentation/state/addfriend_state.dart';
import 'package:clain_the_run/features/addfriend/presentation/view_model/addfriend_view_model.dart';
import 'package:clain_the_run/features/addfriend/presentation/widgets/add_friend_user_card.dart';
import 'package:clain_the_run/features/social/presentation/models/friend_run_summary.dart';
import 'package:clain_the_run/features/social/presentation/pages/friend_profile_screen.dart';
import 'package:clain_the_run/features/social/presentation/widgets/friendcard.dart';
import 'package:clain_the_run/features/social/presentation/widgets/postcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(addFriendViewModelProvider.notifier).loadFriends(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(addFriendViewModelProvider);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF07111A)
          : const Color(0xFFF9FAF7),
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
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: isDark ? Colors.white : const Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      'Add Friends',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'Find runners you know and grow your crew.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF9BA8B4)
                      : const Color(0xFF707070),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _AddFriendSearchField(
                controller: _searchController,
                onChanged: (value) {
                  ref
                      .read(addFriendViewModelProvider.notifier)
                      .searchUsers(value);
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _AddFriendBody(
                state: state,
                onRetry: () {
                  ref
                      .read(addFriendViewModelProvider.notifier)
                      .searchUsers(_searchController.text);
                },
                onPrimaryAction: (user) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final notifier = ref.read(
                    addFriendViewModelProvider.notifier,
                  );
                  final message = switch (user.friendStatus) {
                    'PENDING_OUTGOING' => await notifier.cancelRequest(user),
                    'FRIEND' => await notifier.unfriend(user),
                    _ => await notifier.sendRequest(user),
                  };
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        message ??
                            switch (user.friendStatus) {
                              'PENDING_OUTGOING' => 'Friend request cancelled.',
                              'FRIEND' => 'Friend removed successfully.',
                              _ => 'Friend request sent.',
                            },
                      ),
                    ),
                  );
                },
                onOpenProfile: (user, avatarUrl) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FriendProfileScreen(
                        friend: FriendModel(
                          id: user.id,
                          name: user.fullname,
                          avatarUrl: avatarUrl,
                          totalKm: 0,
                          territories: 0,
                        ),
                        bio: '@${user.username}',
                        initialSummary: const FriendRunSummary.empty(),
                        posts: const <PostModel>[],
                        friendActionLabel: switch (user.friendStatus) {
                          'FRIEND' => 'Remove Friend',
                          'PENDING_OUTGOING' => 'Cancel Request',
                          'NONE' => 'Add Friend',
                          _ => null,
                        },
                        onFriendAction: (currentLabel) async {
                          final notifier = ref.read(
                            addFriendViewModelProvider.notifier,
                          );
                          return switch (currentLabel) {
                            'Remove Friend' => await notifier.unfriend(user),
                            'Cancel Request' => await notifier.cancelRequest(
                              user,
                            ),
                            'Add Friend' => await notifier.sendRequest(user),
                            _ => null,
                          };
                        },
                      ),
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

class _AddFriendBody extends StatelessWidget {
  const _AddFriendBody({
    required this.state,
    required this.onRetry,
    required this.onPrimaryAction,
    required this.onOpenProfile,
  });

  final AddFriendState state;
  final VoidCallback onRetry;
  final Future<void> Function(FriendUserEntity user) onPrimaryAction;
  final void Function(FriendUserEntity user, String avatarUrl) onOpenProfile;

  @override
  Widget build(BuildContext context) {
    if (state.status == AddFriendStatus.loading &&
        state.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.searchResults.isEmpty) {
      return _InfoPanel(
        message: state.errorMessage!,
        actionLabel: 'Retry',
        onTap: onRetry,
      );
    }

    if (state.searchResults.isEmpty) {
      return _InfoPanel(
        message: state.searchText.trim().isEmpty
            ? 'Start typing a name or username to see suggestions.'
            : 'No runners found yet. Try a different name or username.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: state.searchResults.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = state.searchResults[index];
        final uiModel = AddFriendUserModel(
          name: user.fullname,
          avatarUrl: (user.profileUrl != null && user.profileUrl!.isNotEmpty)
              ? ApiEndpoints.profileImageUrl(user.profileUrl!)
              : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullname)}&background=E6F3DC&color=3B6D11',
          mutualFriends: user.mutualFriends,
          subtitle: '@${user.username}',
          isIncomingRequest: user.friendStatus == 'PENDING_INCOMING',
        );

        return AddFriendUserCard(
          user: uiModel,
          onTap: () {
            onOpenProfile(user, uiModel.avatarUrl);
          },
          primaryLabel: _primaryLabel(user.friendStatus),
          onPrimaryTap: () {
            onPrimaryAction(user);
          },
          secondaryLabel: user.friendStatus == 'PENDING_INCOMING'
              ? 'Open Requests'
              : null,
          onSecondaryTap: user.friendStatus == 'PENDING_INCOMING'
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FriendRequestsScreen(),
                    ),
                  );
                }
              : null,
        );
      },
    );
  }

  String _primaryLabel(String friendStatus) {
    switch (friendStatus) {
      case 'PENDING_OUTGOING':
        return 'Cancel';
      case 'PENDING_INCOMING':
        return 'Pending';
      case 'FRIEND':
        return 'Remove';
      default:
        return 'Add Friend';
    }
  }
}

class _AddFriendSearchField extends StatelessWidget {
  const _AddFriendSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFDADAD6),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? const Color(0xFF8FA0AE) : const Color(0xFF9A9A9A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search by name or username',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF8FA0AE)
                      : const Color(0xFF9A9A9A),
                ),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.message, this.actionLabel, this.onTap});

  final String message;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onTap != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onTap, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
