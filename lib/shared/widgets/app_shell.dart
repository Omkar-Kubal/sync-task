import 'package:flutter/material.dart';

import '../motion/sync_motion.dart';
import 'sync_bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _slideDistance = SyncMotion.pageSlideDistance;

  var _animatePageSwitch = false;
  var _slideDirection = 0;

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final sameTab = widget.currentIndex == oldWidget.currentIndex;
    final includesTopBarRoute =
        widget.currentIndex < 0 || oldWidget.currentIndex < 0;
    _animatePageSwitch = !sameTab && !includesTopBarRoute;
    _slideDirection = _animatePageSwitch
        ? (widget.currentIndex > oldWidget.currentIndex ? 1 : -1)
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: _animatePageSwitch
              ? SyncMotion.pageDuration
              : Duration.zero,
          reverseDuration: _animatePageSwitch
              ? SyncMotion.pageReverseDuration
              : Duration.zero,
          transitionBuilder: (child, animation) {
            if (!_animatePageSwitch) {
              return child;
            }
            final position = animation.drive(
              Tween<Offset>(
                begin: Offset(_slideDirection * _slideDistance, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: SyncMotion.standardCurve)),
            );
            final opacity = animation.drive(
              Tween<double>(
                begin: 0.94,
                end: 1,
              ).chain(CurveTween(curve: SyncMotion.enterCurve)),
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
          SyncBottomNav(
            currentIndex: widget.currentIndex,
            onTap: widget.onDestinationSelected,
          ),
        ],
      ),
    );
  }
}


