import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'receipt_pro_entitlement.dart';

class ReceiptProEntitlementLifecycle extends ConsumerStatefulWidget {
  const ReceiptProEntitlementLifecycle({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ReceiptProEntitlementLifecycle> createState() =>
      _ReceiptProEntitlementLifecycleState();
}

class _ReceiptProEntitlementLifecycleState
    extends ConsumerState<ReceiptProEntitlementLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(receiptProEntitlementProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(
      ref
          .read(receiptProEntitlementProvider.notifier)
          .reconcile(source: 'resume'),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
