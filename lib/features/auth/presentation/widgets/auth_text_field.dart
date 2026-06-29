import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF78D21F);
    const Color borderColor = Color(0xFF63C813);
    const Color fillColor = Color(0xFF0C151D);
    const Color hintColor = Color(0xFF97A1AA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'OpenSans Regular',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'OpenSans Regular',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: hintColor,
              fontSize: 17,
              fontFamily: 'OpenSans Regular',
            ),
            prefixIcon: Icon(prefixIcon, color: accentColor),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor.withValues(alpha: 0.58),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: borderColor, width: 1.6),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: accentColor, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
