import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../data/receipt_repository.dart';
import '../pro/receipt_pro_entitlement.dart';
import '../pro/receipt_pro_products.dart';
import 'receipt_paper.dart';

Future<bool?> showReceiptProPaywallSheet({
  required BuildContext context,
  ReceiptQuotaStatus? status,
  List<Task> tasks = const <Task>[],
  String title = "Today's wins",
}) {
  SyncHaptics.selection();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.24),
    builder: (context) {
      return ReceiptProPaywallSheet(status: status, tasks: tasks, title: title);
    },
  );
}

class ReceiptProPaywallSheet extends ConsumerStatefulWidget {
  const ReceiptProPaywallSheet({
    required this.status,
    required this.tasks,
    required this.title,
    super.key,
  });

  final ReceiptQuotaStatus? status;
  final List<Task> tasks;
  final String title;

  @override
  ConsumerState<ReceiptProPaywallSheet> createState() =>
      _ReceiptProPaywallSheetState();
}

class _ReceiptProPaywallSheetState
    extends ConsumerState<ReceiptProPaywallSheet> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ReceiptProEntitlementState>>(
      receiptProEntitlementProvider,
      (previous, next) {
        final previousState = previous?.value;
        final nextState = next.value;
        if (nextState == null || !context.mounted) {
          return;
        }
        if (nextState.isPro && previousState?.isPro != true) {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop(true);
          }
        }
      },
    );

    final colors = SyncTasksColorScheme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final entitlement = ref.watch(receiptProEntitlementProvider);
    final entitlementState = entitlement.value;
    final initializing = entitlement.isLoading && !entitlement.hasValue;
    final plan = entitlementState?.catalog.unlimitedReceipts;
    final busy =
        initializing ||
        entitlementState?.status ==
            ReceiptProEntitlementStatus.catalogLoading ||
        entitlementState?.status == ReceiptProEntitlementStatus.purchasing ||
        entitlementState?.status == ReceiptProEntitlementStatus.restoring;
    final pending =
        entitlementState?.status == ReceiptProEntitlementStatus.pending;
    final checkoutEnabled =
        !busy &&
        !pending &&
        entitlementState?.isPro != true &&
        plan?.available == true &&
        plan?.price != null;

    return SafeArea(
      top: true,
      bottom: false,
      child: ColoredBox(
        color: colors.scaffold,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.9,
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: ColoredBox(
                color: colors.scaffold,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      key: const ValueKey('receipt-pro-paywall-sheet'),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                20 + mediaQuery.padding.left,
                                34,
                                20 + mediaQuery.padding.right,
                                20,
                              ),
                              child: _ReceiptProPaywallContent(
                                status: widget.status,
                                tasks: widget.tasks,
                                title: widget.title,
                              ),
                            ),
                          ),
                          _ReceiptProCheckout(
                            entitlement: entitlement,
                            state: entitlementState,
                            plan: plan,
                            busy: busy,
                            pending: pending,
                            checkoutEnabled: checkoutEnabled,
                            onBuy: () {
                              SyncHaptics.selection();
                              ref
                                  .read(receiptProEntitlementProvider.notifier)
                                  .buyUnlimitedReceipts();
                            },
                            onRestore: () {
                              SyncHaptics.selection();
                              ref
                                  .read(receiptProEntitlementProvider.notifier)
                                  .restore();
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 18,
                      right: 20 + mediaQuery.padding.right,
                      child: _PaywallCloseButton(
                        onClose: () => Navigator.of(context).maybePop(false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptProPaywallContent extends StatelessWidget {
  const _ReceiptProPaywallContent({
    required this.status,
    required this.tasks,
    required this.title,
  });

  final ReceiptQuotaStatus? status;
  final List<Task> tasks;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final previewItems = [
      for (var i = 0; i < tasks.length; i++)
        SavedReceiptItem(
          taskId: tasks[i].id,
          position: i,
          title: tasks[i].title,
          completedAt: tasks[i].completedAt ?? DateTime.now(),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 66),
        Text(
          'Unlimited\nreceipts',
          style: textTheme.displaySmall?.copyWith(
            color: colors.textPrimary,
            fontSize: 42,
            fontWeight: FontWeight.w800,
            height: 1.02,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Keep a record of your completed work.',
          style: textTheme.titleMedium?.copyWith(
            color: colors.textSecondary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.22,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 26),
        Center(
          child: SizedBox(
            height: 304,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              child: ReceiptPaperPreview(
                title: title.trim().isEmpty ? "Today's wins" : title,
                items: previewItems,
                includeFolderLabels: false,
                showReceiptMetadata: false,
                paperScale: ReceiptPaperScale.printing,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (status == null)
          const _PaywallQuotaIntroCard()
        else
          _PaywallStatusCard(status: status!),
        const SizedBox(height: 14),
        _PaywallBenefitCard(colors: colors, textTheme: textTheme),
      ],
    );
  }
}

class _ReceiptProCheckout extends StatelessWidget {
  const _ReceiptProCheckout({
    required this.entitlement,
    required this.state,
    required this.plan,
    required this.busy,
    required this.pending,
    required this.checkoutEnabled,
    required this.onBuy,
    required this.onRestore,
  });

  final AsyncValue<ReceiptProEntitlementState> entitlement;
  final ReceiptProEntitlementState? state;
  final ReceiptProPlan? plan;
  final bool busy;
  final bool pending;
  final bool checkoutEnabled;
  final VoidCallback onBuy;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final price = plan?.price ?? '₹199';
    final active = state?.isPro == true;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: colors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: checkoutEnabled ? onBuy : null,
              child: Text(
                active
                    ? 'Unlimited receipts active'
                    : busy
                    ? _busyLabel(state)
                    : pending
                    ? 'Payment pending'
                    : 'Unlock for $price',
              ),
            ),
            if (_billingMessage(entitlement, state, plan)
                case final message?) ...[
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: busy ? null : onRestore,
              child: const Text('Restore purchases'),
            ),
          ],
        ),
      ),
    );
  }

  String _busyLabel(ReceiptProEntitlementState? state) {
    return switch (state?.status) {
      ReceiptProEntitlementStatus.purchasing => 'Opening Google Play...',
      ReceiptProEntitlementStatus.restoring => 'Checking purchases...',
      _ => 'Loading price...',
    };
  }

  String? _billingMessage(
    AsyncValue<ReceiptProEntitlementState> entitlement,
    ReceiptProEntitlementState? state,
    ReceiptProPlan? plan,
  ) {
    if (entitlement.isLoading && !entitlement.hasValue) {
      return 'Loading Google Play price...';
    }
    if (state?.isPro == true) {
      return 'Unlimited receipts are active.';
    }
    if (state?.message != null) {
      return state!.message;
    }
    return plan?.unavailableReason;
  }
}

class _PaywallCloseButton extends StatelessWidget {
  const _PaywallCloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return SizedBox.square(
      dimension: 56,
      child: IconButton(
        tooltip: 'Close',
        onPressed: () {
          SyncHaptics.selection();
          onClose();
        },
        style: IconButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.divider),
          shape: const CircleBorder(),
        ),
        icon: const Icon(Icons.close_rounded, size: 32),
      ),
    );
  }
}

class _PaywallQuotaIntroCard extends StatelessWidget {
  const _PaywallQuotaIntroCard();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PaywallIconTile(icon: SyncIcons.receipt, colors: colors),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3 free receipts weekly',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pro unlocks unlimited receipt generation whenever you need it.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.28,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaywallStatusCard extends StatelessWidget {
  const _PaywallStatusCard({required this.status});

  final ReceiptQuotaStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PaywallIconTile(icon: SyncIcons.receipt, colors: colors),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${status.freeLimit} of ${status.freeLimit} free receipts used',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You’ve used your weekly free quota.\n'
                    'Free receipts reset ${_resetDateLabel(status.weekEndExclusive)}.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.28,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaywallBenefitCard extends StatelessWidget {
  const _PaywallBenefitCard({required this.colors, required this.textTheme});

  final SyncTasksColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _PaywallBenefitRow(
            icon: Icons.all_inclusive_rounded,
            title: 'Unlimited receipts',
            body: 'Generate as many receipts as you need.',
            colors: colors,
            textTheme: textTheme,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 74, right: 18),
            child: Divider(height: 1, color: colors.divider),
          ),
          _PaywallBenefitRow(
            icon: SyncIcons.folder,
            title: 'Your data stays safe',
            body: 'Saved receipts and all task features stay free.',
            colors: colors,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _PaywallBenefitRow extends StatelessWidget {
  const _PaywallBenefitRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.colors,
    required this.textTheme,
  });

  final IconData icon;
  final String title;
  final String body;
  final SyncTasksColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PaywallIconTile(icon: icon, colors: colors),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaywallIconTile extends StatelessWidget {
  const _PaywallIconTile({required this.icon, required this.colors});

  final IconData icon;
  final SyncTasksColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: colors.textPrimary, size: 24),
    );
  }
}

String _resetDateLabel(DateTime value) {
  final month = switch (value.month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sept',
    10 => 'Oct',
    11 => 'Nov',
    _ => 'Dec',
  };
  return '${DateFormat('EEEE').format(value)}, ${value.day} $month';
}
