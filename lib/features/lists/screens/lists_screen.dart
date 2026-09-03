import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/synctask_color_scheme.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Scaffold(
      backgroundColor: colors.scaffold,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Align(
              alignment: Alignment.centerRight,
              child: _ListsActionPill(
                onMorePressed: () => context.go('/lists/more'),
                onSettingsPressed: () => context.go('/lists/settings'),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 48, 18, 24),
              children: [
                _ListCard(
                  key: const Key('lists-primary-section'),
                  children: [
                    _ListRow(
                      label: 'All',
                      semanticLabel: 'Open All list',
                      icon: const Icon(Icons.format_list_bulleted),
                      onTap: () => context.go('/lists/all'),
                    ),
                    _ListRow(
                      label: 'Today',
                      semanticLabel: 'Open Today list',
                      icon: const _DateIcon(),
                      onTap: () => context.go('/today'),
                    ),
                    _ListRow(
                      label: 'Upcoming',
                      semanticLabel: 'Open Upcoming list',
                      icon: const Icon(Icons.calendar_month_outlined),
                      onTap: () => context.go('/upcoming'),
                    ),
                    _ListRow(
                      label: 'Completed',
                      semanticLabel: 'Open Completed list',
                      icon: const Icon(Icons.check_circle_outline),
                      onTap: () => context.go('/lists/completed'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const _SectionLabel('MY FOLDERS'),
                const SizedBox(height: 10),
                _ListCard(
                  key: const Key('lists-inbox-section'),
                  children: [
                    _ListRow(
                      label: 'Inbox',
                      semanticLabel: 'Open Inbox list',
                      icon: const Icon(Icons.inbox),
                      onTap: () => context.go('/lists/inbox'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const _SectionLabel('REMINDERS'),
                const SizedBox(height: 10),
                _ListCard(
                  key: const Key('lists-reminders-section'),
                  children: [
                    _ListRow(
                      label: 'Reminders',
                      semanticLabel: 'Open Reminders list',
                      icon: const Icon(Icons.format_list_bulleted),
                      onTap: () => context.go('/lists/reminders'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const _SectionLabel('NOTION'),
                const SizedBox(height: 10),
                _ListCard(
                  key: const Key('lists-notion-section'),
                  children: [
                    _ListRow(
                      label: 'Notion — Coming Soon',
                      semanticLabel: 'Open Notion list',
                      icon: const _NotionIcon(),
                      onTap: () => context.go('/lists/notion'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListsActionPill extends StatelessWidget {
  const _ListsActionPill({
    required this.onMorePressed,
    required this.onSettingsPressed,
  });

  final VoidCallback onMorePressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      height: 54,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.surface.withAlpha(0xE6),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colors.divider.withAlpha(0x66)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(0x0F),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(0x0A),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: Icons.more_horiz,
            semanticLabel: 'More list options',
            onPressed: onMorePressed,
          ),
          const SizedBox(width: 4),
          _ActionButton(
            icon: Icons.settings_outlined,
            semanticLabel: 'Settings',
            onPressed: onSettingsPressed,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Semantics(
      container: true,
      button: true,
      onTap: onPressed,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: IconButton(
          onPressed: onPressed,
          tooltip: semanticLabel,
          icon: Icon(icon, color: colors.textPrimary, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            fixedSize: const Size.square(42),
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
            side: BorderSide(color: colors.divider.withAlpha(0x99)),
          ),
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.children, super.key});

  final List<_ListRow> children;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.divider.withAlpha(0x59)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(0x0C),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(0x08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 18,
                  color: colors.divider,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Semantics(
      container: true,
      button: true,
      onTap: onTap,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: IconTheme(
                        data: IconThemeData(
                          color: colors.textPrimary,
                          size: 31,
                        ),
                        child: Center(child: icon),
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colors.textPrimary,
                      size: 32,
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

class _DateIcon extends StatelessWidget {
  const _DateIcon();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final today = DateTime.now().day.toString();
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colors.textPrimary, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        today,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _NotionIcon extends StatelessWidget {
  const _NotionIcon();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colors.textPrimary, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'N',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
