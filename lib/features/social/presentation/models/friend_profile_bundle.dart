import 'package:clain_the_run/features/social/presentation/models/friend_run_summary.dart';
import 'package:clain_the_run/features/social/presentation/widgets/postcard.dart';

class FriendProfileBundle {
  const FriendProfileBundle({required this.summary, required this.posts});

  final FriendRunSummary summary;
  final List<PostModel> posts;
}
