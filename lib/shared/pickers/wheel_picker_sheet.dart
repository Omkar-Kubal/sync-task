import 'package:flutter/material.dart';

import '../../core/theme/sync_typography.dart';

import '../sheets/app_bottom_sheet.dart';

class WheelPickerSheet extends StatelessWidget {
  const WheelPickerSheet({
    required this.title,
    required this.onDone,
    this.initialMinutes = 0,
    super.key,
  });

  final String title;
  final int initialMinutes;
  final ValueChanged<int> onDone;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: SyncTypography.of(context).pageTitle),
          const SizedBox(height: 24),
          Text(
            '${initialMinutes ~/ 60}'.padLeft(2, '0'),
            style: SyncTypography.of(context).pageTitle,
          ),
          const Text('hours'),
          const SizedBox(height: 12),
          Text(
            '${initialMinutes % 60}'.padLeft(2, '0'),
            style: SyncTypography.of(context).pageTitle,
          ),
          const Text('minutes'),
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Cancel'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => onDone(initialMinutes),
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
