import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/sync_fab.dart';
import '../../../shared/widgets/sync_header.dart';
import '../../../shared/widgets/sync_icon_button.dart';

class UpcomingScreen extends StatelessWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SyncHeader(
            title: 'Upcoming',
            subtitle: DateFormat('MMM d · Today · EEEE').format(now),
            trailing: const SyncIconButton(icon: Icons.more_horiz, semanticLabel: 'More options'),
          ),
          const Expanded(child: Center(child: Text('No upcoming tasks'))),
        ],
      ),
      floatingActionButton: SyncFab(onPressed: () {}, semanticLabel: 'Create task'),
    );
  }
}
