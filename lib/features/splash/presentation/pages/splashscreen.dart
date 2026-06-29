import 'package:clain_the_run/core/constants/app_asset_paths.dart';
import 'package:clain_the_run/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.title});

  final String title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() {
            setState(() {});
          });

    controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double progressBarLeft = 80;
    const double progressBarRight = 80;
    const double progressBarBottom = 80;
    const double progressBarHeight = 10;
    const double progressBarRadius = 14;
    const Color progressColor = Color(0xFF55A53F);
    const Color progressTrackColor = Color(0xFF1E2A33);

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              AppAssetPaths.splashBackground,
              fit: BoxFit.cover,
            ),
          ),
          // Change `bottom` to move the loading bar up or down.
          Positioned(
            left: progressBarLeft,
            right: progressBarRight,
            bottom: progressBarBottom,
            child: ClipRRect(
              // Change the radius value to control how rounded the bar looks.
              borderRadius: BorderRadius.circular(progressBarRadius),
              child: SizedBox(
                // Change the height to make the loading bar thicker or thinner.
                height: progressBarHeight,
                child: LinearProgressIndicator(
                  value: controller.value,
                  semanticsLabel: 'Loading',
                  // Change this color for the unfilled track.
                  backgroundColor: progressTrackColor,
                  // Change this color for the filled progress.
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    progressColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
