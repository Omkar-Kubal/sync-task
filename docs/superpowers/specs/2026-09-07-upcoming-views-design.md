# Upcoming Views Design — 2026-09-07

## Scope
Add actionable view modes to the existing Upcoming screen without changing bottom navigation or reintroducing Focus.

## Behavior
- The Upcoming screen shows compact view chips: Agenda, Week, Overdue, No date, Folders.
- Agenda is the default and keeps the existing date-grouped timeline for today and future scheduled active tasks.
- Week shows only active tasks scheduled from today through the next seven days, grouped by date.
- Overdue shows active tasks scheduled before today, grouped under an Overdue section.
- No date shows active unscheduled tasks, grouped under No date.
- Folders shows active scheduled and unscheduled tasks grouped by folder name.
- Existing task row actions remain: open edit, complete, delete.
- Empty states reflect the selected view.

## Non-goals
- No bottom-nav changes.
- No Focus screen, Focus timer, Focus route, or focus analytics.
- No calendar grid drag/drop in this slice.