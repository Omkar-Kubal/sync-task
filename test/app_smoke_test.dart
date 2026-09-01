import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/app.dart';

void main() {
  testWidgets('renders SyncTask app shell', (tester) async {
    await tester.pumpWidget(const SyncTaskApp());

    expect(find.byKey(const Key('app-splash-logo')), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
  });
}
