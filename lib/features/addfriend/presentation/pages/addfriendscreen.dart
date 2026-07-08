import 'package:flutter/material.dart';

class AddFriendScreen extends StatelessWidget {
  const AddFriendScreen({super.key});

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
                      'Add Friends',
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
                'Find runners you know and grow your crew.',
                style: TextStyle(fontSize: 13, color: Color(0xFF707070)),
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _AddFriendSearchField(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _AddFriendSearchField extends StatelessWidget {
  const _AddFriendSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDADAD6)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: Color(0xFF9A9A9A)),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search by name or username',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9A9A9A)),
                isDense: true,
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
