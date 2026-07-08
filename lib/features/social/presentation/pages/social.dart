import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/addfriend/presentation/pages/addfriendscreen.dart';
import 'package:clain_the_run/features/addfriend/presentation/pages/friend_requests_screen.dart';
import 'package:clain_the_run/features/message/presentation/pages/group_message_screen.dart';
import 'package:clain_the_run/features/message/presentation/pages/messagescreen.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/presentation/pages/friend_profile_screen.dart';
import 'package:clain_the_run/features/social/presentation/pages/group_profile_screen.dart';
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

  final List<FriendModel> _friends = const [
    FriendModel(
      name: 'Ram Khadka',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      totalKm: 500,
      territories: 12,
    ),
    FriendModel(
      name: 'Aarav Sharma',
      avatarUrl: 'https://i.pravatar.cc/150?img=13',
      totalKm: 102,
      territories: 8,
    ),
    FriendModel(
      name: 'Riya Thapa',
      avatarUrl: 'https://i.pravatar.cc/150?img=26',
      totalKm: 600,
      territories: 2,
    ),
    FriendModel(
      name: 'Kiran Gurung',
      avatarUrl: 'https://i.pravatar.cc/150?img=14',
      totalKm: 99,
      territories: 8,
    ),
    FriendModel(
      name: 'Anjali Rai',
      avatarUrl: 'https://i.pravatar.cc/150?img=27',
      totalKm: 1102,
      territories: 1,
    ),
  ];

  final List<GroupModel> _groups = const [
    GroupModel(
      name: 'The Runners',
      iconUrl: 'https://i.pravatar.cc/100?img=41',
      memberCount: 8,
      totalKm: 512,
    ),
    GroupModel(
      name: 'Ultimate Runners',
      iconUrl: 'https://i.pravatar.cc/100?img=42',
      memberCount: 11,
      totalKm: 1012,
    ),
    GroupModel(
      name: 'Motivated Boys',
      iconUrl: 'https://i.pravatar.cc/100?img=43',
      memberCount: 3,
      totalKm: 112,
    ),
    GroupModel(
      name: 'Lost In Pace',
      iconUrl: 'https://i.pravatar.cc/100?img=44',
      memberCount: 14,
      totalKm: 2312,
    ),
    GroupModel(
      name: 'Wonder Women',
      iconUrl: 'https://i.pravatar.cc/100?img=45',
      memberCount: 2,
      totalKm: 812,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(
      () => ref.read(socialViewModelProvider.notifier).loadPosts(),
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
    final posts = socialState.posts.map(_mapPostEntityToViewModel).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                      icon: Icons.group_add_rounded,
                      label: 'Create Group',
                      onTap: () => showCreateGroupPopup(context),
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
                      ref.read(socialViewModelProvider.notifier).loadPosts();
                    },
                    onCreatePost: () {
                      showCreatePostPopup(
                        context,
                        onSubmit: (caption, imageUrl) async {
                          final success = await ref
                              .read(socialViewModelProvider.notifier)
                              .createPost(caption: caption, imageUrl: imageUrl);
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
                  _FriendsTab(friends: _friends),
                  _GroupsTab(groups: _groups),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    return ListView(
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
    );
  }
}

class _FriendsTab extends StatelessWidget {
  const _FriendsTab({required this.friends});

  final List<FriendModel> friends;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: _SearchField(hint: 'Search friends...'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                style: const TextStyle(fontSize: 13, color: Color(0xFF9A9A9A)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: friends.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final friend = friends[index];

              return FriendCard(
                friend: friend,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FriendProfileScreen(
                        friend: friend,
                        bio: _friendBio(friend.name),
                        totalRuns: _friendRuns(friend.name),
                        postCount: _friendPosts(friend.name).length,
                        posts: _friendPosts(friend.name),
                      ),
                    ),
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

String _friendBio(String friendName) {
  switch (friendName) {
    case 'Ram Khadka':
      return 'Just chilllll guysss';
    case 'Aarav Sharma':
      return 'Always down for an early morning run.';
    case 'Riya Thapa':
      return 'Coffee, cardio, and chasing better pace.';
    case 'Kiran Gurung':
      return 'Territory hunter and weekend long-run specialist.';
    case 'Anjali Rai':
      return 'Running helps me reset and refocus.';
    default:
      return 'Runner. Explorer. Teammate.';
  }
}

int _friendRuns(String friendName) {
  switch (friendName) {
    case 'Ram Khadka':
      return 20;
    case 'Aarav Sharma':
      return 16;
    case 'Riya Thapa':
      return 24;
    case 'Kiran Gurung':
      return 18;
    case 'Anjali Rai':
      return 29;
    default:
      return 12;
  }
}

List<PostModel> _friendPosts(String friendName) {
  switch (friendName) {
    case 'Ram Khadka':
      return const [
        PostModel(
          id: 'friend-ram-1',
          authorName: 'Ram Khadka',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=12',
          timestamp: 'Today, 7:15 AM',
          caption: "How's the view???",
          imageUrl:
              'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
          likeCount: 23,
          commentCount: 23,
        ),
        PostModel(
          id: 'friend-ram-2',
          authorName: 'Ram Khadka',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=12',
          timestamp: 'Today, 7:15 AM',
          caption: 'Recovery jog done. Feeling fresh for tomorrow.',
          likeCount: 11,
          commentCount: 6,
        ),
      ];
    case 'Aarav Sharma':
      return const [
        PostModel(
          id: 'friend-aarav-1',
          authorName: 'Aarav Sharma',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=13',
          timestamp: 'Today, 6:45 AM',
          caption: 'Quick speed session before class.',
          likeCount: 9,
          commentCount: 4,
        ),
      ];
    case 'Riya Thapa':
      return const [
        PostModel(
          id: 'friend-riya-1',
          authorName: 'Riya Thapa',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=26',
          timestamp: 'Yesterday, 7:20 AM',
          caption: 'Morning run around the lake',
          imageUrl:
              'https://images.unsplash.com/photo-1502904550040-7534597429ae?w=800',
          likeCount: 14,
          commentCount: 6,
        ),
      ];
    default:
      return const [
        PostModel(
          id: 'friend-default-1',
          authorName: 'Friend Post',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=30',
          timestamp: 'Today',
          caption: 'Another good day to run.',
          likeCount: 4,
          commentCount: 1,
        ),
      ];
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab({required this.groups});

  final List<GroupModel> groups;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: _SearchField(hint: 'Search groups...'),
        ),
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
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: groups.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final group = groups[index];

              return GroupCard(
                group: group,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GroupProfileScreen(
                        group: group,
                        description: _groupDescription(group.name),
                        postCount: _groupPosts(group.name).length,
                        posts: _groupPosts(group.name),
                      ),
                    ),
                  );
                },
                onMessage: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GroupMessageScreen(
                        groupName: group.name,
                        groupAvatarUrl: group.iconUrl,
                        memberCount: group.memberCount,
                      ),
                    ),
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

String _groupDescription(String groupName) {
  switch (groupName) {
    case 'The Runners':
      return 'Feel free to explore with us. We run, share routes, and push each other forward.';
    case 'Ultimate Runners':
      return 'Built for runners who love consistency, long miles, and weekend challenges together.';
    case 'Motivated Boys':
      return 'A small but relentless crew focused on staying accountable and getting stronger.';
    case 'Lost In Pace':
      return 'From easy jogs to hard efforts, this group is all about finding your rhythm.';
    case 'Wonder Women':
      return 'Supportive, strong, and always moving. A space for uplifting every member on the run.';
    default:
      return 'Run farther together and keep each other moving.';
  }
}

List<PostModel> _groupPosts(String groupName) {
  switch (groupName) {
    case 'The Runners':
      return const [
        PostModel(
          id: 'group-runners-1',
          authorName: 'Aryan Jung Chhetri',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=11',
          timestamp: 'Today, 7:15 AM',
          caption: "How's the view???",
          imageUrl:
              'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
          likeCount: 7,
          commentCount: 2,
        ),
        PostModel(
          id: 'group-runners-2',
          authorName: 'Anjali Khadka',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=25',
          timestamp: 'Yesterday, 7:15 AM',
          caption: 'Just ran a 10km run!',
          likeCount: 2,
          commentCount: 5,
        ),
        PostModel(
          id: 'group-runners-3',
          authorName: 'Riya Kapoor',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=26',
          timestamp: 'May 17, 7:15 AM',
          caption: 'Morning run around the lake',
          imageUrl:
              'https://images.unsplash.com/photo-1502904550040-7534597429ae?w=800',
          likeCount: 9,
          commentCount: 4,
        ),
      ];
    case 'Ultimate Runners':
      return const [
        PostModel(
          id: 'group-ultimate-1',
          authorName: 'Ram Khadka',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=12',
          timestamp: 'Today, 6:10 AM',
          caption: 'Sunrise tempo run with the crew.',
          imageUrl:
              'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?w=800',
          likeCount: 11,
          commentCount: 3,
        ),
      ];
    case 'Motivated Boys':
      return const [
        PostModel(
          id: 'group-motivated-1',
          authorName: 'Aarav Sharma',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=13',
          timestamp: 'Today, 8:04 AM',
          caption: 'No excuses today. Hill repeats done.',
          likeCount: 5,
          commentCount: 1,
        ),
      ];
    default:
      return const [
        PostModel(
          id: 'group-default-1',
          authorName: 'Group Admin',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=18',
          timestamp: 'Today',
          caption: 'Welcome to the group. More updates coming soon.',
          likeCount: 3,
          commentCount: 0,
        ),
      ];
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
