import 'dart:typed_data';

import 'package:clain_the_run/app/theme_provider.dart';
import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/auth/presentation/pages/login_screen.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/map/data/datasources/run_api_service.dart';
import 'package:clain_the_run/features/map/data/models/run_record.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/profileheadercard.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/profilestattile.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/statsheet.dart';
import 'package:clain_the_run/features/profile/presentation/widgets/weeklyactivitycart.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/presentation/view_model/social_view_model.dart';
import 'package:clain_the_run/features/social/presentation/widgets/create_post_popup.dart';
import 'package:clain_the_run/features/social/presentation/widgets/postcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RunApiService _runApiService = RunApiService();
  List<RunRecord> _runs = const <RunRecord>[];
  bool _isLoadingRuns = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authViewModelProvider.notifier).loadCurrentUser(),
    );
    Future.microtask(
      () => ref.read(socialViewModelProvider.notifier).loadMyPosts(),
    );
    Future.microtask(_loadRuns);
  }

  Future<void> _loadRuns() async {
    try {
      final runs = await _runApiService.fetchMyRuns();
      if (!mounted) return;
      setState(() {
        _runs = runs;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _runs = const <RunRecord>[];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRuns = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(
      authViewModelProvider.select((state) => state.authEntity),
    );
    final myPosts = ref
        .watch(socialViewModelProvider.select((state) => state.myPosts))
        .map(_mapPostEntityToViewModel)
        .toList();
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
    final profileStats = _buildStats(_runs);
    final weeklyStats = _buildWeeklyStats(_runs);
    final territoryCount = _runs.where((run) => run.hasTerritory).length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _ProfileDrawer(
        isDarkMode: isDark,
        onThemeChanged: (enabled) {
          ref
              .read(themeModeProvider.notifier)
              .setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
        },
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: Icon(
                      Icons.menu,
                      size: 28,
                      color: isDark ? Colors.white : const Color(0xFF222222),
                    ),
                  ),
                ],
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
                runCount: _runs.length,
                territoryCount: territoryCount,
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
                      onTap: () =>
                          showAllStatsSheet(context, stats: profileStats),
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
                      ProfileStatTile(
                        stat: profileStats[i],
                        showDivider: i != 2,
                      ),
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
                days: weeklyStats.days,
                totalDistanceKm: weeklyStats.totalDistanceKm,
                totalTime: weeklyStats.totalTime,
                avgPace: '${weeklyStats.avgPace} / km',
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
              if (myPosts.isEmpty)
                _ProfilePostMessage(
                  message: 'You have not posted anything yet.',
                  actionLabel: 'Refresh',
                  onTap: () {
                    ref
                        .read(socialViewModelProvider.notifier)
                        .loadMyPosts(force: true);
                  },
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
    // The profile header is already kept in sync after edit, so refreshing
    // should only reload the posts list instead of re-fetching everything.
    await ref.read(socialViewModelProvider.notifier).loadMyPosts(force: true);
    await _loadRuns();
  }

  List<ProfileStatModel> _buildStats(List<RunRecord> runs) {
    final totalDistanceKm = runs.fold<double>(
      0,
      (sum, run) => sum + (run.distanceMeters / 1000),
    );
    final totalDurationSeconds = runs.fold<int>(
      0,
      (sum, run) => sum + run.durationSeconds,
    );
    final totalDistanceMeters = runs.fold<double>(
      0,
      (sum, run) => sum + run.distanceMeters,
    );
    final totalCalories = runs.fold<int>(
      0,
      (sum, run) => sum + ((run.distanceMeters / 1000) * 68).round(),
    );

    return [
      ProfileStatModel(
        icon: Icons.show_chart_rounded,
        iconColor: const Color(0xFF72B63E),
        value: _isLoadingRuns ? '...' : totalDistanceKm.toStringAsFixed(1),
        label: 'Total Km',
      ),
      ProfileStatModel(
        icon: Icons.timer_outlined,
        iconColor: const Color(0xFF3D6FE0),
        value: _isLoadingRuns
            ? '--:--:--'
            : _formatDuration(totalDurationSeconds),
        label: 'Total Time',
      ),
      ProfileStatModel(
        icon: Icons.speed_rounded,
        iconColor: const Color(0xFFB6A72E),
        value: _isLoadingRuns
            ? '--'
            : _formatPace(totalDistanceMeters, totalDurationSeconds),
        label: 'Avg Pace',
      ),
      ProfileStatModel(
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFE08A2E),
        value: _isLoadingRuns ? '...' : _formatNumber(totalCalories),
        label: 'Calories',
      ),
      ProfileStatModel(
        icon: Icons.directions_run_rounded,
        iconColor: const Color(0xFFB03A3A),
        value: _isLoadingRuns ? '...' : '${runs.length}',
        label: 'Total Runs',
      ),
    ];
  }

  _WeeklyProfileStats _buildWeeklyStats(List<RunRecord> runs) {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dailyDistance = List<double>.filled(7, 0);
    double totalDistanceKm = 0;
    int totalDurationSeconds = 0;

    for (final run in runs) {
      final createdAt = run.createdAt?.toLocal();
      if (createdAt == null) continue;
      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final diff = day.difference(startOfWeek).inDays;
      if (diff < 0 || diff > 6) continue;
      final distanceKm = run.distanceMeters / 1000;
      dailyDistance[diff] += distanceKm;
      totalDistanceKm += distanceKm;
      totalDurationSeconds += run.durationSeconds;
    }

    return _WeeklyProfileStats(
      days: [
        for (int index = 0; index < 7; index++)
          DailyDistance(label: labels[index], km: dailyDistance[index]),
      ],
      totalDistanceKm: totalDistanceKm,
      totalTime: _formatDuration(totalDurationSeconds),
      avgPace: _formatPace(totalDistanceKm * 1000, totalDurationSeconds),
    );
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatPace(double distanceMeters, int durationSeconds) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return "0'00\"";
    final secondsPerKm = durationSeconds / (distanceMeters / 1000);
    final minutes = secondsPerKm ~/ 60;
    final seconds = (secondsPerKm.round() % 60).toString().padLeft(2, '0');
    return "$minutes'$seconds\"";
  }

  String _formatNumber(int value) {
    final digits = value.toString();
    final parts = <String>[];
    for (int end = digits.length; end > 0; end -= 3) {
      final start = (end - 3).clamp(0, digits.length);
      parts.insert(0, digits.substring(start, end));
    }
    return parts.join(',');
  }

  Future<void> _openEditProfileSheet() async {
    final user = ref.read(authViewModelProvider).authEntity;
    final didSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _EditProfileSheet(user: user);
      },
    );

    if (didSave == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    }
  }

  void _openCreatePostPopup() {
    showCreatePostPopup(
      context,
      onSubmit: (caption, imagePath) async {
        final success = await ref
            .read(socialViewModelProvider.notifier)
            .createPost(caption: caption, imagePath: imagePath);
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

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({this.user});

  final dynamic user;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;
  bool _isSaving = false;
  bool _isPickingImage = false;

  String get _currentFullname => widget.user?.fullname.trim() ?? '';
  String get _currentBio => widget.user?.bio?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.fullname ?? '');
    _bioController = TextEditingController(text: widget.user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
    });

    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 1080,
      );

      if (!mounted) return;

      if (file == null) {
        setState(() {
          _isPickingImage = false;
        });
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) return;

      setState(() {
        _isPickingImage = false;
        _selectedImageBytes = bytes;
        _selectedImagePath = file.path;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPickingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load the selected image.')),
      );
    }
  }

  Future<void> _submit() async {
    final rawFullname = _nameController.text.trim();
    final rawBio = _bioController.text.trim();
    final fullname = rawFullname.isEmpty || rawFullname == _currentFullname
        ? null
        : rawFullname;
    final bio = rawBio.isEmpty || rawBio == _currentBio ? null : rawBio;
    final profileImagePath = _selectedImagePath;

    if (fullname == null && bio == null && profileImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick at least one profile field to update.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final message = await ref
        .read(authViewModelProvider.notifier)
        .updateProfile(
          fullname: fullname,
          bio: bio,
          profileImagePath: profileImagePath,
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Container(
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
                'Update any profile field you want. Everything here is optional.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF9BA8B4)
                      : const Color(0xFF6E6E6E),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileImagePickerCard(
                imageBytes: _selectedImageBytes,
                imageUrl: _selectedImageBytes == null
                    ? widget.user?.profileUrl
                    : null,
                isPickingImage: _isPickingImage,
                onPickImage: _isSaving || _isPickingImage ? null : _pickImage,
              ),
              const SizedBox(height: 12),
              _ProfileInputField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Leave blank to keep current name',
              ),
              const SizedBox(height: 12),
              _ProfileInputField(
                controller: _bioController,
                label: 'Bio',
                hintText: 'Leave blank to keep current bio',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF72B63E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInputField extends StatelessWidget {
  const _ProfileInputField({
    required this.controller,
    required this.label,
    this.hintText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
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

class _WeeklyProfileStats {
  const _WeeklyProfileStats({
    required this.days,
    required this.totalDistanceKm,
    required this.totalTime,
    required this.avgPace,
  });

  final List<DailyDistance> days;
  final double totalDistanceKm;
  final String totalTime;
  final String avgPace;
}

class _ProfileImagePickerCard extends StatelessWidget {
  const _ProfileImagePickerCard({
    required this.imageBytes,
    required this.imageUrl,
    required this.isPickingImage,
    this.onPickImage,
  });

  final Uint8List? imageBytes;
  final String? imageUrl;
  final bool isPickingImage;
  final VoidCallback? onPickImage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16222E) : const Color(0xFFF8F8F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFD8D8D5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isDark ? const Color(0xFF111C26) : Colors.white,
            backgroundImage: imageBytes != null
                ? MemoryImage(imageBytes!)
                : (imageUrl != null && imageUrl!.isNotEmpty
                          ? NetworkImage(
                              ApiEndpoints.profileImageUrl(imageUrl!),
                            )
                          : null)
                      as ImageProvider<Object>?,
            child: imageBytes == null && (imageUrl == null || imageUrl!.isEmpty)
                ? const Icon(Icons.person_rounded, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Image',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a photo from your gallery.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9BA8B4)
                        : const Color(0xFF6E6E6E),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onPickImage,
            child: Text(isPickingImage ? 'Loading...' : 'Choose'),
          ),
        ],
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

class _ProfileDrawer extends ConsumerWidget {
  const _ProfileDrawer({
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  static const _tokenKey = 'auth_token';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFF233241)
                        : const Color(0xFFE2E2DF),
                  ),
                ),
                child: SwitchListTile(
                  value: isDarkMode,
                  onChanged: onThemeChanged,
                  activeThumbColor: const Color(0xFF2CC76F),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  subtitle: Text(
                    'Switch the app appearance',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? const Color(0xFF9BA8B4)
                          : const Color(0xFF7B7B7B),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    const storage = FlutterSecureStorage();
                    final prefs = await SharedPreferences.getInstance();
                    await storage.delete(key: _tokenKey);
                    await prefs.remove(_tokenKey);
                    ref.read(authViewModelProvider.notifier).resetState();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Color(0xFFD64545),
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD64545),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: isDarkMode
                          ? const Color(0xFF5A2626)
                          : const Color(0xFFF0CACA),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: isDarkMode
                        ? const Color(0xFF1E1111)
                        : const Color(0xFFFFF7F7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
