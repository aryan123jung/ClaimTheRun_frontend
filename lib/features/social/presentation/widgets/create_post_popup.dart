import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showCreatePostPopup(
  BuildContext context, {
  required Future<String?> Function(String caption, String? imageUrl) onSubmit,
  VoidCallback? onSuccess,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Create post',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _CreatePostPopupOverlay(onSubmit: onSubmit, onSuccess: onSuccess);
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
  const _CreatePostPopupOverlay({required this.onSubmit, this.onSuccess});

  final Future<String?> Function(String caption, String? imageUrl) onSubmit;
  final VoidCallback? onSuccess;

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
          SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: CreatePostPopupCard(
                  onSubmit: onSubmit,
                  onSuccess: onSuccess,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePostPopupCard extends StatefulWidget {
  const CreatePostPopupCard({
    super.key,
    required this.onSubmit,
    this.onSuccess,
  });

  final Future<String?> Function(String caption, String? imageUrl) onSubmit;
  final VoidCallback? onSuccess;

  @override
  State<CreatePostPopupCard> createState() => _CreatePostPopupCardState();
}

class _CreatePostPopupCardState extends State<CreatePostPopupCard> {
  static const int _captionLimit = 500;

  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;
  bool _isPickingImage = false;
  String? _errorMessage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageDataUrl;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final captionLength = _captionController.text.characters.length;
    final trimmedCaption = _captionController.text.trim();

    return Material(
      color: isDark ? const Color(0xFF111C26) : Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 720,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111C26) : Colors.white,
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
                  color: isDark
                      ? const Color(0xFF233241)
                      : const Color(0xFFD0D0D0),
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
                    children: [
                      Text(
                        'Create a Post',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Share your run, thoughts or moments.',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? const Color(0xFF9BA8B4)
                              : const Color(0xFF787878),
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
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF16222E)
                          : const Color(0xFFF2F2F2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 28,
                      color: isDark
                          ? const Color(0xFFB3BEC8)
                          : const Color(0xFF4B4B4B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Text(
                  'Add Photos',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF232323),
                  ),
                ),
                const Spacer(),
                Text(
                  _selectedImageBytes == null ? '0/1' : '1/1',
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
              onTap: _isPickingImage ? null : _pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF16222E)
                      : const Color(0xFFF8FCF5),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF233241)
                        : const Color(0xFF9BCB84),
                    width: 1.8,
                  ),
                ),
                child: _selectedImageBytes == null
                    ? Column(
                        children: [
                          if (_isPickingImage)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 18),
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Color(0xFF46BB34),
                                ),
                              ),
                            )
                          else
                            const _UploadBadge(),
                          const SizedBox(height: 18),
                          Text(
                            _isPickingImage
                                ? 'Opening gallery...'
                                : 'Tap to add a photo',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3E8F1F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'JPG, PNG, WEBP supported',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF818181),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.memory(
                              _selectedImageBytes!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Photo attached',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF2B2B2B),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _pickImage,
                                child: const Text('Change'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedImageBytes = null;
                                    _selectedImageDataUrl = null;
                                  });
                                },
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Write a caption',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF232323),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: isDark ? const Color(0xFF16222E) : Colors.transparent,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF233241)
                      : const Color(0xFFB8B8B8),
                  width: 1.4,
                ),
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
                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$captionLength/$_captionLimit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF8FA0AE)
                        : const Color(0xFF9A9A9A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC83C3C),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting || trimmedCaption.isEmpty
                    ? null
                    : _submitPost,
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
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      setState(() {
        _errorMessage = 'Caption cannot be empty.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final error = await widget.onSubmit(caption, _selectedImageDataUrl);
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
      widget.onSuccess?.call();
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage = error;
    });
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
      _errorMessage = null;
    });

    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 1280,
      );

      if (file == null) {
        if (!mounted) return;
        setState(() {
          _isPickingImage = false;
        });
        return;
      }

      final bytes = await file.readAsBytes();
      final mimeType = _inferMimeType(file.path);
      final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';

      if (!mounted) return;
      setState(() {
        _isPickingImage = false;
        _selectedImageBytes = bytes;
        _selectedImageDataUrl = dataUrl;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPickingImage = false;
        _errorMessage = 'Could not load the selected image.';
      });
    }
  }

  String _inferMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
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
