import 'package:clain_the_run/core/widgets/button.dart';
import 'package:clain_the_run/features/onboardings/presentation/pages/onboardingtwo.dart';
import 'package:flutter/material.dart';

class OnboardingOne extends StatelessWidget {
  const OnboardingOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/onboardingggg1.jpeg',
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
            right: 20,
            bottom: 55,
            child: PrimaryButton(
              label: 'Next',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingTwo()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
