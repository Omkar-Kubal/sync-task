import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';

class BlackPlaceholderScreen extends StatelessWidget {
  const BlackPlaceholderScreen({
    this.onClose,
    this.title = 'Coming soon',
    this.message = 'This list is not available yet.',
    super.key,
  });

  final VoidCallback? onClose;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: onClose != null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _returnToLists(context);
        }
      },
      child: Scaffold(
        backgroundColor: SyncTasksColorScheme.of(context).scaffold,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PlaceholderHeader(
                title: title,
                onClose: () => _returnToLists(context),
              ),
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          SyncIcons.sync,
                          size: 34,
                          color: SyncTasksColorScheme.of(context).textSecondary,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Coming soon',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: SyncTasksColorScheme.of(
                                  context,
                                ).textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                                height: 1.12,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: SyncTasksColorScheme.of(
                                  context,
                                ).textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                                height: 1.34,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _returnToLists(BuildContext context) {
    final close = onClose;
    if (close == null) {
      context.go('/lists');
    } else {
      close();
    }
  }
}

class _PlaceholderHeader extends StatelessWidget {
  const _PlaceholderHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colors.textPrimary,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: 'Close list',
          child: ExcludeSemantics(
            child: IconButton(
              onPressed: onClose,
              tooltip: 'Close list',
              style: IconButton.styleFrom(
                fixedSize: const Size(38, 38),
                minimumSize: const Size(38, 38),
                foregroundColor: colors.textPrimary,
                backgroundColor: colors.surface,
                padding: EdgeInsets.zero,
                side: BorderSide.none,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}


