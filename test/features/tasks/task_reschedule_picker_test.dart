import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart';
import 'package:synctasks/features/tasks/widgets/task_reschedule_picker.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repository;

  setUp(() {
    db = AppDatabase.memory();
    repository = TaskRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<Completer<TaskRescheduleSelection?>> openPicker(
    WidgetTester tester,
    Task task,
    DateTime now,
  ) async {
    final result = Completer<TaskRescheduleSelection?>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result.complete(
                  await showTaskReschedulePicker(context, task, now: now),
                );
              },
              child: const Text('Reschedule'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Reschedule'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('future date keeps task time and rebases reminder offset', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final id = await repository.createTask(
      TaskDraft(
        title: 'Timed task',
        scheduledDate: yesterday,
        scheduledTime: DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          16,
        ),
        reminderTime: DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          15,
        ),
      ),
    );
    final task = (await repository.getTask(id))!;
    final selectionFuture = await openPicker(tester, task, now);
    await tester.pumpAndSettle();

    final tomorrow = today.add(const Duration(days: 1));
    await tester.tap(find.text('${tomorrow.day}'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final selection = await selectionFuture.future;
    expect(selection?.date, tomorrow);
    expect(
      selection?.time,
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16),
    );
    expect(
      selection?.reminderTime,
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 15),
    );
    expect(selection?.reminderRemoved, isFalse);
  });

  testWidgets('a reminder that rebases into the past is removed', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final id = await repository.createTask(
      TaskDraft(
        title: 'Date only task',
        scheduledDate: yesterday,
        reminderTime: DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          8,
        ),
      ),
    );
    final task = (await repository.getTask(id))!;
    final selectionFuture = await openPicker(
      tester,
      task,
      today.add(const Duration(hours: 12)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final selection = await selectionFuture.future;
    expect(selection?.date, today);
    expect(selection?.reminderTime, isNull);
    expect(selection?.reminderRemoved, isTrue);
  });
}
