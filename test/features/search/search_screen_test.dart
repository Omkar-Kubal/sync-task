import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart' as domain;
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:synctasks/features/search/screens/search_screen.dart';

void main() {
  testWidgets('search screen filters tasks by title only', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: const SearchScreen(
          initialTasks: [
            SearchTaskResult(id: 1, title: 'Write report', metadata: 'Inbox'),
            SearchTaskResult(id: 2, title: 'Plan workout', metadata: 'Today'),
          ],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'report');
    await tester.pump();

    expect(find.text('Write report'), findsOneWidget);
    expect(find.text('Plan workout'), findsNothing);
  });

  testWidgets('search screen queries repository tasks when typing', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await TaskRepository(
      db,
    ).createTask(const domain.TaskDraft(title: 'Repository result'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildSyncTasksTheme(Brightness.light),
          home: const SearchScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Repository');
    await tester.pumpAndSettle();

    expect(find.text('Repository result'), findsOneWidget);
  });

  testWidgets('search results open editable repository tasks', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await TaskRepository(
      db,
    ).createTask(const domain.TaskDraft(title: 'Repository result'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildSyncTasksTheme(Brightness.light),
          home: const SearchScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Repository');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Repository result'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('edit-task-title-field')), findsOneWidget);
  });

  testWidgets('search results complete repository tasks', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await TaskRepository(
      db,
    ).createTask(const domain.TaskDraft(title: 'Repository result'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildSyncTasksTheme(Brightness.light),
          home: const SearchScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Repository');
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(500, 0));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect((await db.select(db.tasks).get()).single.isCompleted, isTrue);
    expect(find.text('Repository result'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);
  });

  testWidgets('search results filter by date state completed and folder', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final clock = DateTime.now();
    final now = DateTime(clock.year, clock.month, clock.day, 9);
    final repo = TaskRepository(db, now: () => now);
    final inbox = (await db.select(db.folders).get()).single;
    final workFolderId = await db
        .into(db.folders)
        .insert(
          FoldersCompanion.insert(name: 'Work', sortOrder: 1, createdAt: now),
        );

    await repo.createTask(
      domain.TaskDraft(title: 'Shared today', scheduledDate: now),
    );
    await repo.createTask(
      domain.TaskDraft(
        title: 'Shared upcoming',
        scheduledDate: now.add(const Duration(days: 2)),
      ),
    );
    final completedId = await repo.createTask(
      const domain.TaskDraft(title: 'Shared done'),
    );
    await repo.completeTask(completedId);
    await repo.createTask(
      domain.TaskDraft(title: 'Shared work', folderId: workFolderId),
    );
    await repo.createTask(
      domain.TaskDraft(title: 'Shared inbox', folderId: inbox.id),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildSyncTasksTheme(Brightness.light),
          home: const SearchScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Shared');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pumpAndSettle();
    expect(find.text('Shared done'), findsOneWidget);
    expect(find.text('Shared today'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Today'));
    await tester.pumpAndSettle();
    expect(find.text('Shared today'), findsOneWidget);
    expect(find.text('Shared upcoming'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Upcoming'));
    await tester.pumpAndSettle();
    expect(find.text('Shared today'), findsOneWidget);
    expect(find.text('Shared upcoming'), findsOneWidget);
    expect(find.text('Shared done'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Work'));
    await tester.pumpAndSettle();
    expect(find.text('Shared work'), findsOneWidget);
    expect(find.text('Shared inbox'), findsNothing);
  });
}


