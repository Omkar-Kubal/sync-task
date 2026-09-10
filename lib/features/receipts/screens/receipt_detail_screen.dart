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
import '../widgets/receipt_screen_chrome.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReceiptScreenHeader(
          title: 'Your receipt',
          backTooltip: 'Back to Receipts',
          onBack: () => ReceiptDetailScreen._returnToReceipts(context),
          trailing: IconButton(
            tooltip: 'Receipt options',
            onPressed: null,
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.56,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: ReceiptPaperPreview(
                    title: receipt.title,
                    items: receipt.items,
                    includeFolderLabels: receipt.includeFolderLabels,
                    createdAt: receipt.createdAt,
                    displayNumber: receipt.displayNumber,
                    drawingStrokesJson: receipt.drawingStrokesJson,
                    photoPath: receipt.photoPath,
                    paperScale: ReceiptPaperScale.detail,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Drag to play',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ReceiptBottomActionBar(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing comes next.')),
                  );
                },
                child: const Text('Share receipt'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ReceiptDetailScreen._returnToReceipts(context),
                child: const Text('Done'),
              ),
            ],
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
