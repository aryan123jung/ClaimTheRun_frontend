import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';
import 'package:clain_the_run/features/addfriend/domain/usecases/search_users_usecase.dart';
import 'package:clain_the_run/features/auth/domain/entities/auth_entity.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/leaderboard/presentation/widgets/card.dart';
import 'package:clain_the_run/features/map/data/datasources/run_api_service.dart';
import 'package:clain_the_run/features/profile/presentation/pages/profile.dart';
import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/domain/usecases/get_groups_usecase.dart';
import 'package:clain_the_run/features/social/presentation/models/friend_run_summary.dart';
import 'package:clain_the_run/features/social/presentation/pages/friend_profile_screen.dart';
import 'package:clain_the_run/features/social/presentation/pages/group_profile_screen.dart';
import 'package:clain_the_run/features/social/presentation/widgets/friendcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LeaderboardScope { global, friends }

enum LeaderboardMode { solo, group }

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  static const _brandGreen = Color(0xFF72B63E);
  static const _activeTextGreen = Color(0xFF3B6D11);

  final RunApiService _runApiService = RunApiService();

  LeaderboardScope _scope = LeaderboardScope.global;
  LeaderboardMode _mode = LeaderboardMode.solo;
  bool _isLoading = true;
  String? _errorMessage;
  List<LeaderboardEntry> _entries = const [];
  List<GroupLeaderboardEntry> _groupEntries = const [];
  List<LeaderboardEntry> _friendEntries = const [];
  Map<String, FriendUserEntity> _usersByUsername = const {};
  Map<String, GroupEntity> _groupsById = const {};
  Map<String, GroupEntity> _groupsByName = const {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadLeaderboard);
  }

  Future<void> _loadLeaderboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final currentUser = ref.read(authViewModelProvider).authEntity;
      final searchUsers = ref.read(searchUsersUsecaseProvider);
      final getGroups = ref.read(getGroupsUsecaseProvider);

      final usersResult = await searchUsers(
        const SearchUsersParams(search: ''),
      );
      final groupsResult = await getGroups();

      final users = usersResult.fold(
        (_) => <FriendUserEntity>[],
        (data) => data,
      );
      final groups = groupsResult.fold((_) => <GroupEntity>[], (data) => data);

      final globalEntries = await _buildRunnerEntries(
        currentUser: currentUser,
        users: users,
        includeCurrentUser: true,
      );
      final friendEntries = await _buildRunnerEntries(
        currentUser: currentUser,
        users: users.where((user) => user.friendStatus == 'FRIEND').toList(),
        includeCurrentUser: true,
      );
      final groupEntries = _buildGroupEntries(groups);

      if (!mounted) return;
      setState(() {
        _entries = globalEntries;
        _friendEntries = friendEntries;
        _groupEntries = groupEntries;
        _usersByUsername = {
          for (final user in users)
            if (user.username.trim().isNotEmpty) user.username.trim(): user,
        };
        _groupsById = {for (final group in groups) group.id: group};
        _groupsByName = {
          for (final group in groups)
            if (group.name.trim().isNotEmpty) group.name.trim(): group,
        };
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  List<_RunnerSeed> seedsFrom(
    AuthEntity? currentUser,
    List<FriendUserEntity> users,
  ) {
    final seeds = <String, _RunnerSeed>{};

    if (currentUser?.id != null) {
      seeds[currentUser!.id!] = _RunnerSeed(
        id: currentUser.id!,
        fullname: currentUser.fullname,
        username: currentUser.username,
        profileUrl: currentUser.profileUrl,
        isCurrentUser: true,
      );
    }

    for (final user in users) {
      seeds[user.id] = _RunnerSeed(
        id: user.id,
        fullname: user.fullname,
        username: user.username,
        profileUrl: user.profileUrl,
        isCurrentUser: currentUser?.id == user.id,
      );
    }

    return seeds.values.toList();
  }

  Future<List<LeaderboardEntry>> _buildRunnerEntries({
    required AuthEntity? currentUser,
    required List<FriendUserEntity> users,
    required bool includeCurrentUser,
  }) async {
    final seeds = <String, _RunnerSeed>{};

    if (includeCurrentUser && currentUser?.id != null) {
      seeds[currentUser!.id!] = _RunnerSeed(
        id: currentUser.id!,
        fullname: currentUser.fullname,
        username: currentUser.username,
        profileUrl: currentUser.profileUrl,
        isCurrentUser: true,
      );
    }

    for (final user in users) {
      seeds[user.id] = _RunnerSeed(
        id: user.id,
        fullname: user.fullname,
        username: user.username,
        profileUrl: user.profileUrl,
        isCurrentUser: currentUser?.id == user.id,
      );
    }

    final items = await Future.wait(
      seeds.values.map((seed) async {
        final runs = seed.isCurrentUser
            ? await _runApiService.fetchMyRuns()
            : await _runApiService.fetchRunsByUserId(seed.id);
        return MapEntry(seed, FriendRunSummary.fromRuns(runs));
      }),
    );

    final entries =
        items
            .map(
              (item) => _RunnerAggregate(
                name: item.key.fullname.trim().isEmpty
                    ? item.key.username
                    : item.key.fullname,
                id: item.key.id,
                username: item.key.username,
                avatarUrl: _resolveProfileUrl(
                  item.key.profileUrl,
                  item.key.fullname,
                  item.key.username,
                ),
                distanceKm: item.value.totalKm,
                time: item.value.totalTime,
                totalRuns: item.value.totalRuns,
                territories: item.value.territories,
                isCurrentUser: item.key.isCurrentUser,
              ),
            )
            .toList()
          ..sort((a, b) {
            final distanceCompare = b.distanceKm.compareTo(a.distanceKm);
            if (distanceCompare != 0) return distanceCompare;
            final territoryCompare = b.territories.compareTo(a.territories);
            if (territoryCompare != 0) return territoryCompare;
            return b.totalRuns.compareTo(a.totalRuns);
          });

    return List<LeaderboardEntry>.generate(
      entries.length,
      (index) => LeaderboardEntry(
        id: entries[index].id,
        rank: index + 1,
        name: entries[index].name,
        username: entries[index].username,
        avatarUrl: entries[index].avatarUrl,
        distanceKm: entries[index].distanceKm,
        time: entries[index].time,
        isCurrentUser: entries[index].isCurrentUser,
      ),
    );
  }

  List<GroupLeaderboardEntry> _buildGroupEntries(List<GroupEntity> groups) {
    final rankedGroups = groups.toList()
      ..sort((a, b) {
        final memberCompare = b.memberCount.compareTo(a.memberCount);
        if (memberCompare != 0) return memberCompare;
        return a.createdAt.compareTo(b.createdAt);
      });

    return List<GroupLeaderboardEntry>.generate(rankedGroups.length, (index) {
      final group = rankedGroups[index];
      return GroupLeaderboardEntry(
        id: group.id,
        rank: index + 1,
        name: group.name,
        avatarUrl: _resolveGroupUrl(group.imageUrl, group.name),
        membersCount: group.memberCount,
        distanceKm: group.memberCount.toDouble(),
        time: _groupSubtitle(group),
      );
    });
  }

  String _resolveProfileUrl(String? raw, String fullname, String username) {
    if (raw != null && raw.trim().isNotEmpty) {
      return ApiEndpoints.profileImageUrl(raw);
    }
    final fallbackName = fullname.trim().isNotEmpty ? fullname : username;
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fallbackName)}&background=E6F3DC&color=3B6D11';
  }

  String _resolveGroupUrl(String? raw, String groupName) {
    if (raw != null && raw.trim().isNotEmpty) {
      return ApiEndpoints.uploadUrl(raw);
    }
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(groupName)}&background=E6F3DC&color=3B6D11';
  }

  String _groupSubtitle(GroupEntity group) {
    if (group.description.trim().isNotEmpty) {
      return group.description.trim();
    }
    return '@${group.creator.username}';
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Compete, improve, be the best',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF9BA8B4)
                          : const Color(0xFF8B8B8B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SegmentedToggle<LeaderboardScope>(
                    height: 40,
                    value: _scope,
                    onChanged: (value) => setState(() {
                      _scope = value;
                      if (value == LeaderboardScope.friends) {
                        _mode = LeaderboardMode.solo;
                      }
                    }),
                    options: const [
                      _SegmentOption(
                        value: LeaderboardScope.global,
                        icon: Icons.public_rounded,
                        label: 'Global',
                      ),
                      _SegmentOption(
                        value: LeaderboardScope.friends,
                        icon: Icons.people_outline_rounded,
                        label: 'Friends',
                      ),
                    ],
                    activeColor: _activeTextGreen,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _scope == LeaderboardScope.global
                        ? SizedBox(
                            width: 150,
                            child: _SegmentedToggle<LeaderboardMode>(
                              height: 34,
                              value: _mode,
                              onChanged: (value) =>
                                  setState(() => _mode = value),
                              compact: true,
                              activeColor: Colors.white,
                              activeBackground: _brandGreen,
                              options: const [
                                _SegmentOption(
                                  value: LeaderboardMode.solo,
                                  label: 'Solo',
                                ),
                                _SegmentOption(
                                  value: LeaderboardMode.group,
                                  label: 'Group',
                                ),
                              ],
                            ),
                          )
                        : const _SoloOnlyChip(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? _LeaderboardErrorView(
                      message: _errorMessage!,
                      onRetry: _loadLeaderboard,
                    )
                  : _scope == LeaderboardScope.global
                  ? _GlobalLeaderboardView(
                      mode: _mode,
                      entries: _entries,
                      groupEntries: _groupEntries,
                      onUserTap: _openUserProfile,
                      onGroupTap: _openGroupProfile,
                    )
                  : _FriendsLeaderboardView(
                      entries: _friendEntries,
                      onUserTap: _openUserProfile,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUserProfile(LeaderboardEntry entry) async {
    if (entry.isCurrentUser) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
      return;
    }

    final user = _usersByUsername[entry.username.trim()];
    if (user == null) return;

    final friend = FriendModel(
      id: user.id,
      name: user.fullname,
      avatarUrl: entry.avatarUrl,
      totalKm: entry.distanceKm,
      territories: 0,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FriendProfileScreen(
          friend: friend,
          bio: '@${user.username}',
          posts: const [],
          initialSummary: const FriendRunSummary.empty(),
          friendActionLabel: switch (user.friendStatus) {
            'FRIEND' => 'Remove Friend',
            'PENDING_OUTGOING' => 'Cancel Request',
            'NONE' => 'Add Friend',
            _ => null,
          },
        ),
      ),
    );
  }

  Future<void> _openGroupProfile(GroupLeaderboardEntry entry) async {
    final group = _groupsById[entry.id] ?? _groupsByName[entry.name.trim()];
    if (group == null) return;

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => GroupProfileScreen(group: group)));
  }
}

class _GlobalLeaderboardView extends StatelessWidget {
  const _GlobalLeaderboardView({
    required this.mode,
    required this.entries,
    required this.groupEntries,
    required this.onUserTap,
    required this.onGroupTap,
  });

  final LeaderboardMode mode;
  final List<LeaderboardEntry> entries;
  final List<GroupLeaderboardEntry> groupEntries;
  final ValueChanged<LeaderboardEntry> onUserTap;
  final ValueChanged<GroupLeaderboardEntry> onGroupTap;

  @override
  Widget build(BuildContext context) {
    final itemCount = mode == LeaderboardMode.solo
        ? entries.length
        : groupEntries.length;

    if (itemCount == 0) {
      return const _EmptyLeaderboardView(
        title: 'No leaderboard data yet',
        subtitle: 'Save runs or join groups to populate this leaderboard.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      notificationPredicate: (_) => false,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: mode == LeaderboardMode.solo
                ? GlobalSoloLeaderboardCard(
                    entry: entries[index],
                    onTap: () => onUserTap(entries[index]),
                  )
                : GlobalGroupLeaderboardCard(
                    entry: groupEntries[index],
                    onTap: () => onGroupTap(groupEntries[index]),
                  ),
          );
        },
      ),
    );
  }
}

class _FriendsLeaderboardView extends StatelessWidget {
  const _FriendsLeaderboardView({
    required this.entries,
    required this.onUserTap,
  });

  final List<LeaderboardEntry> entries;
  final ValueChanged<LeaderboardEntry> onUserTap;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _EmptyLeaderboardView(
        title: 'No friends ranked yet',
        subtitle: 'Add friends and save runs to see the friends leaderboard.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: FriendsLeaderboardCard(
            entry: entries[index],
            onTap: () => onUserTap(entries[index]),
          ),
        );
      },
    );
  }
}

class _LeaderboardErrorView extends StatelessWidget {
  const _LeaderboardErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 34,
              color: Color(0xFFD45656),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load leaderboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8B8B8B)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _LeaderboardScreenState._brandGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLeaderboardView extends StatelessWidget {
  const _EmptyLeaderboardView({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 34,
              color: _LeaderboardScreenState._brandGreen,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8B8B8B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoloOnlyChip extends StatelessWidget {
  const _SoloOnlyChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _LeaderboardScreenState._brandGreen,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _LeaderboardScreenState._brandGreen.withValues(alpha: 0.24),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'Solo',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SegmentOption<T> {
  const _SegmentOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class _SegmentedToggle<T> extends StatelessWidget {
  const _SegmentedToggle({
    required this.value,
    required this.onChanged,
    required this.options,
    required this.height,
    this.activeColor = const Color(0xFF111111),
    this.activeBackground = Colors.white,
    this.compact = false,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<_SegmentOption<T>> options;
  final double height;
  final Color activeColor;
  final Color activeBackground;
  final bool compact;

  static const _inactiveColor = Color(0xFFA7AEAA);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2732) : const Color(0xFFF1F1EF),
        borderRadius: BorderRadius.circular(compact ? 9 : 11),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _SegmentButton(
                isActive: option.value == value,
                icon: option.icon,
                label: option.label,
                activeColor: activeColor,
                activeBackground: activeBackground,
                inactiveColor: _inactiveColor,
                compact: compact,
                onTap: () => onChanged(option.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.isActive,
    required this.label,
    required this.activeColor,
    required this.activeBackground,
    required this.inactiveColor,
    required this.compact,
    required this.onTap,
    this.icon,
  });

  final bool isActive;
  final IconData? icon;
  final String label;
  final Color activeColor;
  final Color activeBackground;
  final Color inactiveColor;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive ? activeColor : inactiveColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive ? activeBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(compact ? 7 : 9),
        boxShadow: isActive && activeBackground == Colors.white
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(compact ? 7 : 9),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? color
                        : (isDark ? const Color(0xFF9BA8B4) : color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RunnerSeed {
  const _RunnerSeed({
    required this.id,
    required this.fullname,
    required this.username,
    required this.profileUrl,
    required this.isCurrentUser,
  });

  final String id;
  final String fullname;
  final String username;
  final String? profileUrl;
  final bool isCurrentUser;
}

class _RunnerAggregate {
  const _RunnerAggregate({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.distanceKm,
    required this.time,
    required this.totalRuns,
    required this.territories,
    required this.isCurrentUser,
  });

  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final double distanceKm;
  final String time;
  final int totalRuns;
  final int territories;
  final bool isCurrentUser;
}
