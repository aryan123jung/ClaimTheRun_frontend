import 'package:clain_the_run/features/message/presentation/pages/group_message_screen.dart';
import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/presentation/state/social_state.dart';
import 'package:clain_the_run/features/social/presentation/view_model/social_view_model.dart';
import 'package:clain_the_run/features/social/presentation/widgets/create_post_popup.dart';
import 'package:clain_the_run/features/social/presentation/widgets/groupcard.dart';
import 'package:clain_the_run/features/social/presentation/widgets/postcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupProfileScreen extends ConsumerStatefulWidget {
  const GroupProfileScreen({super.key, required this.group});

  final GroupEntity group;

  @override
  ConsumerState<GroupProfileScreen> createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends ConsumerState<GroupProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(socialViewModelProvider.notifier)
          .loadGroupPosts(widget.group.id, force: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(socialViewModelProvider);
    final group = _currentGroup(state) ?? widget.group;
    final posts = state.groupPostsById[group.id] ?? const [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF07111A)
          : const Color(0xFFF9FAF7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: isDark ? Colors.white : const Color(0xFF232323),
                    ),
                  ),
                  const Spacer(),
                  if (group.isJoined) ...[
                    _HeaderPillButton(
                      icon: Icons.add_rounded,
                      label: 'Add Post',
                      outlined: true,
                      compact: true,
                      onTap: () => _openCreatePost(group.id),
                    ),
                    const SizedBox(width: 12),
                  ],
                  _CircleHeaderAction(
                    icon: Icons.chat_bubble_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GroupMessageScreen(
                            groupName: group.name,
                            groupAvatarUrl: _groupImage(group),
                            memberCount: group.memberCount,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(socialViewModelProvider.notifier)
                      .loadGroupPosts(group.id, force: true);
                  await ref
                      .read(socialViewModelProvider.notifier)
                      .loadGroups(
                        search: ref.read(socialViewModelProvider).groupSearchQuery,
                        force: true,
                      );
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  children: [
                    _GroupHeroCard(
                      group: _toGroupModel(group),
                      totalPosts: posts.length,
                      onJoinToggle: () async {
                        if (group.isJoined) {
                          await ref
                              .read(socialViewModelProvider.notifier)
                              .leaveGroup(group.id);
                        } else {
                          await ref
                              .read(socialViewModelProvider.notifier)
                              .joinGroup(group.id);
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.status == SocialStatus.loading && posts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.errorMessage != null && posts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(state.errorMessage!),
                        ),
                      )
                    else if (posts.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('No group posts yet.'),
                        ),
                      )
                    else
                      for (final post in posts) ...[
                        PostCard(post: _mapPostEntityToViewModel(post)),
                        const SizedBox(height: 16),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GroupEntity? _currentGroup(SocialState state) {
    for (final group in state.groups) {
      if (group.id == widget.group.id) return group;
    }
    return null;
  }

  void _openCreatePost(String groupId) {
    showCreatePostPopup(
      context,
      onSubmit: (caption, imagePath) async {
        final success = await ref
            .read(socialViewModelProvider.notifier)
            .createPost(
              caption: caption,
              imagePath: imagePath,
              communityId: groupId,
            );
        if (success) return null;
        return ref.read(socialViewModelProvider).errorMessage ??
            'Unable to create group post';
      },
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group post uploaded successfully.')),
        );
      },
    );
  }

  GroupModel _toGroupModel(GroupEntity group) {
    return GroupModel(
      id: group.id,
      name: group.name,
      iconUrl: _groupImage(group),
      memberCount: group.memberCount,
      description: group.description,
      isJoined: group.isJoined,
    );
  }

  String _groupImage(GroupEntity group) {
    final imageUrl = group.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return imageUrl;
    }
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(group.name)}&background=E6F3DC&color=3B6D11';
  }
}

class _GroupHeroCard extends StatelessWidget {
  const _GroupHeroCard({
    required this.group,
    required this.totalPosts,
    required this.onJoinToggle,
  });

  final GroupModel group;
  final int totalPosts;
  final VoidCallback onJoinToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE8E8E4),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 88,
                height: 88,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF16222E)
                      : const Color(0xFFF5F8F2),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(group.iconUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111111),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _HeaderPillButton(
                          icon: group.isJoined
                              ? Icons.check_rounded
                              : Icons.group_add_outlined,
                          label: group.isJoined ? 'Joined' : 'Join',
                          outlined: true,
                          compact: true,
                          onTap: onJoinToggle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      group.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDark
                            ? const Color(0xFF9BA8B4)
                            : const Color(0xFF8A8A8A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16222E) : const Color(0xFFFAFAF8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF233241)
                    : const Color(0xFFEAEAE6),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _GroupStatBlock(
                    value: '${group.memberCount}',
                    label: 'Members',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: _GroupStatBlock(
                    value: group.totalKm.toStringAsFixed(0),
                    label: 'Km',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: _GroupStatBlock(
                    value: '$totalPosts',
                    label: 'Posts',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupStatBlock extends StatelessWidget {
  const _GroupStatBlock({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF9BA8B4) : const Color(0xFF8A8A8A),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF233241)
          : const Color(0xFFE7E7E2),
    );
  }
}

class _HeaderPillButton extends StatelessWidget {
  const _HeaderPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 18,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: outlined
              ? Colors.transparent
              : (isDark ? const Color(0xFF72B63E) : const Color(0xFF55A63A)),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: outlined
                ? const Color(0xFFBFDDA8)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 18 : 20,
              color: outlined
                  ? const Color(0xFF72B63E)
                  : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 14 : 15,
                fontWeight: FontWeight.w700,
                color: outlined
                    ? const Color(0xFF72B63E)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleHeaderAction extends StatelessWidget {
  const _CircleHeaderAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16222E) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF233241) : const Color(0xFFE4E4E1),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white : const Color(0xFF3B6D11),
        ),
      ),
    );
  }
}

PostModel _mapPostEntityToViewModel(PostEntity post) {
  return PostModel(
    id: post.id,
    authorName: post.author.fullname,
    authorAvatarUrl: post.author.profileUrl ?? '',
    timestamp: formatPostTimestamp(post.createdAt),
    caption: post.caption,
    imageUrl: post.imageUrl,
    likeCount: post.likeCount,
    commentCount: post.commentCount,
    isLiked: post.isLiked,
  );
}
