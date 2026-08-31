import 'package:flutter/material.dart';

import '../../../shared/widgets/sync_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SyncHeader(title: 'Settings'),
            ListTile(title: Text('Appearance')),
            ListTile(title: Text('Default Folder')),
            ListTile(title: Text('Notifications')),
            ListTile(title: Text('Sound')),
            ListTile(title: Text('Vibration')),
            ListTile(title: Text('About local storage')),
            ListTile(title: Text('Notion - Coming Soon')),
            ListTile(title: Text('Version')),
            ListTile(title: Text('Privacy')),
            ListTile(title: Text('Feedback')),
          ],
        ),
      ),
    );
  }
}
