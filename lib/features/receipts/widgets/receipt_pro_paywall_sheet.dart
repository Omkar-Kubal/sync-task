import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/sheets/app_sheet_shadow.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/widgets/sync_button.dart';
import '../../../shared/widgets/sync_grouped_section.dart';
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
      child: ConstrainedBox(
        key: const ValueKey('receipt-pro-paywall-sheet'),
        constraints: BoxConstraints(
          minHeight: mediaQuery.size.height * 0.70,
          maxHeight: mediaQuery.size.height * 0.85,
          minWidth: double.infinity,
        ),
        child: DecoratedBox(
          key: const ValueKey('receipt-pro-paywall-surface'),
          decoration: AppSheetShadow.decoration(color: colors.scaffold),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: ColoredBox(
              color: colors.scaffold,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  key: const ValueKey('receipt-pro-paywall-scroll'),
                  padding: EdgeInsets.fromLTRB(
                    24 + mediaQuery.padding.left,
                    20,
                    24 + mediaQuery.padding.right,
                    20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PaywallHeaderLockup(
                        onClose: () => Navigator.of(context).maybePop(false),
                      ),
                      const SizedBox(height: 24),
                      _ReceiptProPaywallContent(status: widget.status),
                      const SizedBox(height: 20),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaywallHeaderLockup extends StatelessWidget {
  const _PaywallHeaderLockup({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        _PaywallCloseButton(onClose: onClose),
        const SizedBox(width: 8),
        const _PaywallLogoMark(),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'SyncTasks',
                      key: const ValueKey('receipt-pro-brand-title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const _PaywallProBadge(),
                ],
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Unlimited receipts for your completed work.',
                    maxLines: 1,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        _PaywallValuePanel(
          status: status,
          colors: colors,
          textTheme: textTheme,
        ),
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
    final price = plan?.price;
    final active = state?.isPro == true;
    final buttonLabel = active
        ? 'Unlimited receipts active'
        : busy
        ? _busyLabel(state)
        : pending
        ? 'Payment pending'
        : checkoutEnabled && price != null
        ? 'Unlock for $price'
        : 'Price unavailable';
    final message = _billingMessage(entitlement, state, plan);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LifetimeOption(plan: plan, colors: colors, textTheme: textTheme),
        if (message != null) ...[
          const SizedBox(height: 8),
          _InlineBillingStatus(message: message, colors: colors),
        ],
        const SizedBox(height: 16),
        SyncButton.primary(
          label: buttonLabel,
          onPressed: checkoutEnabled ? onBuy : null,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: busy ? null : onRestore,
            child: Text(
              'Restore purchases',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
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

class _PaywallLogoMark extends StatelessWidget {
  const _PaywallLogoMark();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      key: const ValueKey('receipt-pro-logo-mark'),
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.controlPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: colors.divider, width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo-whitebackground.png',
          fit: BoxFit.cover,
        ),
      ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SyncIcons.premium,
            color: SyncIcons.premiumSilverOnFilled(context),
            size: 10,
          ),
          const SizedBox(width: 3),
          Text(
            'PRO',
            style: textTheme.labelLarge?.copyWith(
              color: colors.scaffold,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1,
            ),
          ),
        ],
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
    final price = plan?.price;
    final priceLabel = price ?? 'Price unavailable';
    return Semantics(
      selected: true,
      label: 'Lifetime, $priceLabel',
      child: Container(
        key: const ValueKey('receipt-pro-lifetime-option-card'),
        height: 56,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.textPrimary),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.textPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                SyncIcons.premium,
                color: SyncIcons.premiumSilverOnFilled(context),
                size: 15,
              ),
            ),
            const SizedBox(width: 12),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    'One-time receipt upgrade',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 72,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  priceLabel,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
      dimension: 46,
      child: IconButton(
        tooltip: 'Close',
        onPressed: () {
          SyncHaptics.selection();
          onClose();
        },
        style: IconButton.styleFrom(
          fixedSize: const Size(46, 46),
          minimumSize: const Size(46, 46),
          padding: EdgeInsets.zero,
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
          side: BorderSide.none,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const CircleBorder(),
        ),
        icon: const Icon(Icons.close_rounded, size: 24),
      ),
    );
  }
}

class _PaywallValuePanel extends StatelessWidget {
  const _PaywallValuePanel({
    required this.status,
    required this.colors,
    required this.textTheme,
  });

  final ReceiptQuotaStatus? status;
  final SyncTasksColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SyncGroupedSection(
      key: const ValueKey('receipt-pro-value-panel'),
      children: [
        if (status == null)
          _PaywallQuotaIntroCard(colors: colors, textTheme: textTheme)
        else
          _PaywallStatusCard(
            status: status!,
            colors: colors,
            textTheme: textTheme,
          ),
        _PaywallPanelDivider(colors: colors),
        _PaywallBenefitRow(
          icon: Icons.all_inclusive_rounded,
          title: 'Unlimited receipts',
          body: 'Generate as many receipts as you need.',
          colors: colors,
          textTheme: textTheme,
        ),
        _PaywallPanelDivider(colors: colors),
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

class _PaywallPanelDivider extends StatelessWidget {
  const _PaywallPanelDivider({required this.colors});

  final SyncTasksColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 72, endIndent: 16, color: colors.divider);
  }
}

class _PaywallQuotaIntroCard extends StatelessWidget {
  const _PaywallQuotaIntroCard({required this.colors, required this.textTheme});

  final SyncTasksColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return _PaywallFeatureRow(
      icon: SyncIcons.receipt,
      title: '3 free receipts weekly',
      body: 'Pro unlocks unlimited receipt generation whenever you need it.',
      colors: colors,
      textTheme: textTheme,
    );
  }
}

class _PaywallStatusCard extends StatelessWidget {
  const _PaywallStatusCard({
    required this.status,
    required this.colors,
    required this.textTheme,
  });

  final ReceiptQuotaStatus status;
  final SyncTasksColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return _PaywallFeatureRow(
      icon: SyncIcons.receipt,
      title: '${status.freeLimit} of ${status.freeLimit} free receipts used',
      body:
          'You’ve used your weekly free quota.\n'
          'Free receipts reset ${_resetDateLabel(status.weekEndExclusive)}.',
      colors: colors,
      textTheme: textTheme,
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
    return _PaywallFeatureRow(
      icon: icon,
      title: title,
      body: body,
      colors: colors,
      textTheme: textTheme,
    );
  }
}

class _PaywallFeatureRow extends StatelessWidget {
  const _PaywallFeatureRow({
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
    return ListTile(
      minVerticalPadding: 6,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _PaywallIconTile(icon: icon, colors: colors),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          color: colors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
      subtitle: Text(
        body,
        style: textTheme.bodyLarge?.copyWith(
          color: colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
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
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: colors.textPrimary, size: 20),
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
