import 'dart:ui';

import 'package:clain_the_run/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:clain_the_run/features/auth/presentation/state/auth_state.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF010B14);
    const Color accentColor = Color(0xFF78D21F);
    const Color subtitleColor = Color(0xFF99A1A9);
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: 0.16,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                    child: Image.asset(
                      'assets/images/logoHEAD.png',
                      width: 360,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Positioned(
          //   top: 85,
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: Image.asset(
          //       'assets/images/asv.png',
          //       // height: 190,
          //       height: 170,
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
          Positioned(
            top: 85,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logoHEAD.png',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    'assets/images/logoBODY.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          // SizedBox(height: 40),
          Column(
            children: [
              const SizedBox(height: 280),

              // SizedBox(height: 10),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'OpenSans Bold',
                  ),
                  children: [
                    TextSpan(
                      text: 'Password ',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'Recovery!',
                      style: TextStyle(color: accentColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter your email below to recover your password.',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'OpenSans Italic',
                ),
              ),
              const SizedBox(height: 100),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        label: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icons.mail_outline_rounded,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Email is required';
                          if (!email.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 180),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: AuthPrimaryButton(
                          label: 'Send OTP',
                          // onPressed: (){
                          //   Navigator.push(context, MaterialPageRoute(builder: (context)=>))
                          // },
                          onPressed: () {},
                          isLoading: isLoading,
                        ),
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
