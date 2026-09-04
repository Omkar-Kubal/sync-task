import 'package:flutter/material.dart';

import 'sync_bottom_nav.dart';

class AppShell extends StatefulWidget {
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
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _slideDistance = 0.22;

  var _slideDirection = 0;

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _slideDirection = widget.currentIndex == oldWidget.currentIndex
        ? 0
        : (widget.currentIndex > oldWidget.currentIndex ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 340),
          reverseDuration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final position = animation.drive(
              Tween<Offset>(
                begin: Offset(_slideDirection * _slideDistance, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOutCubic)),
            );
            final opacity = animation.drive(
              Tween<double>(
                begin: 0.86,
                end: 1,
              ).chain(CurveTween(curve: Curves.easeOut)),
            );
            return SlideTransition(
              key: const Key('nav-page-slide'),
              position: position,
              child: FadeTransition(opacity: opacity, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(widget.currentIndex),
            child: widget.child,
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.activeFocusBar != null) widget.activeFocusBar!,
          SyncBottomNav(
            currentIndex: widget.currentIndex,
            onTap: widget.onDestinationSelected,
          ),
        ],
      ),
    );
  }
}
