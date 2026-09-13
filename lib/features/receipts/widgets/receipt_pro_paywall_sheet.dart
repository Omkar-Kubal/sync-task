import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/sheets/app_sheet_shadow.dart';
import '../../../shared/services/sync_haptics.dart';
import '../data/receipt_repository.dart';
import '../pro/receipt_pro_entitlement.dart';
import '../pro/receipt_pro_products.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(receiptProEntitlementProvider.notifier).clearTransientMessage();
    });
  }

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

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.56,
        alignment: Alignment.bottomCenter,
        child: DecoratedBox(
          key: const ValueKey('receipt-pro-paywall-surface'),
          decoration: AppSheetShadow.decoration(color: colors.scaffold),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                            key: const ValueKey('receipt-pro-paywall-scroll'),
                            padding: EdgeInsets.fromLTRB(
                              18 + mediaQuery.padding.left,
                              18,
                              18 + mediaQuery.padding.right,
                              126,
                            ),
                            child: _ReceiptProPaywallContent(
                              status: widget.status,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _ReceiptProCheckout(
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
                  ),
                  Positioned(
                    top: 14,
                    left: 18 + mediaQuery.padding.left,
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
    );
  }
}

class _ReceiptProPaywallContent extends StatelessWidget {
  const _ReceiptProPaywallContent({required this.status});

  final ReceiptQuotaStatus? status;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _PaywallHeroLockup(),
        const SizedBox(height: 8),
        if (status == null)
          const _PaywallQuotaIntroCard()
        else
          _PaywallStatusCard(status: status!),
        const SizedBox(height: 8),
        _PaywallBenefitList(colors: colors, textTheme: textTheme),
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
    final buttonLabel = active
        ? 'Unlimited receipts active'
        : busy
        ? _busyLabel(state)
        : pending
        ? 'Payment pending'
        : 'Unlock for $price';
    final disabledButtonTextColor =
        Theme.of(context).brightness == Brightness.dark
        ? colors.textPrimary.withValues(alpha: 0.72)
        : colors.controlForeground.withValues(alpha: 0.72);
    final buttonTextColor = checkoutEnabled || active
        ? colors.controlForeground
        : disabledButtonTextColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LifetimeOption(plan: plan, colors: colors, textTheme: textTheme),
            const SizedBox(height: 2),
            _CheckoutSupportRow(
              message: _billingMessage(entitlement, state, plan),
              busy: busy,
              onRestore: onRestore,
              colors: colors,
              textTheme: textTheme,
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 34,
              child: FilledButton(
                onPressed: checkoutEnabled ? onBuy : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.controlPrimary,
                  foregroundColor: colors.controlForeground,
                  disabledBackgroundColor: colors.controlPrimary.withValues(
                    alpha: 0.18,
                  ),
                  disabledForegroundColor: buttonTextColor,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  buttonLabel,
                  style: textTheme.labelLarge?.copyWith(
                    color: buttonTextColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
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

class _PaywallHeroLockup extends StatelessWidget {
  const _PaywallHeroLockup();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        const _PaywallLogoMark(),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'SyncTasks',
                  key: const ValueKey('receipt-pro-brand-title'),
                  maxLines: 1,
                  style: textTheme.displaySmall?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            const _PaywallProBadge(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Unlimited receipts for your completed work.',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _PaywallLogoMark extends StatelessWidget {
  const _PaywallLogoMark();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      key: const ValueKey('receipt-pro-logo-mark'),
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colors.divider, width: 1.5),
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}

class _PaywallProBadge extends StatelessWidget {
  const _PaywallProBadge();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('receipt-pro-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.textPrimary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'PRO',
        style: textTheme.labelLarge?.copyWith(
          color: colors.scaffold,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          height: 1,
        ),
      ),
    );
  }
}

class _LifetimeOption extends StatelessWidget {
  const _LifetimeOption({
    required this.plan,
    required this.colors,
    required this.textTheme,
  });

  final ReceiptProPlan? plan;
  final SyncTasksColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final price = plan?.price ?? '₹199';
    return Semantics(
      selected: true,
      label: 'Lifetime, $price',
      child: Container(
        key: const ValueKey('receipt-pro-lifetime-option-card'),
        height: 40,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.textPrimary, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.textPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(SyncIcons.check, color: colors.scaffold, size: 14),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lifetime',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'One-time receipt upgrade',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      height: 1.18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 68,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  price,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineBillingStatus extends StatelessWidget {
  const _InlineBillingStatus({required this.message, required this.colors});

  final String message;
  final SyncTasksColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1.18,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _CheckoutSupportRow extends StatelessWidget {
  const _CheckoutSupportRow({
    required this.message,
    required this.busy,
    required this.onRestore,
    required this.colors,
    required this.textTheme,
  });

  final String? message;
  final bool busy;
  final VoidCallback onRestore;
  final SyncTasksColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final restoreButton = TextButton(
      onPressed: busy ? null : onRestore,
      style: TextButton.styleFrom(
        minimumSize: const Size(84, 26),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        'Restore purchases',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.labelLarge?.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );

    if (message == null) {
      return Align(alignment: Alignment.centerRight, child: restoreButton);
    }

    return Row(
      children: [
        Expanded(
          child: _InlineBillingStatus(message: message!, colors: colors),
        ),
        const SizedBox(width: 4),
        restoreButton,
      ],
    );
  }
}

class _PaywallCloseButton extends StatelessWidget {
  const _PaywallCloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return SizedBox.square(
      dimension: 36,
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
        icon: const Icon(Icons.close_rounded, size: 20),
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PaywallIconTile(icon: SyncIcons.receipt, colors: colors),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3 free receipts weekly',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Pro unlocks unlimited receipt generation whenever you need it.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.22,
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PaywallIconTile(icon: SyncIcons.receipt, colors: colors),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${status.freeLimit} of ${status.freeLimit} free receipts used',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'You’ve used your weekly free quota.\n'
                    'Free receipts reset ${_resetDateLabel(status.weekEndExclusive)}.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.22,
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

class _PaywallBenefitList extends StatelessWidget {
  const _PaywallBenefitList({required this.colors, required this.textTheme});

  final SyncTasksColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaywallBenefitRow(
          icon: Icons.all_inclusive_rounded,
          title: 'Unlimited receipts',
          body: 'Generate as many receipts as you need.',
          colors: colors,
          textTheme: textTheme,
        ),
        const SizedBox(height: 7),
        _PaywallBenefitRow(
          icon: SyncIcons.folder,
          title: 'Your data stays safe',
          body: 'Saved receipts and all task features stay free.',
          colors: colors,
          textTheme: textTheme,
        ),
      ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _PaywallIconTile(icon: icon, colors: colors),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                  height: 1.14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.22,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
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
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: colors.textPrimary, size: 18),
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
