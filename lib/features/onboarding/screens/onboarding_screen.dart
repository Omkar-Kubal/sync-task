import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../features/settings/providers/settings_controller.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/widgets/sync_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  var _pageIndex = 0;

  static const _pages = [
    _OnboardingPageData(
      title: 'Plan today with less noise',
      body:
          'SyncTasks keeps your tasks, reminders, and lists simple, local, and ready when you are.',
      visual: _OnboardingVisual.welcome,
    ),
    _OnboardingPageData(
      title: 'Start with Today',
      body:
          'Add what matters now, schedule it for today, and clear it when it is done.',
      visual: _OnboardingVisual.today,
    ),
    _OnboardingPageData(
      title: 'Move work out of your head',
      body:
          'Send tasks to Tomorrow, Next Week, or a custom date without leaving the task sheet.',
      visual: _OnboardingVisual.schedule,
    ),
    _OnboardingPageData(
      title: 'Widgets on your Home Screen',
      body:
          'Track today\'s progress, quick add new tasks, and view your checklist right from your home screen.',
      visual: _OnboardingVisual.widgets,
    ),
    _OnboardingPageData(
      title: 'Keep projects tidy',
      body:
          'Use Inbox by default, then organize tasks into folders when a list needs its own place.',
      visual: _OnboardingVisual.lists,
    ),
    _OnboardingPageData(
      title: 'Ready when you are',
      body:
          'Your tasks stay on this device. You can change notifications, appearance, and haptics later in Settings.',
      visual: _OnboardingVisual.finish,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final isLastPage = _pageIndex == _pages.length - 1;

    return PopScope<void>(
      canPop: _pageIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _pageIndex > 0) {
          _previousPage();
        }
      },
      child: Scaffold(
        backgroundColor: colors.scaffold,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              children: [
                const _OnboardingTopBar(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _pageIndex = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(data: _pages[index]);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _ProgressDots(
                  pageCount: _pages.length,
                  activeIndex: _pageIndex,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: isLastPage
                            ? 'Get Started'
                            : 'Next onboarding page',
                        child: SyncButton.primary(
                          label: isLastPage ? 'Get Started' : '->',
                          height: 52,
                          onPressed: isLastPage
                              ? _completeOnboarding
                              : _nextPage,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _nextPage() {
    SyncHaptics.selection();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _previousPage() {
    SyncHaptics.selection();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _completeOnboarding() async {
    SyncHaptics.action();
    await ref.read(settingsControllerProvider).completeOnboarding();
    if (mounted) {
      context.go('/today');
    }
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 34,
            height: 34,
            fit: BoxFit.contain,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 248,
                  child: _OnboardingVisualPanel(visual: data.visual),
                ),
                SizedBox(height: constraints.maxHeight < 520 ? 18 : 30),
                Text(
                  data.title,
                  textAlign: TextAlign.left,
                  style: textTheme.displaySmall?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 31,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.body,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 15,
                    height: 1.42,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingVisualPanel extends StatelessWidget {
  const _OnboardingVisualPanel({required this.visual});

  final _OnboardingVisual visual;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: switch (visual) {
        _OnboardingVisual.welcome => const _WelcomeVisual(),
        _OnboardingVisual.today => const _TodayVisual(),
        _OnboardingVisual.schedule => const _ScheduleVisual(),
        _OnboardingVisual.widgets => const _WidgetsVisual(),
        _OnboardingVisual.lists => const _ListsVisual(),
        _OnboardingVisual.finish => const _FinishVisual(),
      },
    );
  }
}

class _WelcomeVisual extends StatelessWidget {
  const _WelcomeVisual();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      width: 184,
      height: 184,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surface.withValues(alpha: 0.86),
        boxShadow: [
          BoxShadow(
            color: colors.controlPrimary.withValues(alpha: 0.14),
            blurRadius: 42,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          key: const Key('onboarding-welcome-logo'),
          width: 108,
          height: 108,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _TodayVisual extends StatelessWidget {
  const _TodayVisual();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      width: 214,
      height: 226,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: colors.controlPrimary.withValues(alpha: 0.13),
            blurRadius: 34,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/logo.png',
        key: const Key('onboarding-today-app-image'),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) {
          return DecoratedBox(
            decoration: BoxDecoration(color: colors.surfaceSecondary),
            child: Center(
              child: Icon(
                Icons.today_rounded,
                color: colors.textSecondary,
                size: 42,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScheduleVisual extends StatelessWidget {
  const _ScheduleVisual();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SchedulePreviewRow(icon: SyncIcons.tomorrow, label: 'Tomorrow'),
        SizedBox(height: 6),
        _SchedulePreviewRow(icon: SyncIcons.nextWeek, label: 'Next Week'),
        SizedBox(height: 6),
        _SchedulePreviewRow(
          icon: SyncIcons.reminder,
          label: 'Reminder',
          value: '8:30',
        ),
        SizedBox(height: 6),
        _SchedulePreviewRow(
          icon: SyncIcons.repeat,
          label: 'Repeat',
          value: 'Weekly',
        ),
      ],
    );
  }
}

class _SchedulePreviewRow extends StatelessWidget {
  const _SchedulePreviewRow({
    required this.icon,
    required this.label,
    this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      width: 218,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: colors.textPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListsVisual extends StatelessWidget {
  const _ListsVisual();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ListPreviewRow(icon: Icons.inbox_rounded, label: 'Inbox', count: '4'),
        _ListPreviewDivider(),
        _ListPreviewRow(icon: SyncIcons.folder, label: 'Work', count: '7'),
        _ListPreviewDivider(),
        _ListPreviewRow(
          icon: SyncIcons.reminder,
          label: 'Reminders',
          count: '2',
        ),
        _ListPreviewDivider(),
        _ListPreviewRow(icon: SyncIcons.completed, label: 'Completed'),
      ],
    );
  }
}

class _ListPreviewRow extends StatelessWidget {
  const _ListPreviewRow({required this.icon, required this.label, this.count});

  final IconData icon;
  final String label;
  final String? count;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      width: 224,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: colors.surface,
      child: Row(
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ListPreviewDivider extends StatelessWidget {
  const _ListPreviewDivider();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return SizedBox(
      width: 224,
      child: Divider(height: 1, indent: 46, color: colors.divider),
    );
  }
}

class _FinishVisual extends StatelessWidget {
  const _FinishVisual();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: colors.controlPrimary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_rounded,
            color: colors.controlForeground,
            size: 36,
          ),
        ),
        const SizedBox(height: 12),
        _FinishPill(
          icon: Icons.smartphone_rounded,
          label: 'Stored on this device',
        ),
        const SizedBox(height: 6),
        _FinishPill(
          icon: SyncIcons.settings,
          label: 'Change later in Settings',
        ),
      ],
    );
  }
}

class _FinishPill extends StatelessWidget {
  const _FinishPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      width: 224,
      height: 38,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.pageCount, required this.activeIndex});

  final int pageCount;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Semantics(
      label: 'Onboarding page ${activeIndex + 1} of $pageCount',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < pageCount; i++) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: i == activeIndex ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == activeIndex
                    ? colors.controlPrimary
                    : colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            if (i < pageCount - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

enum _OnboardingVisual { welcome, today, schedule, widgets, lists, finish }

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.visual,
  });

  final String title;
  final String body;
  final _OnboardingVisual visual;
}





class _WidgetsVisual extends StatelessWidget {
  const _WidgetsVisual();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 214,
      height: 226,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: colors.controlPrimary.withValues(alpha: 0.13),
            blurRadius: 34,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today_rounded,
                size: 16,
                color: colors.textPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Today Widget',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3/5 done',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _WidgetTaskItem(
            title: 'Review proposal',
            time: '10:00 AM',
            isDone: true,
          ),
          const SizedBox(height: 8),
          const _WidgetTaskItem(
            title: 'Design widget mockup',
            time: '2:30 PM',
            isDone: false,
          ),
          const SizedBox(height: 8),
          const _WidgetTaskItem(
            title: 'Team sync meeting',
            time: '4:00 PM',
            isDone: false,
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 5,
                    backgroundColor: colors.surfaceSecondary,
                    color: colors.controlPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.controlPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: colors.controlForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WidgetTaskItem extends StatelessWidget {
  const _WidgetTaskItem({
    required this.title,
    required this.time,
    required this.isDone,
  });

  final String title;
  final String time;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? colors.controlPrimary : Colors.transparent,
            border: Border.all(
              color: isDone ? colors.controlPrimary : colors.divider,
              width: 1.5,
            ),
          ),
          child: isDone
              ? Icon(
                  Icons.check_rounded,
                  size: 11,
                  color: colors.controlForeground,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDone ? colors.textSecondary : colors.textPrimary,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 11,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
