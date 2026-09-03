import 'package:flutter/material.dart';

import '../../../core/theme/synctask_color_scheme.dart';

class StartupStepPage extends StatelessWidget {
  const StartupStepPage({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.canGoBack = false,
    this.onBackPressed,
    super.key,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final bool canGoBack;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: canGoBack
                    ? IconButton(
                        onPressed: onBackPressed,
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back',
                      )
                    : Image.asset(
                        'assets/images/logo.png',
                        key: const Key('startup-flow-logo'),
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
              ),
              const Spacer(),
              Text(
                title,
                style: textTheme.displaySmall?.copyWith(
                  color: colors.textPrimary,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                body,
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.textSecondary,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPrimaryPressed,
                  child: Text(primaryLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
