import 'package:clain_the_run/core/constants/app_asset_paths.dart';
import 'package:clain_the_run/features/onboardings/presentation/pages/onboardingone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clain_the_run/features/splash/presentation/view_model/splash_view_model.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashReadyProvider, (_, next) {
      next.whenData((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingOne()),
        );
      });
    });

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
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      semanticsLabel: 'Loading',
                      backgroundColor: progressTrackColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        progressColor,
                      ),
                    );
                  },
                  child: const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
