import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/domain/entities/post_entity.dart';

enum SocialStatus { initial, loading, loaded, submitting, error }

class SocialState {
  const SocialState({
    required this.status,
    required this.posts,
    required this.myPosts,
    required this.groups,
    required this.groupPostsById,
    required this.groupSearchQuery,
    this.errorMessage,
  });

  const SocialState.initial()
      : status = SocialStatus.initial,
        posts = const [],
        myPosts = const [],
        groups = const [],
        groupPostsById = const {},
        groupSearchQuery = '',
        errorMessage = null;

  final SocialStatus status;
  final List<PostEntity> posts;
  final List<PostEntity> myPosts;
  final List<GroupEntity> groups;
  final Map<String, List<PostEntity>> groupPostsById;
  final String groupSearchQuery;
  final String? errorMessage;

  bool get isBusy =>
      status == SocialStatus.loading || status == SocialStatus.submitting;

  SocialState copyWith({
    SocialStatus? status,
    List<PostEntity>? posts,
    List<PostEntity>? myPosts,
    List<GroupEntity>? groups,
    Map<String, List<PostEntity>>? groupPostsById,
    String? groupSearchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SocialState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      myPosts: myPosts ?? this.myPosts,
      groups: groups ?? this.groups,
      groupPostsById: groupPostsById ?? this.groupPostsById,
      groupSearchQuery: groupSearchQuery ?? this.groupSearchQuery,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
