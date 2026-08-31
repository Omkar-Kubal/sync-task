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
    _SyncNavItem('Today', Icons.calendar_today_outlined),
    _SyncNavItem('Upcoming', Icons.calendar_month_outlined),
    _SyncNavItem('Focus', Icons.adjust_outlined),
    _SyncNavItem('Lists', Icons.format_list_bulleted_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.textPrimary),
            borderRadius: BorderRadius.circular(38),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _SyncBottomNavButton(
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
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _SyncNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final color = selected ? colors.textPrimary : colors.textSecondary;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Semantics(
        selected: selected,
        button: true,
        label: item.label,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncNavItem {
  const _SyncNavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
