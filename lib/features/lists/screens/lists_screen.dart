import 'package:flutter/material.dart';

import '../../../shared/widgets/sync_grouped_section.dart';
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
            trailing: SyncIconButton(
              icon: Icons.settings_outlined,
              semanticLabel: 'Settings',
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SyncGroupedSection(
                    children: [
                      ListTile(
                        title: Text('All'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                      ListTile(
                        title: Text('Today'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                      ListTile(
                        title: Text('Upcoming'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                      ListTile(
                        title: Text('Completed'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _SectionLabel('My Folders'),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SyncGroupedSection(
                    children: [
                      ListTile(
                        title: Text('Inbox'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _SectionLabel('Reminders'),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SyncGroupedSection(
                    children: [
                      ListTile(
                        title: Text('Reminders'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _SectionLabel('Notion'),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SyncGroupedSection(
                    children: [
                      ListTile(
                        title: Text('Notion - Coming Soon'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
