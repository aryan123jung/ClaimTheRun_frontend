import 'package:clain_the_run/core/widgets/button.dart';
import 'package:clain_the_run/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';

class OnboardingTwo extends StatelessWidget {
  const OnboardingTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/onboardinggggg2.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Center(
          //   child: Text(
          //     'hello',
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontSize: 32,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          Positioned(
            left: 20,
            right: 17,
            bottom: 45,
            child: PrimaryButton(
              label: 'Get Started',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
