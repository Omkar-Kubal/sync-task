import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/app.dart';

void main() {
  testWidgets('renders SyncTask app shell', (tester) async {
    await tester.pumpWidget(const SyncTaskApp());
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsWidgets);
  });
}
