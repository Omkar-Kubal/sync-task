import 'package:go_router/go_router.dart';


import '../../features/insights/screens/insights_screen.dart';
import '../../features/lists/screens/black_placeholder_screen.dart';
import '../../features/lists/screens/list_detail_screen.dart';
import '../../features/lists/screens/lists_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/receipts/domain/receipt_composer_seed.dart';
import '../../features/receipts/screens/receipt_composer_screen.dart';
import '../../features/receipts/screens/receipt_detail_screen.dart';
import '../../features/receipts/screens/receipt_history_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/tasks/screens/quick_add_screen.dart';
import '../../features/tasks/screens/today_screen.dart';
import '../../features/tasks/screens/upcoming_screen.dart';
import '../../shared/widgets/app_shell.dart';

GoRouter appRouter() {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final uri = state.uri;
      if (uri.scheme == 'synctasks' && uri.host == 'today') {
        return '/today';
      }
      if (uri.path.startsWith('/focus')) {
        return '/today';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(backToToday: true),
      ),
      GoRoute(
        path: '/quick-add',
        builder: (context, state) => const QuickAddScreen(),
      ),
      GoRoute(
        path: '/receipts/new',
        builder: (context, state) {
          final extra = state.extra;
          return ReceiptComposerScreen(
            seed: extra is ReceiptComposerSeed
                ? extra
                : const ReceiptComposerSeed.empty(),
          );
        },
      ),
      GoRoute(
        path: '/receipts/:id',
        builder: (context, state) {
          return ReceiptDetailScreen(
            receiptId: state.pathParameters['id'] ?? '',
          );
        },
      ),
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
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: UpcomingScreen()),
          ),
          GoRoute(
            path: '/receipts',
            builder: (context, state) => const ReceiptHistoryScreen(),
          ),
          GoRoute(
            path: '/lists',
            builder: (context, state) => const ListsScreen(),
            routes: [
              GoRoute(
                path: 'more',
                builder: (context, state) => const BlackPlaceholderScreen(),
              ),
              GoRoute(
                path: 'all',
                builder: (context, state) => const AllTasksScreen(),
              ),
              GoRoute(
                path: 'completed',
                builder: (context, state) => const CompletedTasksScreen(),
              ),
              GoRoute(
                path: 'inbox',
                builder: (context, state) => const InboxTasksScreen(),
              ),
              GoRoute(
                path: 'folder/:id',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  if (id == null) {
                    return const FolderTasksScreen(folderId: -1);
                  }
                  return FolderTasksScreen(folderId: id);
                },
              ),
              GoRoute(
                path: 'reminders',
                builder: (context, state) => const RemindersScreen(),
              ),
              GoRoute(
                path: 'insights',
                builder: (context, state) => const ConnectedInsightsScreen(),
              ),
              GoRoute(path: 'notion', redirect: (context, state) => '/lists'),
              GoRoute(
                path: 'settings',
                redirect: (context, state) => '/settings',
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

int _navIndex(String location) {
  if (location.startsWith('/lists') || location.startsWith('/receipts')) {
    return 1;
  }
  return 0;
}

String _navPath(int index) {
  return switch (index) {
    0 => '/today',
    1 => '/lists',
    _ => '/today',
  };
}
