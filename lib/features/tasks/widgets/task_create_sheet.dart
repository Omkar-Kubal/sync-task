import 'package:flutter/material.dart';

import '../../../shared/sheets/app_bottom_sheet.dart';

class TaskCreateSheet extends StatelessWidget {
  const TaskCreateSheet({required this.onSubmit, super.key});

  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AppBottomSheet(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Task title', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            onPressed: () => onSubmit(controller.text),
            icon: const Icon(Icons.arrow_upward),
          ),
        ],
      ),
    );
  }
}
