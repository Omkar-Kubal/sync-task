import 'package:flutter/material.dart';

import '../../../shared/widgets/sync_grouped_section.dart';
import '../../../shared/widgets/sync_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: const [
            SyncHeader(title: 'Settings'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SyncGroupedSection(
                children: [
                  ListTile(
                    title: Text('Appearance'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text('Default Folder'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SyncGroupedSection(
                children: [
                  ListTile(
                    title: Text('Notifications'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text('Sound'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text('Vibration'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SyncGroupedSection(
                children: [
                  ListTile(
                    title: Text('About local storage'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text('Notion - Coming Soon'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text('Version'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text('Privacy'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text('Feedback'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
