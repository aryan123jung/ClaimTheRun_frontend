import 'package:clain_the_run/features/addfriend/presentation/widgets/add_friend_user_card.dart';
import 'package:flutter/material.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  static const _requests = [
    AddFriendUserModel(
      name: 'Nabin Shrestha',
      avatarUrl: 'https://i.pravatar.cc/150?img=52',
      mutualFriends: 6,
      subtitle: 'Runs every morning around Boudha',
      isIncomingRequest: true,
    ),
    AddFriendUserModel(
      name: 'Sujan Karki',
      avatarUrl: 'https://i.pravatar.cc/150?img=54',
      mutualFriends: 3,
      subtitle: 'Trail runner and long-run lover',
      isIncomingRequest: true,
    ),
    AddFriendUserModel(
      name: 'Prerana Thapa',
      avatarUrl: 'https://i.pravatar.cc/150?img=48',
      mutualFriends: 4,
      subtitle: 'Looking for evening running partners',
      isIncomingRequest: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 18, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Expanded(
                    child: Text(
                      'Friend Requests',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'See everyone waiting to connect with you.',
                style: TextStyle(fontSize: 13, color: Color(0xFF707070)),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _requests.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = _requests[index];
                  return AddFriendUserCard(
                    user: user,
                    primaryLabel: 'Accept',
                    secondaryLabel: 'Delete',
                    onPrimaryTap: () {},
                    onSecondaryTap: () {},
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
