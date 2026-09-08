# Bulk Actions Implementation Plan — 2026-09-07

1. Add widget tests for Today multi-select complete, delete, reschedule, and move-folder behavior. Confirm the tests fail before implementation.
2. Add repository/controller bulk methods that batch simple field updates and reuse existing complete/delete behavior.
3. Extend TaskRow with optional selection-mode behavior while preserving normal tap, complete, delete, and swipe interactions.
4. Add a reusable bulk action bar and date/folder action sheets.
5. Wire the Today screen to own selected task IDs, render the action bar, and call bulk controller methods.
6. Run targeted tests, then run analyzer and the full test suite.