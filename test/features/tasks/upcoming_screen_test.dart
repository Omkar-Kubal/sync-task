import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/notifications/notification_service.dart';
import 'package:synctasks/core/notifications/task_reminder_service.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/tasks/data/folder_repository.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart';
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:synctasks/features/tasks/screens/upcoming_screen.dart';

void main() {
  late AppDatabase db;
  late TaskController controller;

  setUp(() {
    db = AppDatabase.memory();
    controller = TaskController(TaskRepository(db));
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(
          RecordingNotificationScheduler(),
        ),
      ],
      child: MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: const UpcomingScreen(),
      ),
    );
  }

  testWidgets('upcoming screen matches compact mockup chrome', (tester) async {
    await tester.pumpWidget(wrap());

    final now = DateTime.now();
    expect(find.text('Upcoming'), findsOneWidget);
    expect(
      find.text(
        '${DateFormat('MMM d').format(now)} · Today · ${DateFormat('EEEE').format(now)}',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('More options'), findsNothing);
    expect(find.bySemanticsLabel('Create task'), findsOneWidget);

    final titleText = tester.widget<Text>(find.text('Upcoming'));
    expect(titleText.style?.fontSize, 29);
  });

  testWidgets('upcoming empty state explains there are no upcoming tasks', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Nothing scheduled yet.'), findsOneWidget);
    expect(
      find.text("Create a task or add a date when you're ready."),
      findsOneWidget,
    );
  });

  testWidgets('upcoming hides unfinished overflow actions', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('More options'), findsNothing);
    expect(find.text('View'), findsNothing);
    expect(find.text('Select tasks'), findsNothing);
  });

  testWidgets('upcoming shows view chips and agenda excludes overdue no-date', (
    tester,
  ) async {
    final today = _today();
    await controller.create(
      TaskDraft(title: 'Future agenda task', scheduledDate: today),
    );
    await controller.create(
      TaskDraft(
        title: 'Old task',
        scheduledDate: today.subtract(const Duration(days: 1)),
      ),
    );
    await controller.create(const TaskDraft(title: 'Loose task'));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, 'Agenda'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Week'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Overdue'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'No date'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Folders'), findsOneWidget);
    expect(find.text('Future agenda task'), findsOneWidget);
    expect(find.text('Old task'), findsNothing);
    expect(find.text('Loose task'), findsNothing);
  });

  testWidgets('upcoming week view only shows the next seven days', (
    tester,
  ) async {
    final today = _today();
    await controller.create(
      TaskDraft(
        title: 'This week task',
        scheduledDate: today.add(const Duration(days: 6)),
      ),
    );
    await controller.create(
      TaskDraft(
        title: 'Later than week task',
        scheduledDate: today.add(const Duration(days: 8)),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Week'));
    await tester.pumpAndSettle();

    expect(find.text('This week task'), findsOneWidget);
    expect(find.text('Later than week task'), findsNothing);
  });

  testWidgets('upcoming overdue and no-date views reveal hidden active tasks', (
    tester,
  ) async {
    final today = _today();
    await controller.create(
      TaskDraft(
        title: 'Pay late invoice',
        scheduledDate: today.subtract(const Duration(days: 2)),
      ),
    );
    await controller.create(const TaskDraft(title: 'Someday idea'));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Overdue'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('upcoming-section-overdue')), findsOneWidget);
    expect(find.text('Pay late invoice'), findsOneWidget);
    expect(find.text('Someday idea'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'No date'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('upcoming-section-no-date')), findsOneWidget);
    expect(find.text('Someday idea'), findsOneWidget);
    expect(find.text('Pay late invoice'), findsNothing);
  });

  testWidgets('upcoming folders view groups active tasks by folder', (
    tester,
  ) async {
    final folders = FolderRepository(db);
    final work = await folders.createFolder('Work');
    final today = _today();
    await controller.create(
      TaskDraft(title: 'Inbox plan', scheduledDate: today),
    );
    await controller.create(
      TaskDraft(
        title: 'Work plan',
        folderId: work.id,
        scheduledDate: today.add(const Duration(days: 1)),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Folders'));
    await tester.pumpAndSettle();

    final inboxHeader = find.byKey(const Key('upcoming-section-folder-inbox'));
    final workHeader = find.byKey(const Key('upcoming-section-folder-work'));
    expect(inboxHeader, findsOneWidget);
    expect(workHeader, findsOneWidget);
    expect(
      tester.getTopLeft(inboxHeader).dy,
      lessThan(tester.getTopLeft(find.text('Inbox plan')).dy),
    );
    expect(
      tester.getTopLeft(workHeader).dy,
      lessThan(tester.getTopLeft(find.text('Work plan')).dy),
    );
  });

  testWidgets('upcoming title sits in the top row like Today', (tester) async {
    await tester.pumpWidget(wrap());

    final titleTop = tester.getTopLeft(find.text('Upcoming')).dy;
    final titleLeft = tester.getTopLeft(find.text('Upcoming')).dx;

    expect(titleLeft, 20);
    expect(titleTop, 18);
  });

  testWidgets('upcoming screen renders real tasks as compact rows', (
    tester,
  ) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await controller.create(
      TaskDraft(
        title: 'Test1',
        scheduledDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Test1'), findsOneWidget);
    expect(find.textContaining('Inbox'), findsOneWidget);
    expect(find.byKey(const Key('task-row-checkbox')), findsOneWidget);
    expect(find.text('Nothing scheduled yet.'), findsNothing);
  });

  testWidgets('upcoming metadata includes folder and reminder without focus', (
    tester,
  ) async {
    final folders = FolderRepository(db);
    final work = await folders.createFolder('Work');
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final date = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    await controller.create(
      TaskDraft(
        title: 'Deep work',
        folderId: work.id,
        scheduledDate: date,
        reminderTime: DateTime(date.year, date.month, date.day, 9),
        focusDurationMinutes: 45,
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Deep work'), findsOneWidget);
    expect(find.textContaining('Work'), findsOneWidget);
    expect(find.textContaining('Reminder 9:00 AM'), findsOneWidget);
    expect(find.textContaining('Focus'), findsNothing);
  });

  testWidgets('upcoming screen includes tasks scheduled for today', (
    tester,
  ) async {
    final now = DateTime.now();
    await controller.create(
      TaskDraft(
        title: 'Today task',
        scheduledDate: DateTime(now.year, now.month, now.day),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Today task'), findsOneWidget);
    expect(find.text('Nothing scheduled yet.'), findsNothing);
  });

  testWidgets(
    'upcoming screen groups tasks by today tomorrow and later dates',
    (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final later = today.add(const Duration(days: 4));

      await controller.create(
        TaskDraft(title: 'Later task', scheduledDate: later),
      );
      await controller.create(
        TaskDraft(title: 'Tomorrow task', scheduledDate: tomorrow),
      );
      await controller.create(
        TaskDraft(title: 'Today task', scheduledDate: today),
      );

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      final todayHeader = find.byKey(const Key('upcoming-section-today'));
      final tomorrowHeader = find.byKey(const Key('upcoming-section-tomorrow'));
      final laterHeader = find.byKey(
        Key('upcoming-section-${later.toIso8601String()}'),
      );

      expect(todayHeader, findsOneWidget);
      expect(tomorrowHeader, findsOneWidget);
      expect(laterHeader, findsOneWidget);
      expect(
        find.byKey(const Key('upcoming-section-divider-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('upcoming-section-divider-1')),
        findsOneWidget,
      );

      expect(
        tester.getTopLeft(todayHeader).dy,
        lessThan(tester.getTopLeft(find.text('Today task')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Today task')).dy,
        lessThan(tester.getTopLeft(tomorrowHeader).dy),
      );
      expect(
        tester.getTopLeft(tomorrowHeader).dy,
        lessThan(tester.getTopLeft(find.text('Tomorrow task')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Tomorrow task')).dy,
        lessThan(tester.getTopLeft(laterHeader).dy),
      );
      expect(
        tester.getTopLeft(laterHeader).dy,
        lessThan(tester.getTopLeft(find.text('Later task')).dy),
      );
    },
  );

  testWidgets('upcoming task title can be edited from the sheet', (
    tester,
  ) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await controller.create(
      TaskDraft(
        title: 'Test1',
        scheduledDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test1'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('edit-task-title-field')),
      'Test2',
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Test2'), findsOneWidget);
    expect(find.text('Test1'), findsNothing);
  });

  testWidgets('tapping the completion circle removes a task from Upcoming', (
    tester,
  ) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await controller.create(
      TaskDraft(
        title: 'Finish from upcoming',
        scheduledDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('task-row-checkbox-button')));
    await tester.pumpAndSettle();

    expect(find.text('Finish from upcoming'), findsNothing);
    expect(find.text('Nothing scheduled yet.'), findsOneWidget);
  });

  testWidgets('Today chip in upcoming create sheet creates a today task', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Back to today');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit-task-done-button')));
    await tester.pumpAndSettle();

    expect(find.text('Back to today'), findsOneWidget);
    expect(find.byKey(const Key('upcoming-section-today')), findsOneWidget);
    expect(find.byKey(const Key('upcoming-section-tomorrow')), findsNothing);
  });
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}


