import 'package:flutter/material.dart';

import '../../../shared/widgets/sync_header.dart';
import '../../../shared/widgets/sync_icon_button.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SyncHeader(
            title: 'Focus',
            trailing: SyncIconButton(icon: Icons.insights_outlined, semanticLabel: 'Insights'),
          ),
          Expanded(
            child: Center(
              child: Text('--:--', style: Theme.of(context).textTheme.displayMedium),
            ),
          ),
        ],
      ),
    );
  }
}
