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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Container(
          key: const Key('sync-bottom-nav-pill'),
          height: 76,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.textPrimary, width: 3),
            borderRadius: BorderRadius.circular(48),
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
                child: _SyncNavIcon(index: index, color: iconColor),
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
  const _SyncNavIcon({required this.index, required this.color});

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return switch (index) {
      0 => _TodayIcon(color: color),
      1 => Icon(Icons.calendar_month_outlined, color: color, size: 34),
      2 => Icon(Icons.adjust_outlined, color: color, size: 38),
      _ => Icon(Icons.format_list_bulleted_outlined, color: color, size: 38),
    };
  }
}

class _TodayIcon extends StatelessWidget {
  const _TodayIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '31',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
          height: 1,
        ),
      ),
    );
  }
}
