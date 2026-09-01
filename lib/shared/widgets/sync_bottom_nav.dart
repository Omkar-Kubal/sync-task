import 'package:flutter/material.dart';

import '../../core/theme/synctask_color_scheme.dart';

class SyncBottomNav extends StatelessWidget {
  const SyncBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _SyncNavItem('Today'),
    _SyncNavItem('Upcoming'),
    _SyncNavItem('Focus'),
    _SyncNavItem('Lists'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              key: const Key('sync-bottom-nav-pill'),
              height: 52,
              decoration: BoxDecoration(
                color: colors.surface.withAlpha(0xD9),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _SyncBottomNavButton(
                        index: i,
                        item: _items[i],
                        selected: currentIndex == i,
                        onTap: () => onTap(i),
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

class _SyncBottomNavButton extends StatelessWidget {
  const _SyncBottomNavButton({
    required this.index,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final _SyncNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final iconColor = colors.textPrimary;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: InkResponse(
          onTap: onTap,
          radius: 32,
          containedInkWell: true,
          customBorder: const CircleBorder(),
          child: SizedBox.expand(
            child: Center(
              child: ExcludeSemantics(
                child: _SyncNavIcon(
                  index: index,
                  color: iconColor,
                  selected: selected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SyncNavItem {
  const _SyncNavItem(this.label);

  final String label;
}

class _SyncNavIcon extends StatelessWidget {
  const _SyncNavIcon({
    required this.index,
    required this.color,
    required this.selected,
  });

  final int index;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return switch (index) {
      0 => _TodayIcon(color: color, selected: selected),
      1 => Icon(Icons.calendar_month_outlined, color: color, size: 28),
      2 => Image.asset(
        'assets/images/logo.png',
        key: const Key('sync-bottom-nav-focus-logo'),
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
      _ => Icon(Icons.format_list_bulleted_outlined, color: color, size: 32),
    };
  }
}

class _TodayIcon extends StatelessWidget {
  const _TodayIcon({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().day.toString();
    final fillColor = selected ? color : Colors.transparent;
    final foreground = selected
        ? SyncTaskColorScheme.of(context).controlForeground
        : color;
    return Container(
      key: const Key('sync-bottom-nav-today-tile'),
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: color, width: 2.5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        today,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: foreground,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
          height: 1,
        ),
      ),
    );
  }
}
