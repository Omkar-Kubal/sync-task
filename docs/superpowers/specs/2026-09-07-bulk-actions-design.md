# Bulk Actions Design — 2026-09-07

## Scope
Add multi-select bulk actions for task rows without reintroducing Focus or changing bottom navigation.

## User behavior
- Long-pressing a task enters selection mode and selects that task.
- Tapping additional rows toggles selection while selection mode is active.
- A compact action bar shows the selected count and exposes: reschedule, move folder, complete, delete, cancel.
- Complete/delete operate immediately on selected tasks.
- Reschedule opens a date-choice sheet: Today, Tomorrow, Next week, No date.
- Move opens a folder-choice sheet using existing folders.
- After any action, selection clears and task list providers refresh.

## Non-goals
- No Focus screen, Focus nav item, focus timer, or focus-specific analytics.
- No recurring-series-wide bulk edit; bulk reschedule/move applies to selected task rows.
- No bottom navigation changes.