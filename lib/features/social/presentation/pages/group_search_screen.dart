import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/presentation/pages/group_profile_screen.dart';
import 'package:clain_the_run/features/social/presentation/state/social_state.dart';
import 'package:clain_the_run/features/social/presentation/view_model/social_view_model.dart';
import 'package:clain_the_run/features/social/presentation/widgets/groupcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupSearchScreen extends ConsumerStatefulWidget {
  const GroupSearchScreen({super.key});

  @override
  ConsumerState<GroupSearchScreen> createState() => _GroupSearchScreenState();
}

class _GroupSearchScreenState extends ConsumerState<GroupSearchScreen> {
  @override
  void dispose() {
    ref.read(socialViewModelProvider.notifier).searchGroups(search: '');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socialState = ref.watch(socialViewModelProvider);
    final isLoading = socialState.status == SocialStatus.loading;
    final groups = socialState.discoverableGroups;
    final query = socialState.discoverableGroupSearchQuery;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Search Groups'), elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: _GroupSearchField(
                hint: 'Search other groups...',
                onChanged: (value) {
                  ref
                      .read(socialViewModelProvider.notifier)
                      .searchGroups(search: value);
                },
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (query.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: _SearchMessageCard(
                        message:
                            'Search by group name to discover groups you can join.',
                      ),
                    );
                  }

                  if (isLoading && groups.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (socialState.errorMessage != null && groups.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: _SearchMessageCard(
                        message: socialState.errorMessage!,
                        actionLabel: 'Retry',
                        onTap: () {
                          ref
                              .read(socialViewModelProvider.notifier)
                              .searchGroups(search: query);
                        },
                      ),
                    );
                  }

                  if (groups.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: _SearchMessageCard(
                        message: 'No groups matched your search yet.',
                      ),
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
                      );
                    },
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

class _GroupSearchField extends StatelessWidget {
  const _GroupSearchField({required this.hint, this.onChanged});

  final String hint;
  final ValueChanged<String>? onChanged;

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
              onChanged: onChanged,
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

class _SearchMessageCard extends StatelessWidget {
  const _SearchMessageCard({
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
          color: isDark ? const Color(0xFF233241) : const Color(0xFFEDEDEA),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
