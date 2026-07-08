import 'package:clain_the_run/app/theme_provider.dart';
import 'package:clain_the_run/features/splash/presentation/pages/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7F5),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2CC76F),
          secondary: Color(0xFF72B63E),
          surface: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07111A),
        cardColor: const Color(0xFF111C26),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF49D87E),
          secondary: Color(0xFF72B63E),
          surface: Color(0xFF111C26),
        ),
      ),
      home: const SplashScreen(title: ''),
    );
  }
}
