import 'package:clain_the_run/features/message/presentation/pages/chatscreen.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/profilestattile.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/statsheet.dart';
import 'package:clain_the_run/features/social/presentation/view_model/friend_profile_view_model.dart';
import 'package:clain_the_run/features/social/presentation/widgets/friendcard.dart';
import 'package:clain_the_run/features/social/presentation/widgets/postcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendProfileScreen extends ConsumerStatefulWidget {
  const FriendProfileScreen({
    super.key,
    required this.friend,
    required this.posts,
    this.bio = 'Just chilllll guysss',
    this.totalRuns = 20,
    this.postCount = 1,
    this.friendActionLabel,
    this.onFriendAction,
  });

  final FriendModel friend;
  final List<PostModel> posts;
  final String bio;
  final int totalRuns;
  final int postCount;
  final String? friendActionLabel;
  final Future<String?> Function(String currentLabel)? onFriendAction;

  @override
  ConsumerState<FriendProfileScreen> createState() =>
      _FriendProfileScreenState();
}

class _FriendProfileScreenState extends ConsumerState<FriendProfileScreen> {
  late final FriendProfileViewModel _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(friendProfileViewModelProvider.notifier);
    Future<void>.microtask(_initializeProvider);
  }

  @override
  void didUpdateWidget(covariant FriendProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.friend.id != widget.friend.id ||
        oldWidget.friendActionLabel != widget.friendActionLabel) {
      Future<void>.microtask(_initializeProvider);
    }
  }

  void _initializeProvider() {
    _notifier.ensureInitialized(
      friendId: widget.friend.id,
      actionLabel: widget.friendActionLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendProfileViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = [
      ProfileStatModel(
        icon: Icons.show_chart_rounded,
        iconColor: const Color(0xFF72B63E),
        value: widget.friend.totalKm.toStringAsFixed(1),
        label: 'Total Km',
      ),
      const ProfileStatModel(
        icon: Icons.timer_outlined,
        iconColor: Color(0xFF3D6FE0),
        value: '24:36:14',
        label: 'Total Time',
      ),
      const ProfileStatModel(
        icon: Icons.speed_rounded,
        iconColor: Color(0xFFB6A72E),
        value: "6'21\"",
        label: 'Avg Pace',
      ),
      const ProfileStatModel(
        icon: Icons.local_fire_department_rounded,
        iconColor: Color(0xFFE08A2E),
        value: '19,860',
        label: 'Calories',
      ),
      ProfileStatModel(
        icon: Icons.directions_run_rounded,
        iconColor: const Color(0xFFB03A3A),
        value: '${widget.totalRuns}',
        label: 'Total Runs',
      ),
    ];

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
                  _HeaderMessageButton(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            friendId: widget.friend.id,
                            friendName: widget.friend.name,
                            friendUsername: widget.bio.replaceFirst('@', ''),
                            avatarUrl: widget.friend.avatarUrl,
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
                onRefresh: _notifier.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  children: [
                    _FriendHeroCard(
                      friend: widget.friend,
                      bio: widget.bio,
                      totalRuns: widget.totalRuns,
                      postCount: widget.postCount,
                      actionLabel: state.actionLabel,
                      isSubmitting: state.isSubmitting,
                      onFriendAction:
                          state.actionLabel == null ||
                              widget.onFriendAction == null
                          ? null
                          : () async {
                              final successMessage = await _notifier
                                  .submitAction(widget.onFriendAction!);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(successMessage)),
                              );
                            },
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'My Stats',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111111),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                showAllStatsSheet(context, stats: stats),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'See more',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3B6D11),
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: Color(0xFF3B6D11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StatsCard(stats: stats.sublist(0, 3)),
                    const SizedBox(height: 22),
                    Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final post in widget.posts) ...[
                      PostCard(post: post),
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
}

class _FriendHeroCard extends StatelessWidget {
  const _FriendHeroCard({
    required this.friend,
    required this.bio,
    required this.totalRuns,
    required this.postCount,
    this.actionLabel,
    this.isSubmitting = false,
    this.onFriendAction,
  });

  final FriendModel friend;
  final String bio;
  final int totalRuns;
  final int postCount;
  final String? actionLabel;
  final bool isSubmitting;
  final VoidCallback? onFriendAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE8E8E4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(friend.avatarUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bio,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: isDark
                            ? const Color(0xFF9BA8B4)
                            : const Color(0xFF8A8A8A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (actionLabel != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: _OutlineActionButton(
                          icon: _iconForAction(actionLabel!),
                          label: isSubmitting ? 'Please wait...' : actionLabel!,
                          onTap: isSubmitting ? null : onFriendAction,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16222E) : const Color(0xFFFAFAF8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF233241)
                    : const Color(0xFFEAEAE6),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroStat(value: '$totalRuns', label: 'Runs'),
                ),
                const _HeroStatDivider(),
                Expanded(
                  child: _HeroStat(
                    value: '${friend.territories}',
                    label: 'Territories',
                  ),
                ),
                const _HeroStatDivider(),
                Expanded(
                  child: _HeroStat(value: '$postCount', label: 'Posts'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForAction(String label) {
    switch (label) {
      case 'Add Friend':
        return Icons.person_add_alt_1_outlined;
      case 'Cancel Request':
        return Icons.person_off_outlined;
      default:
        return Icons.person_remove_alt_1_outlined;
    }
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final List<ProfileStatModel> stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFD8D8D5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++)
            ProfileStatTile(stat: stats[i], showDivider: i != stats.length - 1),
        ],
      ),
    );
  }
}

class _HeaderMessageButton extends StatelessWidget {
  const _HeaderMessageButton({this.onTap});

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

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF72B63E), width: 1.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF4B9E2C)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF7FD851)
                      : const Color(0xFF4B9E2C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

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
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? const Color(0xFF8FA0AE) : const Color(0xFF909090),
          ),
        ),
      ],
    );
  }
}

class _HeroStatDivider extends StatelessWidget {
  const _HeroStatDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 44,
      color: isDark ? const Color(0xFF233241) : const Color(0xFFE3E3E0),
    );
  }
}
