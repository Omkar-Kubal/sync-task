import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/tasks/widgets/task_row.dart';

void main() {
  testWidgets('task row exposes complete and delete semantic actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: Scaffold(
          body: TaskRow(
            title: 'Write report',
            metadata: 'Inbox',
            onTap: () {},
            onComplete: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Write report'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(TaskRow)),
      matchesSemantics(
        label: 'Write report, Inbox',
        isButton: true,
        hasTapAction: true,
        hasDismissAction: true,
      ),
    );
  });

  testWidgets('task row checkbox completes the task without opening it', (
    tester,
  ) async {
    final haptics = _captureHaptics(tester);
    var completed = false;
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: Scaffold(
          body: TaskRow(
            title: 'Write report',
            metadata: 'Inbox',
            onTap: () => opened = true,
            onComplete: () => completed = true,
            onDelete: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('task-row-checkbox-button')));

    expect(completed, isTrue);
    expect(opened, isFalse);
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
    expect(haptics, isNot(contains('HapticFeedbackType.lightImpact')));
    expect(haptics, isNot(contains('HapticFeedbackType.mediumImpact')));
  });

  testWidgets('task row completion control animates when completed', (
    tester,
  ) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return TaskRow(
                title: 'Write report',
                metadata: 'Inbox',
                isCompleted: completed,
                onTap: () {},
                onComplete: () => setState(() => completed = true),
                onDelete: () {},
              );
            },
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('task-row-checkbox-completion-scale')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('task-row-checkbox-completion-switcher')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('task-row-checkbox-button')));
    await tester.pump();

    final scale = tester.widget<AnimatedScale>(
      find.byKey(const Key('task-row-checkbox-completion-scale')),
    );
    expect(scale.scale, greaterThan(1));

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('task row tap and swipe gestures emit haptics', (tester) async {
    final haptics = _captureHaptics(tester);
    var opened = false;
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: Scaffold(
          body: TaskRow(
            title: 'Write report',
            metadata: 'Inbox',
            onTap: () => opened = true,
            onComplete: () => completed = true,
            onDelete: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Write report'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Dismissible), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
    expect(completed, isTrue);
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
    expect(haptics, isNot(contains('HapticFeedbackType.lightImpact')));
    expect(haptics, isNot(contains('HapticFeedbackType.mediumImpact')));
  });

  testWidgets('task row delete gesture emits mild haptics', (tester) async {
    final haptics = _captureHaptics(tester);
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: Scaffold(
          body: TaskRow(
            title: 'Write report',
            metadata: 'Inbox',
            onTap: () {},
            onComplete: () {},
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
    expect(haptics, isNot(contains('HapticFeedbackType.lightImpact')));
    expect(haptics, isNot(contains('HapticFeedbackType.heavyImpact')));
  });

  testWidgets('task row matches compact checkbox and folder style', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: Scaffold(
          body: TaskRow(
            title: 'Write report',
            metadata: 'Inbox',
            onTap: () {},
            onComplete: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    final checkbox = tester.widget<Container>(
      find.byKey(const Key('task-row-checkbox')),
    );
    final decoration = checkbox.decoration! as BoxDecoration;
    final titleText = tester.widget<Text>(find.text('Write report'));
    final folderText = tester.widget<Text>(find.text('Inbox'));

    expect(
      tester.getSize(find.byKey(const Key('task-row-checkbox'))),
      const Size(20, 20),
    );
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.border?.top.width, 1.6);
    expect(decoration.border?.top.color, const Color(0xFF000000));
    expect(titleText.style?.fontSize, 14);
    expect(folderText.style?.fontSize, 11);
  });

  testWidgets('task row keeps a production tap target while staying compact', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: Scaffold(
          body: TaskRow(
            title: 'Write report',
            onTap: () {},
            onComplete: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(TaskRow)).height,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester.getSize(find.byKey(const Key('task-row-checkbox-button'))),
      const Size(44, 44),
    );
  });
}

List<Object?> _captureHaptics(WidgetTester tester) {
  final calls = <Object?>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        calls.add(call.arguments);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}


