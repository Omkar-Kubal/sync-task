import 'package:flutter/material.dart';

import '../../../shared/widgets/sync_header.dart';
import '../../tasks/widgets/task_row.dart';

class SearchTaskResult {
  const SearchTaskResult({
    required this.id,
    required this.title,
    this.metadata,
  });

  final int id;
  final String title;
  final String? metadata;
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({this.initialTasks = const [], super.key});

  final List<SearchTaskResult> initialTasks;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final results = widget.initialTasks
        .where(
          (task) => task.title.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SyncHeader(title: 'Search'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search tasks'),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final task in results)
                    TaskRow(
                      title: task.title,
                      metadata: task.metadata,
                      onTap: () {},
                      onComplete: () {},
                      onDelete: () {},
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
