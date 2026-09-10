import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/widgets/sync_empty_state.dart';
import '../data/receipt_repository.dart';
import '../domain/receipt_composer_seed.dart';
import '../providers/receipt_feature_provider.dart';
import '../providers/receipt_repository_provider.dart';

class ReceiptHistoryScreen extends ConsumerWidget {
  const ReceiptHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(receiptFeatureEnabledProvider);
    final historyValue = ref.watch(receiptHistoryProvider);
    final colors = SyncTasksColorScheme.of(context);
    final content = Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReceiptHistoryHeader(onBack: () => _returnToLists(context)),
            Expanded(
              child: !enabled
                  ? const SyncEmptyState(
                      icon: SyncIcons.receipt,
                      title: 'Receipts are hidden',
                      message: 'This internal feature is hidden in this build.',
                    )
                  : historyValue.when(
                      data: (receipts) {
                        if (receipts.isEmpty) {
                          return SyncEmptyState(
                            icon: SyncIcons.receipt,
                            title: 'No receipts yet',
                            message: 'Your completed work, worth keeping.',
                            actionLabel: 'Create receipt',
                            onAction: () => context.go(
                              '/receipts/new',
                              extra: const ReceiptComposerSeed.empty(),
                            ),
                          );
                        }
                        return _ReceiptHistoryList(receipts: receipts);
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const SyncEmptyState(
                        icon: SyncIcons.receipt,
                        title: 'Could not load receipts',
                        message: 'Try opening receipt history again.',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
    return BackButtonListener(
      onBackButtonPressed: () async {
        _returnToLists(context);
        return true;
      },
      child: PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _returnToLists(context);
          }
        },
        child: content,
      ),
    );
  }

  void _returnToLists(BuildContext context) {
    SyncHaptics.selection();
    context.go('/lists');
  }
}

class _ReceiptHistoryHeader extends StatelessWidget {
  const _ReceiptHistoryHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 20, 14),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to Lists',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Receipts',
              style: textTheme.titleLarge?.copyWith(color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptHistoryList extends StatelessWidget {
  const _ReceiptHistoryList({required this.receipts});

  final List<ReceiptListItem> receipts;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
      itemCount: receipts.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == receipts.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilledButton.icon(
              onPressed: () {
                SyncHaptics.action();
                context.go(
                  '/receipts/new',
                  extra: const ReceiptComposerSeed.empty(),
                );
              },
              icon: const Icon(SyncIcons.receipt),
              label: const Text('Create receipt'),
            ),
          );
        }
        return _ReceiptHistoryRow(receipt: receipts[index]);
      },
    );
  }
}

class _ReceiptHistoryRow extends StatelessWidget {
  const _ReceiptHistoryRow({required this.receipt});

  final ReceiptListItem receipt;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final date = DateFormat('d MMM yyyy').format(receipt.createdAt);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          SyncHaptics.selection();
          context.go('/receipts/${receipt.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(SyncIcons.receipt, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_taskCountLabel(receipt.taskCount)} · $date',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  String _taskCountLabel(int count) => count == 1 ? '1 task' : '$count tasks';
}
