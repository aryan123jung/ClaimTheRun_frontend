import 'package:clain_the_run/features/social/presentation/widgets/groupcard.dart';
import 'package:clain_the_run/features/social/presentation/widgets/postcard.dart';
import 'package:flutter/material.dart';

class GroupProfileScreen extends StatelessWidget {
  const GroupProfileScreen({
    super.key,
    required this.group,
    required this.posts,
    this.description = 'Run farther together and keep each other moving.',
    this.postCount,
    this.isJoined = true,
  });

  final GroupModel group;
  final List<PostModel> posts;
  final String description;
  final int? postCount;
  final bool isJoined;

  @override
  Widget build(BuildContext context) {
    final totalPosts = postCount ?? posts.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: Color(0xFF232323),
                    ),
                  ),
                  const Spacer(),
                  _HeaderPillButton(
                    icon: Icons.add_rounded,
                    label: 'Add Post',
                    outlined: true,
                    compact: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _CircleHeaderAction(
                    icon: Icons.chat_bubble_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: [
                  _GroupHeroCard(
                    group: group,
                    description: description,
                    totalPosts: totalPosts,
                    isJoined: isJoined,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Posts',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final post in posts) ...[
                    PostCard(post: post),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeroCard extends StatelessWidget {
  const _GroupHeroCard({
    required this.group,
    required this.description,
    required this.totalPosts,
    required this.isJoined,
  });

  final GroupModel group;
  final String description;
  final int totalPosts;
  final bool isJoined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E8E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
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
                  color: const Color(0xFFF5F8F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2EBDD)),
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
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _HeaderPillButton(
                          icon: isJoined
                              ? Icons.check_rounded
                              : Icons.group_add_outlined,
                          label: isJoined ? 'Joined' : 'Join',
                          outlined: true,
                          compact: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _HeroActionButton(
            icon: Icons.directions_run_rounded,
            label: 'Start Run',
            filled: true,
            onTap: () {},
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAF8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAEAE6)),
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
                  child: _GroupStatBlock(value: '$totalPosts', label: 'Posts'),
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
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF909090)),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 52, color: const Color(0xFFE3E3E0));
  }
}

class _HeaderPillButton extends StatelessWidget {
  const _HeaderPillButton({
    required this.icon,
    required this.label,
    required this.outlined,
    this.compact = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool outlined;
  final bool compact;
  final VoidCallback? onTap;

  static const _brandGreen = Color(0xFF72B63E);
  static const _activeTextGreen = Color(0xFF3B6D11);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = outlined
        ? Colors.white
        : _brandGreen.withValues(alpha: 0.62);
    final textColor = outlined ? _activeTextGreen : Colors.white;
    final borderColor = outlined
        ? _activeTextGreen.withValues(alpha: 0.85)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: compact ? 9 : 12,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: outlined ? 1.4 : 0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 16 : 18, color: textColor),
              SizedBox(width: compact ? 6 : 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = filled
        ? const Color(0xFF72B63E)
        : const Color(0xFFF6FBF2);
    final foregroundColor = filled ? Colors.white : const Color(0xFF3B6D11);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: filled ? Colors.transparent : const Color(0xFFDCE9D3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foregroundColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleHeaderAction extends StatelessWidget {
  const _CircleHeaderAction({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF72B63E).withValues(alpha: 0.6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
