import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/focus/screens/focus_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/lists/screens/lists_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/tasks/screens/today_screen.dart';
import '../../features/tasks/screens/upcoming_screen.dart';
import '../../shared/widgets/app_shell.dart';

GoRouter appRouter() {
  return GoRouter(
    initialLocation: '/today',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final location = state.uri.path;
          return AppShell(
            currentIndex: _navIndex(location),
            onDestinationSelected: (index) => context.go(_navPath(index)),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/today',
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: '/today/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/upcoming',
            builder: (context, state) => const UpcomingScreen(),
          ),
          GoRoute(
            path: '/focus',
            builder: (context, state) => const FocusScreen(),
          ),
          GoRoute(
            path: '/focus/attach-task',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Attach Task'))),
          ),
          GoRoute(
            path: '/focus/insights',
            builder: (context, state) => const InsightsScreen(),
          ),
          GoRoute(
            path: '/lists',
            builder: (context, state) => const ListsScreen(),
          ),
          GoRoute(
            path: '/lists/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

int _navIndex(String location) {
  if (location.startsWith('/upcoming')) {
    return 1;
  }
  if (location.startsWith('/focus')) {
    return 2;
  }
  if (location.startsWith('/lists')) {
    return 3;
  }
  return 0;
}

String _navPath(int index) {
  return switch (index) {
    0 => '/today',
    1 => '/upcoming',
    2 => '/focus',
    3 => '/lists',
    _ => '/today',
  };
}
