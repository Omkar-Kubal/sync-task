import '../icons/list_filter_icon.dart';
import 'package:flutter/material.dart';

import '../../core/theme/synctasks_color_scheme.dart';
import '../services/sync_haptics.dart';

class SyncBottomNav extends StatelessWidget {
  const SyncBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [_SyncNavItem('Today'), _SyncNavItem('Lists')];

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 184),
            child: Container(
              key: const Key('sync-bottom-nav-pill'),
              height: 44,
              decoration: BoxDecoration(
                color: colors.surface.withAlpha(0xD9),
                borderRadius: BorderRadius.circular(24),
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
    final colors = SyncTasksColorScheme.of(context);
    final iconColor = colors.textPrimary;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: InkResponse(
          onTap: () {
            SyncHaptics.selection();
            onTap();
          },
          radius: 26,
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
      _ => ListFilterIcon(color: color, size: 22, strokeWidth: 1.45),
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
        ? SyncTasksColorScheme.of(context).controlForeground
        : color;
    return Container(
      key: const Key('sync-bottom-nav-today-tile'),
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: color, width: 2.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        today,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: foreground,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1,
        ),
      ),
    );
  }
}


