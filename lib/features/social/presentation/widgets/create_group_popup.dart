import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showCreateGroupPopup(
  BuildContext context, {
  required Future<String?> Function(
    String name,
    String description,
    String? imagePath,
  )
  onSubmit,
  VoidCallback? onSuccess,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Create group',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _CreateGroupPopupOverlay(onSubmit: onSubmit, onSuccess: onSuccess);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _CreateGroupPopupOverlay extends StatelessWidget {
  const _CreateGroupPopupOverlay({required this.onSubmit, this.onSuccess});

  final Future<String?> Function(String, String, String?) onSubmit;
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
                child: CreateGroupPopupCard(
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

class CreateGroupPopupCard extends StatefulWidget {
  const CreateGroupPopupCard({
    super.key,
    required this.onSubmit,
    this.onSuccess,
  });

  final Future<String?> Function(String, String, String?) onSubmit;
  final VoidCallback? onSuccess;

  @override
  State<CreateGroupPopupCard> createState() => _CreateGroupPopupCardState();
}

class _CreateGroupPopupCardState extends State<CreateGroupPopupCard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSubmitting = false;
  bool _isPickingImage = false;
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF111C26) : Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 720,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111C26) : Colors.white,
          borderRadius: BorderRadius.circular(28),
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
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a Group',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Build your running community.',
                        style: TextStyle(
                          fontSize: 14,
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF16222E)
                          : const Color(0xFFF2F2F2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 26,
                      color: isDark
                          ? const Color(0xFFB3BEC8)
                          : const Color(0xFF4B4B4B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Group Photo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF232323),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: _isPickingImage ? null : _pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 24,
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
                              padding: EdgeInsets.only(bottom: 16),
                              child: SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            const _GroupUploadBadge(),
                          const SizedBox(height: 14),
                          const Text(
                            'Tap to add photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3E8F1F),
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          _selectedImageBytes!,
                          height: 170,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Group Name',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF232323),
              ),
            ),
            const SizedBox(height: 8),
            _InputShell(
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter group name',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Group Description',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF232323),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? const Color(0xFF16222E) : Colors.transparent,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF233241)
                      : const Color(0xFFB8B8B8),
                  width: 1.4,
                ),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 3,
                minLines: 3,
                decoration: const InputDecoration(
                  hintText: 'What is your group about?',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(18, 14, 18, 14),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF55A63A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text('Create Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
      _errorMessage = null;
    });

    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImagePath = file.path;
        _selectedImageBytes = bytes;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) {
      setState(() {
        _errorMessage = 'Group name and description are required.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final error = await widget.onSubmit(name, description, _selectedImagePath);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _errorMessage = error;
    });

    if (error == null) {
      Navigator.of(context).pop();
      widget.onSuccess?.call();
    }
  }
}

class _InputShell extends StatelessWidget {
  const _InputShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16222E) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFB8B8B8),
          width: 1.4,
        ),
      ),
      child: child,
    );
  }
}

class _GroupUploadBadge extends StatelessWidget {
  const _GroupUploadBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
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
          const Icon(Icons.image_rounded, size: 36, color: Color(0xFF46BB34)),
          Positioned(
            right: 16,
            bottom: 17,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF46BB34),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
