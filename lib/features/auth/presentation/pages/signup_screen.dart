import 'package:clain_the_run/features/auth/presentation/pages/login_screen.dart';
import 'package:clain_the_run/features/auth/presentation/state/auth_state.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:clain_the_run/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _handledSuccess = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    await ref
        .read(authViewModelProvider.notifier)
        .register(
          fullname: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
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

      if (next.status == AuthStatus.registered && !_handledSuccess) {
        _handledSuccess = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        ref.read(authViewModelProvider.notifier).resetState();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/asv.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 5),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'OpenSans Bold',
                    ),
                    children: [
                      TextSpan(
                        text: "Let’s Get ",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Started!',
                        style: TextStyle(color: accentColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Register to start your new journey.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'OpenSans Italic',
                  ),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Full Name',
                  hintText: 'Enter your fullname',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _fullNameController,
                  validator: (value) {
                    if ((value?.trim() ?? '').isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                AuthTextField(
                  label: 'Username',
                  hintText: 'Enter your username',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _usernameController,
                  validator: (value) {
                    final username = value?.trim() ?? '';
                    if (username.isEmpty) return 'Username is required';
                    if (username.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 42),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: AuthPrimaryButton(
                    label: 'Register',
                    onPressed: _register,
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'OpenSans Italic',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
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
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'OpenSans Bold',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
