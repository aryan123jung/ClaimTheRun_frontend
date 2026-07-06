import 'dart:ui';

import 'package:flutter/material.dart';

Future<void> showCreatePostPopup(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Create post',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _CreatePostPopupOverlay();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _CreatePostPopupOverlay extends StatelessWidget {
  const _CreatePostPopupOverlay();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.black.withValues(alpha: 0.14)),
              ),
            ),
          ),
          const SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: CreatePostPopupCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePostPopupCard extends StatefulWidget {
  const CreatePostPopupCard({super.key});

  @override
  State<CreatePostPopupCard> createState() => _CreatePostPopupCardState();
}

class _CreatePostPopupCardState extends State<CreatePostPopupCard> {
  static const int _captionLimit = 500;

  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionLength = _captionController.text.characters.length;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 720,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D0D0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Create a Post',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Share your run, thoughts or moments.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF787878),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 28,
                      color: Color(0xFF4B4B4B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: const [
                Text(
                  'Add Photos',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF232323),
                  ),
                ),
                Spacer(),
                Text(
                  '0/5',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4C9A2A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FCF5),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF9BCB84),
                    width: 1.8,
                  ),
                ),
                child: Column(
                  children: const [
                    _UploadBadge(),
                    SizedBox(height: 18),
                    Text(
                      'Tap to add photos',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E8F1F),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'or drag and drop',
                      style: TextStyle(fontSize: 14, color: Color(0xFF818181)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Write a caption',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF232323),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFB8B8B8), width: 1.4),
              ),
              child: TextField(
                controller: _captionController,
                maxLength: _captionLimit,
                maxLines: 5,
                minLines: 5,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "What’s on your mind?",
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8F939B),
                  ),
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.fromLTRB(22, 18, 22, 18),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF1B1B1B),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$captionLength/$_captionLimit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A9A9A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF55A63A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadBadge extends StatelessWidget {
  const _UploadBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE4F4D9), Color(0xFFD0EAB7)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.image_rounded, size: 42, color: Color(0xFF46BB34)),
          Positioned(
            right: 23,
            bottom: 24,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF46BB34),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
