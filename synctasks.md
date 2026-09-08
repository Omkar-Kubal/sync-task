# synctasks

synctasks is an Android-first, local-first task planning app built to keep daily work simple, fast, and low-noise. It helps users capture tasks quickly, organize them into clear lists, schedule what matters, and understand useful completion patterns without turning task management into another chore.

## What synctasks Is About

synctasks is designed for people who want a clean personal task system that feels lightweight but still capable. The app keeps the main experience centered on two primary areas:

- **Today** — the tasks that need attention now.
- **Lists** — the place to review folders, completed work, reminders, insights, and broader task groups.

Upcoming, Settings, Search, and Quick Add are available as supporting flows without crowding the bottom navigation.

## Core Features

### Today Planning

- View active tasks scheduled for today.
- Create new tasks quickly from the Today screen.
- Open task details in a clean edit sheet.
- Complete or delete tasks directly from task rows.
- See compact metadata such as folder, date, time, reminder, and repeat details.

### Upcoming Views

Upcoming helps users look beyond today without adding another bottom-nav destination.

- **Agenda** — scheduled upcoming tasks.
- **Week** — tasks coming up in the next seven days.
- **Overdue** — unfinished tasks whose scheduled date has passed.
- **No date** — active tasks that are not scheduled.
- **Folders** — active tasks grouped by folder.

### Lists and Folders

- Review task groups from the Lists screen.
- Open All, Today, Upcoming, Completed, Inbox, Reminders, and Insights.
- Create and manage custom folders.
- Move tasks between folders.
- Keep Inbox as the default catch-all place for unorganized tasks.

### Bulk Actions

synctasks supports multi-select task management for faster cleanup.

- Select multiple tasks.
- Reschedule selected tasks.
- Move selected tasks to another folder.
- Complete selected tasks.
- Delete selected tasks.

### Quick Add

Quick Add is built for fast capture from inside the app or from the Android widget.

- Uses the user’s default folder when available.
- Supports natural date parsing for quick scheduling.
- Shows a visible success affordance after creating a task.
- Keeps capture lightweight so users can add a task and move on.

### Android Home Screen Widget

synctasks includes Android widget support for glanceable task access.

- Shows today’s remaining task count.
- Displays compact task rows for today.
- Opens the app from the widget body.
- Supports quick task entry from the widget add action.
- Uses synctasks branding rather than generic checklist styling.

### Reminders and Scheduling

- Add scheduled dates and times to tasks.
- Set task reminders.
- View reminder-based tasks from Lists.
- Notification scheduling is handled locally on-device.

### Repeat Tasks

- Create repeating tasks.
- Support standard repeat presets.
- Support custom repeat labels and intervals.
- Generate successor tasks when recurring tasks are completed.

### Search

- Search across tasks.
- Open matching tasks.
- Complete or delete tasks from search results.
- Filter results by task context such as Today, Upcoming, Completed, or folder.

### Insights

Insights are based on task completion and scheduling data only.

- Today and weekly completion counts.
- Current and previous streak context.
- Completion trend bars.
- Productive-day activity grid.
- Best completion day.
- Planned vs. unplanned completion breakdown.

### Settings

- Settings opens as a full-screen sheet from Today.
- Configure app theme.
- Choose the default folder.
- Manage notification preferences.
- Access support/about information.

### Crash Reporting and Privacy-Safe Analytics

synctasks is connected to Firebase for production observability.

- Firebase Crashlytics captures fatal and non-fatal app errors.
- Firebase Analytics records safe app events and screen views.
- Analytics intentionally avoids user-authored content:
  - no task titles
  - no folder names
  - no search text
  - no reminder text
  - no notes or private content

## Product Principles

- **Local-first:** tasks and settings are stored locally for speed and reliability.
- **Minimal navigation:** bottom navigation stays limited to Today and Lists.
- **Fast capture:** adding a task should take only a few seconds.
- **Calm UI:** compact, monochrome, and production-polished.
- **Privacy-aware telemetry:** observe app health without collecting task content.

## Current Platform

synctasks currently targets Android with Flutter. The app uses Drift for local data, Riverpod for state management, GoRouter for navigation, Android home widgets, local notifications, Firebase Crashlytics, and Firebase Analytics.

