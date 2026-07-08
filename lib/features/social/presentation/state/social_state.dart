import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';

enum SocialStatus { initial, loading, loaded, submitting, error }

class SocialState {
  const SocialState({
    required this.status,
    required this.posts,
    required this.myPosts,
    this.errorMessage,
  });

  const SocialState.initial()
    : status = SocialStatus.initial,
      posts = const [],
      myPosts = const [],
      errorMessage = null;

  final SocialStatus status;
  final List<PostEntity> posts;
  final List<PostEntity> myPosts;
  final String? errorMessage;

  bool get isBusy =>
      status == SocialStatus.loading || status == SocialStatus.submitting;

  SocialState copyWith({
    SocialStatus? status,
    List<PostEntity>? posts,
    List<PostEntity>? myPosts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SocialState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      myPosts: myPosts ?? this.myPosts,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
