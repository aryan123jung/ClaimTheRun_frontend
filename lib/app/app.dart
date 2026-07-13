import 'package:clain_the_run/app/theme_provider.dart';
import 'package:clain_the_run/features/auth/presentation/state/auth_state.dart';
import 'package:clain_the_run/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:clain_the_run/features/call/presentation/pages/call_session_screen.dart';
import 'package:clain_the_run/features/call/presentation/state/call_state.dart';
import 'package:clain_the_run/features/call/presentation/view_model/call_view_model.dart';
import 'package:clain_the_run/features/splash/presentation/pages/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _isShowingCallScreen = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(callViewModelProvider.notifier).ensureReady(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(callViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      final previousUserId = previous?.authEntity?.id;
      final nextUserId = next.authEntity?.id;
      if (next.status == AuthStatus.authenticated &&
          nextUserId != null &&
          nextUserId.isNotEmpty &&
          nextUserId != previousUserId) {
        // ignore: avoid_print
        print('[CallUI] auth ready for user=$nextUserId, ensuring call socket');
        ref.read(callViewModelProvider.notifier).ensureReady();
      }
    });

    ref.listen<CallState>(callViewModelProvider, (previous, next) {
      // ignore: avoid_print
      print(
        '[CallUI] state changed ${previous?.status.name ?? 'none'} -> ${next.status.name} callId=${next.callId} participant=${next.participant?.id}',
      );
      final shouldOpen =
          next.status == CallStatus.incoming && !_isShowingCallScreen;
      if (!shouldOpen) return;

      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;

      _isShowingCallScreen = true;
      // ignore: avoid_print
      print('[CallUI] opening incoming call screen');
      navigator
          .push(MaterialPageRoute(builder: (_) => const CallSessionScreen()))
          .whenComplete(() {
            _isShowingCallScreen = false;
            // ignore: avoid_print
            print('[CallUI] call screen closed');
          });
    });

    return MaterialApp(
      navigatorKey: _navigatorKey,
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
