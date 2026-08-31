import 'package:flutter/material.dart';

import 'sync_bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
    this.activeFocusBar,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final Widget? activeFocusBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (activeFocusBar != null) activeFocusBar!,
          SyncBottomNav(
            currentIndex: currentIndex,
            onTap: onDestinationSelected,
          ),
        ],
      ),
    );
  }
}
