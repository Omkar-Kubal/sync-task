import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/widgets/sync_empty_state.dart';
import '../data/receipt_repository.dart';
import '../providers/receipt_feature_provider.dart';
import '../providers/receipt_repository_provider.dart';
import '../widgets/receipt_paper.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  const ReceiptDetailScreen({required this.receiptId, super.key});

  final String receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(receiptFeatureEnabledProvider);
    if (!enabled) {
      return const _ReceiptUnavailableScreen();
    }
    final receiptValue = ref.watch(savedReceiptProvider(receiptId));
    final colors = SyncTasksColorScheme.of(context);
    final content = Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: receiptValue.when(
          data: (receipt) {
            if (receipt == null) {
              return const SyncEmptyState(
                icon: SyncIcons.receipt,
                title: 'Receipt not found',
                message: 'This saved receipt is no longer available.',
              );
            }
            return _ReceiptDetailBody(receipt: receipt);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SyncEmptyState(
            icon: SyncIcons.receipt,
            title: 'Could not open receipt',
            message: 'Try again from the receipt history.',
          ),
        ),
      ),
    );
    return BackButtonListener(
      onBackButtonPressed: () async {
        _returnToReceipts(context);
        return true;
      },
      child: PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _returnToReceipts(context);
          }
        },
        child: content,
      ),
    );
  }

  static void _returnToReceipts(BuildContext context) {
    SyncHaptics.selection();
    context.go('/receipts');
  }
}

class _ReceiptDetailBody extends StatelessWidget {
  const _ReceiptDetailBody({required this.receipt});

  final SavedReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back to Receipts',
                onPressed: () => ReceiptDetailScreen._returnToReceipts(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  'Your receipt',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Receipt options',
                onPressed: null,
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            children: [
              ReceiptPaperPreview(
                title: receipt.title,
                items: receipt.items,
                includeFolderLabels: receipt.includeFolderLabels,
                createdAt: receipt.createdAt,
                displayNumber: receipt.displayNumber,
                drawingStrokesJson: receipt.drawingStrokesJson,
              ),
              const SizedBox(height: 18),
              Text(
                'Replay coming soon',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: null,
                  child: const Text('Share receipt'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ReceiptDetailScreen._returnToReceipts(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReceiptUnavailableScreen extends StatelessWidget {
  const _ReceiptUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SyncTasksColorScheme.of(context).scaffold,
      body: const SafeArea(
        child: SyncEmptyState(
          icon: SyncIcons.receipt,
          title: 'Receipts are not available',
          message: 'This internal feature is hidden in this build.',
        ),
      ),
    );
  }
}
