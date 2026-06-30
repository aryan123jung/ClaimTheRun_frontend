import 'dart:ui';

import 'package:clain_the_run/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:clain_the_run/features/auth/presentation/pages/signup_screen.dart';
import 'package:clain_the_run/features/auth/presentation/state/auth_state.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _handledSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    await ref
        .read(authViewModelProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF010B14);
    const Color accentColor = Color(0xFF78D21F);
    const Color subtitleColor = Color(0xFF99A1A9);
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        _handledSuccess = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      if (next.status == AuthStatus.authenticated && !_handledSuccess) {
        _handledSuccess = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${next.authEntity?.fullname ?? ''}'),
          ),
        );
      }
    });

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
                      text: 'Welcome ',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'Back!',
                      style: TextStyle(color: accentColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Login to continue your login journey.',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'OpenSans Italic',
                ),
              ),
              const SizedBox(height: 32),

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
                      const SizedBox(height: 24),
                      AuthTextField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return 'Password is required';
                          }
                          if ((value ?? '').length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        suffixIcon: Icon(
                          Icons.visibility_outlined,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 22),

                      Padding(
                        padding: const EdgeInsetsGeometry.fromLTRB(
                          240,
                          0,
                          0,
                          0,
                        ),
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Color(0xFF61C901)),
                          ),
                        ),
                      ),

                      SizedBox(height: 22),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: AuthPrimaryButton(
                          label: 'Login',
                          onPressed: _login,
                          isLoading: isLoading,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF99A1A9),
                                fontSize: 16,
                                fontFamily: 'OpenSans Regular',
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: accentColor,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'OpenSans Bold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
