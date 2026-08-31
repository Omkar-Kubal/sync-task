import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/sync_fab.dart';
import '../../../shared/widgets/sync_header.dart';
import '../../../shared/widgets/sync_icon_button.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SyncHeader(
            title: 'Today',
            subtitle: DateFormat('EEEE, MMMM d').format(now),
            trailing: const SyncIconButton(icon: Icons.search, semanticLabel: 'Search'),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No tasks found', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  OutlinedButton(onPressed: () {}, child: const Text('Create new task')),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SyncFab(onPressed: () {}, semanticLabel: 'Create task'),
    );
  }
}
