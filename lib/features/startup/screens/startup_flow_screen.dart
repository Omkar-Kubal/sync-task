import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../settings/providers/settings_controller.dart';
import '../domain/startup_step.dart';
import '../widgets/startup_step_page.dart';

class StartupFlowScreen extends ConsumerWidget {
  const StartupFlowScreen({required this.step, super.key});

  final StartupStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = _copyFor(step);
    return StartupStepPage(
      title: copy.title,
      body: copy.body,
      primaryLabel: copy.primaryLabel,
      canGoBack: step != StartupStep.tasks,
      onBackPressed: () => context.pop(),
      onPrimaryPressed: () async {
        final next = step.next;
        if (next != null) {
          context.push(next.routePath);
          return;
        }
        await ref
            .read(settingsControllerProvider)
            .setStartupFlowCompleted(true);
        if (context.mounted) {
          context.go('/today');
        }
      },
    );
  }
}

_StartupCopy _copyFor(StartupStep step) {
  return switch (step) {
    StartupStep.tasks => const _StartupCopy(
      title: 'Plan your day',
      body: 'Keep Today, Upcoming, and Lists tidy before the work starts.',
      primaryLabel: 'Next',
    ),
    StartupStep.focus => const _StartupCopy(
      title: 'Protect focus time',
      body: 'Attach timers to important tasks or start a standalone focus run.',
      primaryLabel: 'Next',
    ),
    StartupStep.done => const _StartupCopy(
      title: 'SyncTask is ready',
      body: 'Your tasks stay local, fast, and ready when you are.',
      primaryLabel: 'Start',
    ),
  };
}

class _StartupCopy {
  const _StartupCopy({
    required this.title,
    required this.body,
    required this.primaryLabel,
  });

  final String title;
  final String body;
  final String primaryLabel;
}
