import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/profileheadercard.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/profilestattile.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/statsheet.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/weeklyactivitycart.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/presentation/state/social_state.dart';
import 'package:clain_the_run/features/social/presentation/view_model/social_view_model.dart';
import 'package:clain_the_run/features/social/presentation/widgets/create_post_popup.dart';
import 'package:clain_the_run/features/social/presentation/widgets/postcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const _stats = [
    ProfileStatModel(
      icon: Icons.show_chart_rounded,
      iconColor: Color(0xFF72B63E),
      value: '256.4',
      label: 'Total Km',
    ),
    ProfileStatModel(
      icon: Icons.timer_outlined,
      iconColor: Color(0xFF3D6FE0),
      value: '24:36:14',
      label: 'Total Time',
    ),
    ProfileStatModel(
      icon: Icons.speed_rounded,
      iconColor: Color(0xFFB6A72E),
      value: "6'21\"",
      label: 'Avg Pace',
    ),
    ProfileStatModel(
      icon: Icons.local_fire_department_rounded,
      iconColor: Color(0xFFE08A2E),
      value: '19,860',
      label: 'Calories',
    ),
    ProfileStatModel(
      icon: Icons.directions_run_rounded,
      iconColor: Color(0xFFB03A3A),
      value: '47',
      label: 'Total Runs',
    ),
  ];

  static const _weekDays = [
    DailyDistance(label: 'Mon', km: 6.2),
    DailyDistance(label: 'Tue', km: 8.1),
    DailyDistance(label: 'Wed', km: 5.0),
    DailyDistance(label: 'Thu', km: 7.3),
    DailyDistance(label: 'Fri', km: 10.2),
    DailyDistance(label: 'Sat', km: 12.6),
    DailyDistance(label: 'Sun', km: 9.0),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authViewModelProvider.notifier).loadCurrentUser(),
    );
    Future.microtask(
      () => ref.read(socialViewModelProvider.notifier).loadMyPosts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.authEntity;
    final socialState = ref.watch(socialViewModelProvider);
    final myPosts = socialState.myPosts.map(_mapPostEntityToViewModel).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fullName = user?.fullname.trim().isNotEmpty == true
        ? user!.fullname
        : 'Runner';
    final bio = user?.bio?.trim().isNotEmpty == true
        ? user!.bio!.trim()
        : 'Add a short bio from Edit Profile.';
    final avatarUrl = (user?.profileUrl != null && user!.profileUrl!.isNotEmpty)
        ? ApiEndpoints.profileImageUrl(user.profileUrl!)
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=E6F3DC&color=3B6D11';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Track your progress. Own your journey.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF9BA8B4)
                      : const Color(0xFF6E6E6E),
                ),
              ),
              const SizedBox(height: 16),
              ProfileHeaderCard(
                name: fullName,
                bio: bio,
                avatarUrl: avatarUrl,
                runCount: 47,
                territoryCount: 1,
                postCount: myPosts.length,
                onEditAvatar: _openEditProfileSheet,
                onEditProfile: _openEditProfileSheet,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Stats',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => showAllStatsSheet(context, stats: _stats),
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
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111C26) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF233241)
                        : const Color(0xFFD8D8D5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      ProfileStatTile(stat: _stats[i], showDivider: i != 2),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Activity Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 10),
              WeeklyActivityChart(
                days: _weekDays,
                totalDistanceKm: 57.8,
                totalTime: '5:42:18',
                avgPace: "5'55\" / km",
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Posts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openCreatePostPopup,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Post'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B6D11),
                      side: BorderSide(
                        color: const Color(0xFF3B6D11).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (socialState.status == SocialStatus.loading && myPosts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (socialState.errorMessage != null && myPosts.isEmpty)
                _ProfilePostMessage(
                  message: socialState.errorMessage!,
                  actionLabel: 'Retry',
                  onTap: () {
                    ref.read(socialViewModelProvider.notifier).loadMyPosts();
                  },
                )
              else if (myPosts.isEmpty)
                _ProfilePostMessage(
                  message: 'You have not posted anything yet.',
                  actionLabel: 'Create one',
                  onTap: _openCreatePostPopup,
                ),
              for (final post in myPosts) ...[
                PostCard(
                  post: post,
                  onLike: () {
                    ref
                        .read(socialViewModelProvider.notifier)
                        .toggleLike(post.id);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshProfile() async {
    await ref.read(authViewModelProvider.notifier).loadCurrentUser();
    await ref.read(socialViewModelProvider.notifier).loadMyPosts();
  }

  Future<void> _openEditProfileSheet() async {
    final user = ref.read(authViewModelProvider).authEntity;
    final nameController = TextEditingController(text: user?.fullname ?? '');
    final bioController = TextEditingController(text: user?.bio ?? '');
    final imageController = TextEditingController(text: user?.profileUrl ?? '');
    bool isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> submit() async {
                final fullname = nameController.text.trim();
                final bio = bioController.text.trim();
                final profileUrl = imageController.text.trim();
                final messenger = ScaffoldMessenger.of(this.context);
                final navigator = Navigator.of(context);

                if (fullname.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Full name is required.')),
                  );
                  return;
                }

                setModalState(() {
                  isSaving = true;
                });

                final message = await ref
                    .read(authViewModelProvider.notifier)
                    .updateProfile(
                      fullname: fullname,
                      bio: bio,
                      profileUrl: profileUrl,
                    );

                if (!mounted) return;

                setModalState(() {
                  isSaving = false;
                });

                if (message != null) {
                  messenger.showSnackBar(SnackBar(content: Text(message)));
                  return;
                }

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully.'),
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111C26) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Update your full name, bio, and profile image URL.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF9BA8B4)
                            : const Color(0xFF6E6E6E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ProfileInputField(
                      controller: nameController,
                      label: 'Full Name',
                    ),
                    const SizedBox(height: 12),
                    _ProfileInputField(
                      controller: bioController,
                      label: 'Bio',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _ProfileInputField(
                      controller: imageController,
                      label: 'Profile Image URL',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF72B63E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(isSaving ? 'Saving...' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    nameController.dispose();
    bioController.dispose();
    imageController.dispose();
  }

  void _openCreatePostPopup() {
    showCreatePostPopup(
      context,
      onSubmit: (caption, imageUrl) async {
        final success = await ref
            .read(socialViewModelProvider.notifier)
            .createPost(caption: caption, imageUrl: imageUrl);
        if (success) return null;
        return ref.read(socialViewModelProvider).errorMessage ??
            'Unable to create post';
      },
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post uploaded successfully.')),
        );
      },
    );
  }
}

class _ProfileInputField extends StatelessWidget {
  const _ProfileInputField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? const Color(0xFF16222E) : const Color(0xFFF8F8F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF233241) : const Color(0xFFD8D8D5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF233241) : const Color(0xFFD8D8D5),
          ),
        ),
      ),
    );
  }
}

class _ProfilePostMessage extends StatelessWidget {
  const _ProfilePostMessage({
    required this.message,
    this.actionLabel,
    this.onTap,
  });

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
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE3E3E0),
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
