import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../settings/providers/settings_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _delay = Duration(milliseconds: 700);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_delay, () {
      unawaited(_openNextScreen());
    });
  }

  Future<void> _openNextScreen() async {
    final settings = await ref.read(settingsControllerProvider).load();
    if (!mounted) {
      return;
    }
    context.go(settings.hasCompletedOnboarding ? '/today' : '/onboarding');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          key: const Key('app-splash-logo'),
          width: 132,
          height: 132,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}


