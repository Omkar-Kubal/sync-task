import 'package:flutter/material.dart';

import '../../../shared/widgets/sync_header.dart';
import '../../../shared/widgets/sync_icon_button.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SyncHeader(
            title: 'Lists',
            trailing: SyncIconButton(icon: Icons.settings_outlined, semanticLabel: 'Settings'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: const [
                ListTile(title: Text('All'), trailing: Icon(Icons.chevron_right)),
                ListTile(title: Text('Today'), trailing: Icon(Icons.chevron_right)),
                ListTile(title: Text('Upcoming'), trailing: Icon(Icons.chevron_right)),
                ListTile(title: Text('Completed'), trailing: Icon(Icons.chevron_right)),
                SizedBox(height: 24),
                Text('My Folders'),
                ListTile(title: Text('Inbox'), trailing: Icon(Icons.chevron_right)),
                SizedBox(height: 24),
                Text('Reminders'),
                ListTile(title: Text('Reminders'), trailing: Icon(Icons.chevron_right)),
                SizedBox(height: 24),
                Text('Notion'),
                ListTile(title: Text('Notion - Coming Soon'), trailing: Icon(Icons.chevron_right)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
