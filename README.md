# sync-task

SyncTask is an Android-first Flutter task planning and focus timer app.

This workspace includes the V1 implementation foundation from `.raw/prd.md`:

- Monochrome SyncTask design tokens and shared UI primitives
- Drift local database schema for folders, tasks, recurrence, and focus history
- Task repositories for Inbox, Today, Upcoming, Completed, folders, ordering, and recurring undo
- Focus timer state machine with completed-run history idempotency
- Notification service boundaries for reminders and focus alarms
- Lists, Search, Settings, Insights, analytics privacy, and error guardrail foundations

## Verify

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug
```
