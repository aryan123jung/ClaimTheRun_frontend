import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';
import 'package:clain_the_run/features/social/domain/usecases/create_post_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/get_my_posts_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/get_posts_usecase.dart';
import 'package:clain_the_run/features/social/domain/usecases/toggle_post_like_usecase.dart';
import 'package:clain_the_run/features/social/presentation/state/social_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socialViewModelProvider = NotifierProvider<SocialViewModel, SocialState>(
  SocialViewModel.new,
);

class SocialViewModel extends Notifier<SocialState> {
  late final GetPostsUsecase _getPostsUsecase;
  late final GetMyPostsUsecase _getMyPostsUsecase;
  late final CreatePostUsecase _createPostUsecase;
  late final TogglePostLikeUsecase _togglePostLikeUsecase;

  @override
  SocialState build() {
    _getPostsUsecase = ref.read(getPostsUsecaseProvider);
    _getMyPostsUsecase = ref.read(getMyPostsUsecaseProvider);
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

  Future<bool> createPost({required String caption, String? imageUrl}) async {
    state = state.copyWith(status: SocialStatus.submitting, clearError: true);

    final result = await _createPostUsecase(
      CreatePostUsecaseParams(caption: caption, imageUrl: imageUrl),
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
          posts: [post, ...state.posts],
          myPosts: [post, ...state.myPosts],
          clearError: true,
        );
        return true;
      },
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
}
