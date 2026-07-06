import 'package:clain_the_run/features/social/presentation/pages/group_profile_screen.dart';
import 'package:clain_the_run/features/message/presentation/pages/messagescreen.dart';
import 'package:clain_the_run/features/social/presentation/widgets/friendcard.dart';
import 'package:clain_the_run/features/social/presentation/widgets/groupcard.dart';
import 'package:clain_the_run/features/social/presentation/widgets/postcard.dart';
import 'package:flutter/material.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  static const _brandGreen = Color(0xFF72B63E);
  static const _activeTextGreen = Color(0xFF3B6D11);

  late final TabController _tabController;

  // Placeholder data — replace with real data from your backend/provider.
  final List<PostModel> _posts = const [
    PostModel(
      authorName: 'Aryan Jung Chhetri',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=11',
      timestamp: 'Today, 7:15 AM',
      caption: "How's the view???",
      imageUrl:
          'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
      likeCount: 23,
      commentCount: 23,
    ),
    PostModel(
      authorName: 'Riya Kapoor',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=25',
      timestamp: 'Today, 7:15 AM',
      caption: 'Morning run around the lake',
      imageUrl:
          'https://images.unsplash.com/photo-1502904550040-7534597429ae?w=800',
      likeCount: 23,
      commentCount: 23,
    ),
  ];

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
    _tabController.addListener(() {
      // Rebuild so the header action button (message / add friend /
      // create group) updates as the selected tab changes.
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
    return Scaffold(
      backgroundColor: Colors.white,
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
                        const Text(
                          'Social',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Connect. Share. Get inspired.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8B8B8B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _MessagesButton(
                    onTap: () {
                      Navigator.push(
                        context,
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
                      onTap: () {},
                    ),
                  ] else if (_tabController.index == 2) ...[
                    const SizedBox(width: 8),
                    _OutlinedActionButton(
                      icon: Icons.group_add_rounded,
                      label: 'Create Group',
                      onTap: () {},
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            TabBar(
              controller: _tabController,
              labelColor: _activeTextGreen,
              unselectedLabelColor: const Color(0xFFA7AEAA),
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
              dividerColor: const Color(0xFFEDEDEA),
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
                  _FeedTab(posts: _posts),
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
  const _FeedTab({required this.posts});

  final List<PostModel> posts;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      children: [
        const _PostComposer(),
        const SizedBox(height: 14),
        for (final post in posts) ...[
          PostCard(post: post),
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
              return FriendCard(friend: friends[index]);
            },
          ),
        ),
      ],
    );
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
          authorName: 'Anjali Khadka',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=25',
          timestamp: 'Yesterday, 7:15 AM',
          caption: 'Just ran a 10km run!',
          likeCount: 2,
          commentCount: 5,
        ),
        PostModel(
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
  const _PostComposer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEDEA)),
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
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                "What's on your run today?",
                style: TextStyle(fontSize: 13, color: Color(0xFF9A9A9A)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 19,
              color: Color(0xFF6E6E6E),
            ),
          ),
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
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFE4E4E1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9A9A9A),
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Icon(Icons.search_rounded, size: 20, color: Color(0xFF9A9A9A)),
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
