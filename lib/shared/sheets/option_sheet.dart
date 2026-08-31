import 'package:flutter/material.dart';

import 'app_bottom_sheet.dart';

class OptionSheet<T> extends StatelessWidget {
  const OptionSheet({
    required this.title,
    required this.options,
    required this.onSelected,
    super.key,
  });

  final String title;
  final Map<T, String> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final entry in options.entries)
            ListTile(
              title: Text(entry.value),
              onTap: () => onSelected(entry.key),
            ),
        ],
      ),
    );
  }
}
