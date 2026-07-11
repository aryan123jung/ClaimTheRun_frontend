import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';
import 'package:clain_the_run/features/addfriend/presentation/pages/addfriendscreen.dart';
import 'package:clain_the_run/features/addfriend/presentation/pages/friend_requests_screen.dart';
import 'package:clain_the_run/features/addfriend/presentation/state/addfriend_state.dart';
import 'package:clain_the_run/features/addfriend/presentation/view_model/addfriend_view_model.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/map/data/datasources/run_api_service.dart';
import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/message/presentation/pages/group_message_screen.dart';
import 'package:clain_the_run/features/message/presentation/pages/chatscreen.dart';
import 'package:clain_the_run/features/message/presentation/pages/messagescreen.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/presentation/models/friend_profile_bundle.dart';
import 'package:clain_the_run/features/social/presentation/models/friend_run_summary.dart';
import 'package:clain_the_run/features/social/presentation/pages/friend_profile_screen.dart';
import 'package:clain_the_run/features/social/presentation/pages/group_profile_screen.dart';
import 'package:clain_the_run/features/social/presentation/pages/group_search_screen.dart';
import 'package:clain_the_run/features/social/presentation/state/social_state.dart';
import 'package:clain_the_run/features/social/presentation/view_model/social_view_model.dart';
import 'package:clain_the_run/features/social/presentation/widgets/create_group_popup.dart';
import 'package:clain_the_run/features/social/presentation/widgets/create_post_popup.dart';
import 'package:clain_the_run/features/social/presentation/widgets/friendcard.dart';
import 'package:clain_the_run/features/social/presentation/widgets/groupcard.dart';
import 'package:clain_the_run/features/social/presentation/widgets/postcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen>
    with SingleTickerProviderStateMixin {
  static const _brandGreen = Color(0xFF72B63E);
  static const _activeTextGreen = Color(0xFF3B6D11);

  late final TabController _tabController;
  final RunApiService _runApiService = RunApiService();
  Map<String, FriendRunSummary> _friendSummaries = const {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(
      () => ref.read(socialViewModelProvider.notifier).loadPosts(),
    );
    Future.microtask(
      () => ref.read(addFriendViewModelProvider.notifier).loadFriends(),
    );
    Future.microtask(
      () => ref.read(socialViewModelProvider.notifier).loadGroups(),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socialState = ref.watch(socialViewModelProvider);
    final currentUserId = ref.watch(
      authViewModelProvider.select((state) => state.authEntity?.id),
    );
    final friendState = ref.watch(addFriendViewModelProvider);
    _syncFriendSummaries(friendState.friends);
    final posts = socialState.posts
        .where(
          (post) => post.author.id != currentUserId && post.isLiked == false,
        )
        .map(_mapPostEntityToViewModel)
        .toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton(
              onPressed: () => showCreateGroupPopup(
                context,
                onSubmit: (name, description, imagePath) async {
                  final success = await ref
                      .read(socialViewModelProvider.notifier)
                      .createGroup(
                        name: name,
                        description: description,
                        imagePath: imagePath,
                      );
                  if (success) return null;
                  return ref.read(socialViewModelProvider).errorMessage ??
                      'Unable to create group';
                },
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group created successfully.'),
                    ),
                  );
                },
              ),
              backgroundColor: _brandGreen,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Social',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111111),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Connect. Share. Get inspired.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF9BA8B4)
                                : const Color(0xFF8B8B8B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _MessagesButton(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MessagesScreen(),
                        ),
                      );
                    },
                  ),
                  if (_tabController.index == 1) ...[
                    const SizedBox(width: 8),
                    _OutlinedActionButton(
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'Add Friend',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddFriendScreen(),
                          ),
                        );
                      },
                    ),
                  ] else if (_tabController.index == 2) ...[
                    const SizedBox(width: 8),
                    _OutlinedActionButton(
                      icon: Icons.search_rounded,
                      label: 'Search Groups',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const GroupSearchScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            TabBar(
              controller: _tabController,
              labelColor: _activeTextGreen,
              unselectedLabelColor: isDark
                  ? const Color(0xFF7F8E99)
                  : const Color(0xFFA7AEAA),
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              indicatorColor: _brandGreen,
              indicatorWeight: 2.5,
              dividerColor: isDark
                  ? const Color(0xFF233241)
                  : const Color(0xFFEDEDEA),
              tabs: const [
                Tab(text: 'Feed'),
                Tab(text: 'Friends'),
                Tab(text: 'Groups'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FeedTab(
                    posts: posts,
                    isLoading: socialState.status == SocialStatus.loading,
                    errorMessage: socialState.errorMessage,
                    onRetry: () {
                      ref
                          .read(socialViewModelProvider.notifier)
                          .loadPosts(force: true);
                    },
                    onCreatePost: () {
                      showCreatePostPopup(
                        context,
                        onSubmit: (caption, imagePath) async {
                          final success = await ref
                              .read(socialViewModelProvider.notifier)
                              .createPost(
                                caption: caption,
                                imagePath: imagePath,
                              );
                          if (success) return null;
                          return ref
                                  .read(socialViewModelProvider)
                                  .errorMessage ??
                              'Unable to create post';
                        },
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post uploaded successfully.'),
                            ),
                          );
                        },
                      );
                    },
                    onLike: (postId) {
                      ref
                          .read(socialViewModelProvider.notifier)
                          .toggleLike(postId);
                    },
                  ),
                  _FriendsTab(
                    friends: friendState.friends,
                    friendSummaries: _friendSummaries,
                    socialPosts: socialState.posts,
                    isLoading:
                        friendState.status == AddFriendStatus.loading &&
                        friendState.friends.isEmpty,
                    errorMessage: friendState.errorMessage,
                    onRetry: () {
                      ref
                          .read(addFriendViewModelProvider.notifier)
                          .loadFriends();
                    },
                    onRefreshFriends: () {
                      ref
                          .read(addFriendViewModelProvider.notifier)
                          .loadFriends();
                    },
                  ),
                  _GroupsTab(
                    groups: socialState.groups,
                    isLoading:
                        socialState.status == SocialStatus.loading &&
                        socialState.groups.isEmpty,
                    errorMessage: socialState.errorMessage,
                    onRetry: () {
                      ref
                          .read(socialViewModelProvider.notifier)
                          .loadGroups(force: true);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncFriendSummaries(List<FriendUserEntity> friends) {
    final friendIds = friends.map((friend) => friend.id).toSet();
    final knownIds = _friendSummaries.keys.toSet();
    if (friendIds.isEmpty) {
      if (_friendSummaries.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _friendSummaries = const {};
          });
        });
      }
      return;
    }

    if (!friendIds.difference(knownIds).isNotEmpty &&
        !knownIds.difference(friendIds).isNotEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFriendSummaries(friends);
    });
  }

  Future<void> _loadFriendSummaries(List<FriendUserEntity> friends) async {
    final activeIds = friends.map((friend) => friend.id).toSet();
    final summaries = <String, FriendRunSummary>{};

    await Future.wait(
      friends.map((friend) async {
        try {
          final runs = await _runApiService.fetchRunsByUserId(friend.id);
          summaries[friend.id] = FriendRunSummary.fromRuns(runs);
        } catch (_) {
          summaries[friend.id] = const FriendRunSummary.empty();
        }
      }),
    );

    if (!mounted) return;
    setState(() {
      _friendSummaries = {
        for (final entry in summaries.entries)
          if (activeIds.contains(entry.key)) entry.key: entry.value,
      };
    });
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.posts,
    required this.onCreatePost,
    required this.onLike,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  final List<PostModel> posts;
  final VoidCallback onCreatePost;
  final ValueChanged<String> onLike;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRetry?.call();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          _PostComposer(onTap: onCreatePost),
          const SizedBox(height: 14),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null && posts.isEmpty)
            _FeedMessageCard(
              message: errorMessage!,
              actionLabel: 'Retry',
              onTap: onRetry,
            )
          else if (posts.isEmpty)
            const _FeedMessageCard(
              message: 'No personal posts yet. Share your first run update.',
            ),
          for (final post in posts) ...[
            PostCard(post: post, onLike: () => onLike(post.id)),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  const _FriendsTab({
    required this.friends,
    required this.friendSummaries,
    required this.socialPosts,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onRefreshFriends,
  });

  final List<FriendUserEntity> friends;
  final Map<String, FriendRunSummary> friendSummaries;
  final List<PostEntity> socialPosts;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onRefreshFriends;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefreshFriends?.call();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          const _SearchField(hint: 'Search friends...'),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: Row(
              children: [
                const Text(
                  'Friends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FriendRequestsScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Friend Requests',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B6D11),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Total Friends: ${friends.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9A9A9A),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null && friends.isEmpty)
            _FeedMessageCard(
              message: errorMessage!,
              actionLabel: 'Retry',
              onTap: onRetry,
            )
          else if (friends.isEmpty)
            const _FeedMessageCard(
              message:
                  'No friends added yet. Search and add runners to see them here.',
            )
          else
            for (final friend in friends) ...[
              Builder(
                builder: (context) {
                  final cardFriend = _mapFriendUserToCard(
                    friend,
                    friendSummaries[friend.id] ??
                        const FriendRunSummary.empty(),
                  );
                  final profileBundle = _buildFriendProfileBundle(
                    friend: friend,
                    posts: socialPosts,
                    summary:
                        friendSummaries[friend.id] ??
                        const FriendRunSummary.empty(),
                  );

                  return FriendCard(
                    friend: cardFriend,
                    onMessage: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            friendId: friend.id,
                            friendName: friend.fullname,
                            friendUsername: friend.username,
                            avatarUrl: cardFriend.avatarUrl,
                          ),
                        ),
                      );
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FriendProfileScreen(
                            friend: cardFriend,
                            bio: '@${friend.username}',
                            posts: profileBundle.posts,
                            initialSummary: profileBundle.summary,
                            friendActionLabel: 'Remove Friend',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              if (friend != friends.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

FriendModel _mapFriendUserToCard(
  FriendUserEntity friend,
  FriendRunSummary summary,
) {
  return FriendModel(
    id: friend.id,
    name: friend.fullname,
    avatarUrl: (friend.profileUrl != null && friend.profileUrl!.isNotEmpty)
        ? ApiEndpoints.profileImageUrl(friend.profileUrl!)
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(friend.fullname)}&background=E6F3DC&color=3B6D11',
    totalKm: summary.totalKm,
    territories: summary.territories,
  );
}

FriendProfileBundle _buildFriendProfileBundle({
  required FriendUserEntity friend,
  required List<PostEntity> posts,
  required FriendRunSummary summary,
}) {
  final friendPosts = posts
      .where((post) => post.author.id == friend.id)
      .map(_mapPostEntityToViewModel)
      .toList();

  return FriendProfileBundle(summary: summary, posts: friendPosts);
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab({
    required this.groups,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  final List<GroupEntity> groups;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text(
                'Groups',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
              const Spacer(),
              Text(
                'Total Group: ${groups.length}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF9A9A9A)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (errorMessage != null && groups.isEmpty) {
                return _FeedMessageCard(
                  message: errorMessage!,
                  actionLabel: 'Retry',
                  onTap: onRetry,
                );
              }
              if (groups.isEmpty) {
                return const _FeedMessageCard(
                  message:
                      'No joined groups yet. Search and join groups to see them here.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: groups.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final groupCard = _mapGroupEntityToCard(group);

                  return GroupCard(
                    group: groupCard,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              GroupProfileScreen(group: group),
                        ),
                      );
                    },
                    onMessage: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GroupMessageScreen(
                            communityId: group.id,
                            groupName: group.name,
                            groupAvatarUrl: groupCard.iconUrl,
                            memberCount: group.memberCount,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PostComposer extends StatelessWidget {
  const _PostComposer({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFEDEDEA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B2732)
                      : const Color(0xFFF7F7F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  "What's on your run today?",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF9BA8B4)
                        : const Color(0xFF9A9A9A),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1B2732)
                    : const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.image_outlined,
                size: 19,
                color: isDark
                    ? const Color(0xFF9BA8B4)
                    : const Color(0xFF6E6E6E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedMessageCard extends StatelessWidget {
  const _FeedMessageCard({required this.message, this.actionLabel, this.onTap});

  final String message;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFEDEDEA),
        ),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFB3BEC8) : const Color(0xFF4D4D4D),
            ),
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onTap, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE4E4E1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF9BA8B4)
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
          Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? const Color(0xFF9BA8B4) : const Color(0xFF9A9A9A),
          ),
        ],
      ),
    );
  }
}

GroupModel _mapGroupEntityToCard(GroupEntity group) {
  final imageUrl = (group.imageUrl != null && group.imageUrl!.isNotEmpty)
      ? ApiEndpoints.uploadUrl(group.imageUrl!)
      : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(group.name)}&background=E6F3DC&color=3B6D11';

  return GroupModel(
    id: group.id,
    name: group.name,
    iconUrl: imageUrl,
    memberCount: group.memberCount,
    description: group.description,
    isJoined: group.isJoined,
  );
}

class _MessagesButton extends StatelessWidget {
  const _MessagesButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF72B63E).withValues(alpha: 0.6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(11),
          child: Icon(Icons.chat_bubble_rounded, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  static const _activeTextGreen = Color(0xFF3B6D11);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _activeTextGreen.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: _activeTextGreen),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _activeTextGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PostModel _mapPostEntityToViewModel(PostEntity post) {
  final avatarUrl =
      (post.author.profileUrl != null && post.author.profileUrl!.isNotEmpty)
      ? ApiEndpoints.profileImageUrl(post.author.profileUrl!)
      : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(post.author.fullname)}&background=E6F3DC&color=3B6D11';

  return PostModel(
    id: post.id,
    authorName: post.author.fullname,
    authorAvatarUrl: avatarUrl,
    timestamp: formatPostTimestamp(post.createdAt),
    caption: post.caption,
    imageUrl: post.imageUrl,
    likeCount: post.likeCount,
    commentCount: post.commentCount,
    isLiked: post.isLiked,
  );
}
