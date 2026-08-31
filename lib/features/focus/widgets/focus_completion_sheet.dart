import 'package:flutter/material.dart';

import '../../../shared/sheets/app_bottom_sheet.dart';
import '../../../shared/widgets/sync_button.dart';

class FocusCompletionSheet extends StatelessWidget {
  const FocusCompletionSheet({
    required this.durationLabel,
    required this.onExtendFive,
    required this.onExtendTen,
    required this.onDismiss,
    this.taskTitle,
    super.key,
  });

  final String? taskTitle;
  final String durationLabel;
  final VoidCallback onExtendFive;
  final VoidCallback onExtendTen;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Focus Complete', style: Theme.of(context).textTheme.titleLarge),
          if (taskTitle != null) ...[
            const SizedBox(height: 8),
            Text(taskTitle!),
          ],
          const SizedBox(height: 8),
          Text('$durationLabel completed'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onExtendFive, child: const Text('+5 min'))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton(onPressed: onExtendTen, child: const Text('+10 min'))),
            ],
          ),
          const SizedBox(height: 16),
          SyncButton.primary(label: 'Dismiss', onPressed: onDismiss),
        ],
      ),
    );
  }
}
