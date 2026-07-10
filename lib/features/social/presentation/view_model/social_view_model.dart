import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/domain/usecases/create_group_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/create_post_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/get_group_posts_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/get_my_groups_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/get_my_posts_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/get_posts_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/join_group_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/leave_group_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/toggle_post_like_usecase.dart';
import 'package:clain_the_run/features/social/presentation/state/social_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socialViewModelProvider = NotifierProvider<SocialViewModel, SocialState>(
  SocialViewModel.new,
);

class SocialViewModel extends Notifier<SocialState> {
  late final GetPostsUsecase _getPostsUsecase;
  late final GetMyPostsUsecase _getMyPostsUsecase;
  late final GetMyGroupsUsecase _getMyGroupsUsecase;
  late final GetGroupPostsUsecase _getGroupPostsUsecase;
  late final CreateGroupUsecase _createGroupUsecase;
  late final JoinGroupUsecase _joinGroupUsecase;
  late final LeaveGroupUsecase _leaveGroupUsecase;
  late final CreatePostUsecase _createPostUsecase;
  late final TogglePostLikeUsecase _togglePostLikeUsecase;

  @override
  SocialState build() {
    _getPostsUsecase = ref.read(getPostsUsecaseProvider);
    _getMyPostsUsecase = ref.read(getMyPostsUsecaseProvider);
    _getMyGroupsUsecase = ref.read(getMyGroupsUsecaseProvider);
    _getGroupPostsUsecase = ref.read(getGroupPostsUsecaseProvider);
    _createGroupUsecase = ref.read(createGroupUsecaseProvider);
    _joinGroupUsecase = ref.read(joinGroupUsecaseProvider);
    _leaveGroupUsecase = ref.read(leaveGroupUsecaseProvider);
    _createPostUsecase = ref.read(createPostUsecaseProvider);
    _togglePostLikeUsecase = ref.read(togglePostLikeUsecaseProvider);
    return const SocialState.initial();
  }

  Future<void> loadPosts({bool force = false}) async {
    if (!force &&
        state.posts.isNotEmpty &&
        state.status == SocialStatus.loaded) {
      return;
    }

    state = state.copyWith(
      status: state.posts.isEmpty ? SocialStatus.loading : state.status,
      clearError: true,
    );

    final result = await _getPostsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: SocialStatus.error,
        errorMessage: failure.message,
      ),
      (posts) => state = state.copyWith(
        status: SocialStatus.loaded,
        posts: posts,
        clearError: true,
      ),
    );
  }

  Future<void> loadMyPosts({bool force = false}) async {
    if (!force &&
        state.myPosts.isNotEmpty &&
        state.status == SocialStatus.loaded) {
      return;
    }

    state = state.copyWith(
      status: state.myPosts.isEmpty ? SocialStatus.loading : state.status,
      clearError: true,
    );

    final result = await _getMyPostsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: SocialStatus.error,
        errorMessage: failure.message,
      ),
      (posts) => state = state.copyWith(
        status: SocialStatus.loaded,
        myPosts: posts,
        clearError: true,
      ),
    );
  }

  Future<bool> createPost({
    required String caption,
    String? imagePath,
    String? communityId,
  }) async {
    state = state.copyWith(status: SocialStatus.submitting, clearError: true);

    final result = await _createPostUsecase(
      CreatePostUsecaseParams(
        caption: caption,
        imagePath: imagePath,
        communityId: communityId,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: SocialStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (post) {
        state = state.copyWith(
          status: SocialStatus.loaded,
          posts: communityId == null ? [post, ...state.posts] : state.posts,
          myPosts: [post, ...state.myPosts],
          groupPostsById: communityId == null
              ? state.groupPostsById
              : {
                  ...state.groupPostsById,
                  communityId: [
                    post,
                    ...state.groupPostsById[communityId] ?? const [],
                  ],
                },
          clearError: true,
        );
        return true;
      },
    );
  }

  Future<void> loadGroups({String? search, bool force = false}) async {
    if (!force &&
        search == state.groupSearchQuery &&
        state.groups.isNotEmpty &&
        state.status == SocialStatus.loaded) {
      return;
    }

    state = state.copyWith(
      status: state.groups.isEmpty ? SocialStatus.loading : state.status,
      groupSearchQuery: search ?? '',
      clearError: true,
    );

    final result = await _getMyGroupsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: SocialStatus.error,
        errorMessage: failure.message,
      ),
      (groups) {
        final query = (search ?? '').trim().toLowerCase();
        final filteredGroups = query.isEmpty
            ? groups
            : groups.where((group) {
                final name = group.name.toLowerCase();
                final description = group.description.toLowerCase();
                return name.contains(query) || description.contains(query);
              }).toList();
        state = state.copyWith(
          status: SocialStatus.loaded,
          groups: filteredGroups,
          clearError: true,
        );
      },
    );
  }

  Future<void> loadGroupPosts(String groupId, {bool force = false}) async {
    if (!force && state.groupPostsById[groupId]?.isNotEmpty == true) {
      return;
    }

    state = state.copyWith(status: SocialStatus.loading, clearError: true);
    final result = await _getGroupPostsUsecase(groupId);
    result.fold(
      (failure) => state = state.copyWith(
        status: SocialStatus.error,
        errorMessage: failure.message,
      ),
      (posts) => state = state.copyWith(
        status: SocialStatus.loaded,
        groupPostsById: {...state.groupPostsById, groupId: posts},
        clearError: true,
      ),
    );
  }

  Future<bool> createGroup({
    required String name,
    required String description,
    String? imagePath,
  }) async {
    state = state.copyWith(status: SocialStatus.submitting, clearError: true);
    final result = await _createGroupUsecase(
      CreateGroupParams(
        name: name,
        description: description,
        imagePath: imagePath,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: SocialStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (group) {
        state = state.copyWith(
          status: SocialStatus.loaded,
          groups: [group, ..._withoutGroup(group.id)],
          clearError: true,
        );
        return true;
      },
    );
  }

  Future<void> joinGroup(String groupId) async {
    final result = await _joinGroupUsecase(groupId);
    result.fold(
      (failure) => state = state.copyWith(
        status: SocialStatus.error,
        errorMessage: failure.message,
      ),
      (group) => _upsertGroup(group),
    );
  }

  Future<void> leaveGroup(String groupId) async {
    final result = await _leaveGroupUsecase(groupId);
    result.fold(
      (failure) => state = state.copyWith(
        status: SocialStatus.error,
        errorMessage: failure.message,
      ),
      (group) => _upsertGroup(group),
    );
  }

  Future<void> toggleLike(String postId) async {
    final existingPosts = state.posts;
    final index = existingPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final result = await _togglePostLikeUsecase(
      TogglePostLikeUsecaseParams(postId: postId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: SocialStatus.error,
        errorMessage: failure.message,
      ),
      (updatedPost) => state = state.copyWith(
        status: SocialStatus.loaded,
        posts: _replacePost(existingPosts, updatedPost),
        myPosts: _replacePost(state.myPosts, updatedPost),
        clearError: true,
      ),
    );
  }

  List<PostEntity> _replacePost(
    List<PostEntity> posts,
    PostEntity updatedPost,
  ) {
    return [
      for (final post in posts)
        if (post.id == updatedPost.id) updatedPost else post,
    ];
  }

  List<GroupEntity> _withoutGroup(String groupId) {
    return state.groups.where((group) => group.id != groupId).toList();
  }

  void _upsertGroup(GroupEntity group) {
    state = state.copyWith(
      status: SocialStatus.loaded,
      groups: [group, ..._withoutGroup(group.id)],
      clearError: true,
    );
  }
}
