import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/features/tasks/domain/quick_add_parse_result.dart';
import 'package:synctasks/features/tasks/domain/quick_add_parser.dart';

void main() {
  test('quick add parser removes natural date phrases and returns dates', () {
    final now = DateTime(2026, 9, 7, 10);

    expect(
      parseQuickAdd('Draft launch tomorrow', now: now),
      QuickAddParseResult(
        title: 'Draft launch',
        scheduledDate: DateTime(2026, 9, 8),
        hasDateInstruction: true,
      ),
    );
    expect(
      parseQuickAdd('Plan roadmap next week', now: now),
      QuickAddParseResult(
        title: 'Plan roadmap',
        scheduledDate: DateTime(2026, 9, 14),
        hasDateInstruction: true,
      ),
    );
    expect(
      parseQuickAdd('Someday maybe no date', now: now),
      const QuickAddParseResult(
        title: 'Someday maybe',
        hasDateInstruction: true,
      ),
    );
    expect(
      parseQuickAdd('Call Sam Friday', now: now),
      QuickAddParseResult(
        title: 'Call Sam',
        scheduledDate: DateTime(2026, 9, 11),
        hasDateInstruction: true,
      ),
    );
    expect(
      parseQuickAdd('Inbox note', now: now),
      const QuickAddParseResult(title: 'Inbox note'),
    );
  });
}


