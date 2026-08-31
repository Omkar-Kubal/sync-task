import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/features/focus/screens/focus_screen.dart';

void main() {
  testWidgets('focus idle screen has no default duration or preset buttons', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildSyncTaskTheme(Brightness.light),
      home: const FocusScreen(),
    ));

    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('--:--'), findsOneWidget);
    expect(find.text('25:00'), findsNothing);
    expect(find.text('+5'), findsNothing);
    expect(find.text('+10'), findsNothing);
  });
}
