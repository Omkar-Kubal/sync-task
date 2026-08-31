# SyncTask Product Requirements Document (PRD)

**Product:** SyncTask  
**Platform:** Android  
**Framework:** Flutter / Dart  
**Architecture Basis:** Reuse SyncSpend architecture and conventions  
**Status:** Product + architecture design consolidated  
**Version:** V1 planning baseline  
**Date:** 2026-08-31

---

## 0. Executive Summary

SyncTask is a minimalistic, monochromatic Android task-management and focus app. It combines a clean todo-list workflow with Pomodoro-style timer functionality inherited conceptually from Toki, while removing Toki's mascot, purple visual identity, preset/session-count model, and separate-product feel.

The product is not intended to behave as "a todo app plus a timer." Its core interaction model is:

> **Plan task -> optionally assign custom Focus Timer -> start Focus from task -> work -> timer completes -> user independently decides whether task is complete.**

SyncTask is local-first, fully usable offline, requires no login, and ships without Pro/paywall in V1. Notion appears as a visible "Coming Soon" integration, but does not ship functional sync in V1.

The app reuses SyncSpend's engineering foundation: Flutter/Dart, Riverpod, Drift, `go_router`, `shared_preferences`, local notifications/timezone tooling, Firebase Crashlytics/Analytics, Inter typography, semantic theme tokens, `core / features / shared` organization, and local-first design philosophy.

---

# Section 1 — Product Definition and Scope

## 1.1 Product Goal

Build an Android-first productivity app that combines:

1. Minimal task planning.
2. Custom-duration focus timers.
3. Direct task-to-focus linkage.
4. Lightweight productivity insights.
5. Local-first privacy and offline operation.

The primary goal is fast daily use, not project management complexity.

## 1.2 Product Positioning

SyncTask should feel like a calm utility rather than a gamified productivity system.

It should avoid:

- points, XP, levels, badges, rewards
- mascot-based motivation
- session-count planning
- priority systems
- nested projects
- subtasks
- dense analytics dashboards
- mandatory accounts
- cloud dependency

The app should emphasize:

- clear task lists
- minimal visual noise
- deliberate focus
- fast navigation
- predictable interactions
- personal/local data ownership

## 1.3 V1 Product Pillars

### 1. Tasks

Supported task views and capabilities:

- Today
- Upcoming
- Inbox
- Completed
- Search
- Reminders
- Custom folders
- Manual task ordering
- Date
- Optional time
- One optional reminder
- Basic recurrence
- Optional custom Focus Timer

### 2. Focus

Supported Focus capabilities:

- custom duration only
- wheel picker input
- standalone Focus
- optional task attachment
- pause
- resume
- stop
- alarm-style completion
- +5 minute extension
- +10 minute extension
- streak

There is **no session concept** in user-facing task planning.

### 3. Task <-> Focus Bridge

Each task may store one custom Focus Timer duration.

Example:

```text
Write report -> 45 min
```

Rules:

- Focus Timer is optional on task creation/edit.
- Starting Focus from a task requires a Focus Timer.
- No default 25-minute fallback is applied.
- User may override saved task duration before starting a specific Focus run.
- Override affects current run only unless task is separately edited.
- Task completion remains independent from Focus completion.

### 4. Insights

V1 Insights include:

- Focus runs today
- Focus runs this week
- focused time today
- focused time this week
- tasks completed today
- current streak
- GitHub-style yearly activity grid

The activity grid intensity is based on **completed Focus run count**, not focused minutes or task completion count.

### 5. Integrations / Settings

V1 includes:

- reminders
- appearance
- Focus sound
- Focus vibration
- default folder setting if retained during implementation
- Notion "Coming Soon"

Notion is architecture-ready but non-functional in V1.

## 1.4 Explicitly Out of Scope for V1

- iOS release
- cloud account/login
- cross-device sync
- functioning Notion sync
- Pro/paywall
- subscription/lifetime purchase
- priorities
- flags
- tags
- subtasks
- nested folders
- folder rename
- multiple reminders per task
- custom recurrence rules beyond Daily / Weekly / Monthly
- deadlines separate from task date
- default Focus duration
- preset Focus durations
- focus session targets/counts
- Pomodoro break-cycle system
- mascot
- progress ring requirement
- productivity score
- monthly analytics
- folder analytics
- detailed trends
- automatic task completion after Focus

---

# Section 2 — Technical Foundation and Data Model

## 2.1 Architecture Decision

SyncTask reuses SyncSpend's architecture instead of creating a new Flutter architecture.

Primary project structure:

```text
lib/
├── core/
├── features/
├── shared/
├── app.dart
├── firebase_options.dart
└── main.dart
```

Recommended SyncTask specialization:

```text
lib/
├── core/
│   ├── database/
│   ├── notifications/
│   ├── timer/
│   ├── routing/
│   ├── theme/
│   ├── analytics/
│   └── constants/
│
├── features/
│   ├── tasks/
│   ├── focus/
│   ├── insights/
│   ├── lists/
│   ├── search/
│   └── settings/
│
├── shared/
│   ├── widgets/
│   ├── sheets/
│   ├── pickers/
│   └── extensions/
│
├── app.dart
├── firebase_options.dart
└── main.dart
```

## 2.2 Reused SyncSpend Technical Stack

SyncTask should reuse SyncSpend equivalents for:

- Flutter / Dart
- Riverpod 3 + `riverpod_annotation`
- Drift + `drift_flutter`
- `go_router`
- `shared_preferences`
- `flutter_local_notifications`
- `timezone`
- `flutter_timezone`
- Firebase Core
- Firebase Crashlytics
- Firebase Analytics
- Inter font

Packages that exist in SyncSpend but are not required for SyncTask V1 should not be carried over without need. Examples include finance/export/OCR/Notion/purchase-specific dependencies.

## 2.3 Architectural Rule

> Reuse SyncSpend architecture and conventions, not SyncSpend dependency baggage.

## 2.4 Core Data Entities

### `folders`

```text
id
name
createdAt
sortOrder
```

Rules:

- Inbox is permanent.
- Every task belongs to exactly one folder.
- Unassigned/new tasks default to Inbox.
- Custom folders may be created.
- Custom folders may be deleted.
- Folder rename is not supported in V1.
- Deleting a custom folder moves its tasks to Inbox.

### `task_series`

Used only for recurring tasks.

```text
id
title
folderId
repeatType       // daily | weekly | monthly
anchorDate
time
reminderTime
focusDuration
isActive
createdAt
```

Purpose:

- preserve recurrence definition
- preserve original cadence
- support one current occurrence at a time
- support deleting an occurrence without deleting recurrence series

### `tasks`

Each visible task is one task row / recurrence occurrence.

```text
id
seriesId?        // null = non-recurring
folderId
title
scheduledDate?
scheduledTime?
reminderTime?
focusDuration?
isCompleted
completedAt?
globalSortOrder
createdAt
```

Used by:

- Today
- Upcoming
- Inbox
- Completed
- Search
- folders
- reminders

### `focus_history`

Stores **completed Focus runs only**.

```text
id
taskId?
startedAt
completedAt
plannedDuration
actualDuration
wasExtended
createdAt
```

Rules:

- `taskId = null` for standalone Focus.
- stopped/cancelled timers are never inserted.
- extended Focus remains one run.
- final actual duration includes extensions.

## 2.5 Active Timer Persistence

Active timer state is temporary execution state and must remain separate from `focus_history`.

Suggested state:

```text
ActiveFocus
├── taskId?
├── startedAt
├── plannedDuration
├── currentEndAt?
├── pausedRemaining?
├── totalExtension
└── status
```

Rules:

- exactly one active Focus timer at a time
- survives app process kill
- does not survive device reboot
- restored from saved timestamp/state when app reopens

## 2.6 Recurrence Model

Recurring tasks use:

> **Series + generated occurrence**

Not a mutating single row and not bulk-pre-generated occurrences.

Core rule:

```text
Series
  ↓
exactly 1 active occurrence
  ↓
completed or deleted
  ↓
calculate next valid future occurrence
  ↓
generate next occurrence
```

### Recurrence Options

V1 supports:

- Daily
- Weekly
- Monthly

No custom recurrence editor.

### No Backlog Generation

If a recurring task remains incomplete, recurrence waits.

Example:

```text
Daily task scheduled Monday
Monday: incomplete
Tuesday: no new occurrence
Wednesday: still incomplete
Wednesday: user completes/deletes task
Thursday: next valid occurrence generated
```

Missed recurring occurrences are not backfilled.

### Original Cadence

Recurrence remains based on original schedule, not completion date.

Example:

```text
Weekly Monday task
completed Wednesday
next valid scheduled recurrence remains based on Monday cadence
```

If missed dates are already in the past, engine selects next valid recurrence date greater than current time.

### Editing Recurring Tasks

Edits to current recurring task apply to the entire series:

- title
- folder
- time
- reminder
- Focus Timer
- recurrence
- date

Changing scheduled date resets recurrence anchor.

Example:

```text
Weekly Monday
→ move to Wednesday
→ future recurrence becomes Wednesday
```

### Repeat -> None

Changing recurring task to `Repeat: None`:

1. deactivates recurrence series
2. keeps current occurrence
3. detaches current occurrence from series
4. current task becomes normal one-time task
5. preserves date/time/folder/reminder/Focus Timer

### Deleting Recurring Occurrence

Swipe-delete removes only the current occurrence.

- series remains active
- next occurrence is generated using recurrence rules
- delete remains immediate with Undo

---

# Section 3 — Focus Timer and Android Alarm Lifecycle

## 3.1 Timer State Machine

```text
IDLE
  ↓ Start
RUNNING
  ↓ Pause
PAUSED
  ↓ Resume
RUNNING
  ↓ reaches 00:00
RINGING
  ├─ +5 min  → RUNNING
  ├─ +10 min → RUNNING
  └─ Dismiss → COMPLETED → IDLE
```

Manual stop:

```text
RUNNING / PAUSED
        ↓ Stop
       IDLE
```

Stopped Focus creates no Insights/history data.

## 3.2 Timer Ownership

Focus execution is owned by dedicated timer subsystem, not UI.

Recommended core structure:

```text
core/timer/
├── timer_controller.dart
├── timer_state.dart
├── timer_repository.dart
└── timer_storage.dart
```

### `TimerController`

Responsibilities:

- start
- pause
- resume
- stop
- extend +5
- extend +10
- dismiss completion
- restore process-killed timer

### `TimerRepository`

Coordinates:

- persistent timer state
- Android alarm scheduling
- timer lifecycle operations

### `TimerStorage`

Stores active timer state locally.

## 3.3 Timing Source of Truth

UI must not depend on counting Dart timer ticks.

Remaining time is always derived from:

```text
endTimestamp - currentTime
```

A lightweight ticker may refresh displayed text only.

This avoids timer drift and supports reliable restoration.

## 3.4 Starting Focus

### Standalone Focus

```text
Focus tab
→ choose duration via wheel picker
→ optional Attach Task
→ Start
```

No default duration is prefilled.

`Start` remains disabled until duration > 0.

### Task-linked Focus

```text
Task
→ task bottom sheet
→ Focus Timer must exist
→ Start Focus
→ Focus screen
→ task + saved duration prefilled
→ user may override duration
→ Start
```

If task has no Focus Timer:

- keep task sheet open
- highlight Focus Timer field
- require duration selection
- do not apply default

## 3.5 Standalone Attach-Task Rule

When user chooses standalone duration first and then attaches a task:

- current run keeps selected standalone duration
- task's saved Focus Timer is not overwritten

Example:

```text
Selected 30m standalone timer
Attach task with saved 45m timer
Current run stays 30m
Task remains configured as 45m
```

## 3.6 Pause

At pause:

```text
remaining = endAt - now
```

Then:

- persist remaining duration
- cancel scheduled Focus completion alarm
- clear active `endAt`
- set state to PAUSED

Paused timer remains paused through app kill/reopen.

## 3.7 Resume

```text
newEndAt = now + pausedRemaining
```

Then:

- persist new end time
- clear paused remaining state
- reschedule Android alarm
- state -> RUNNING

## 3.8 Background Behavior

Timer continues while:

- user navigates elsewhere in SyncTask
- app is backgrounded
- screen is locked
- Flutter process is killed

Android-scheduled alarm remains authoritative when Flutter is not active.

## 3.9 App Process Kill

SyncTask must survive process kill.

On reopen:

```text
load active timer
→ if RUNNING and endAt > now
   restore remaining time
→ if PAUSED
   restore paused state
→ if endAt <= now
   resolve expired/ringing state appropriately
```

Do not infer completed Focus history from invalid/corrupt timer state.

## 3.10 Device Reboot

V1 explicitly does not restore Focus after device reboot.

Rules:

- no boot receiver requirement
- no alarm reconstruction after reboot
- stale active timer is discarded at next app launch
- Focus returns to idle

## 3.11 Active Focus Bar

When Focus is active and user leaves Focus tab, display compact bar above bottom navigation.

Task-linked:

```text
Finish report                     18:42
```

Standalone:

```text
Focus                             18:42
```

Rules:

- whole bar is tappable
- tap returns to Focus
- no Pause button in V1 active bar
- bar remains visually minimal

## 3.12 Timer Completion

At zero:

```text
RUNNING -> RINGING
```

Expected Android behavior:

- alarm-style sound
- vibration
- high-priority completion surface/notification
- display linked task title when applicable

Task is **not** automatically completed.

No "Mark task complete?" prompt.

## 3.13 Completion Actions

Alarm surface offers:

```text
+5 min
+10 min
Dismiss
```

### Extension

Extension remains part of same Focus run.

Example:

```text
Original: 45m
+10m
+5m
Final completed run: 60m
```

Stored history:

```text
plannedDuration = 45m
actualDuration  = 60m
wasExtended     = true
```

### Dismiss

Only `Dismiss` finalizes Focus history.

Reason: timer reaching zero is not final if user extends.

On dismiss:

1. stop ringing
2. create one `focus_history` record
3. clear active timer
4. Insights updates from history
5. return state to IDLE

## 3.14 Notification/Alarm Service Separation

Recommended:

```text
core/notifications/
├── notification_service.dart
├── task_reminder_service.dart
└── focus_alarm_service.dart
```

### Task Reminder Service

Handles scheduled task reminders only.

### Focus Alarm Service

Handles Focus timer completion only.

These systems must not share business logic simply because both use Android notifications.

## 3.15 Android Restrictions / Fallback

Android restrictions on exact alarms and full-screen alarm surfaces must be handled gracefully.

Core requirement:

- timer completion data remains correct
- use strongest allowed OS notification/alarm behavior
- if exact/full-screen privileges are unavailable, fall back to high-priority ringing notification behavior

---

# Section 4 — Navigation and Screen Flow Architecture

## 4.1 Primary Navigation

Persistent four-tab bottom navigation:

```text
Today | Upcoming | Focus | Lists
```

Search and Insights are intentionally not bottom-navigation destinations.

## 4.2 Today

Primary daily task screen.

Header:

```text
Today                         Search
Monday, August 31
```

Contains tasks scheduled today.

Interactions:

- tap task -> task bottom sheet
- long press + drag -> reorder
- swipe right -> complete
- swipe left -> delete
- floating `+` -> create task
- search icon -> global Search

## 4.3 Search

Accessible from Today header only.

Search across:

- Today
- Upcoming
- Inbox
- custom folders
- Completed

V1 search scope:

- task title matching
- no filters
- no advanced syntax
- no tags
- no date filter

Tap result opens same task bottom sheet.

## 4.4 Upcoming

Grouped by date:

```text
TODAY
TOMORROW
THIS WEEK
LATER
```

Within each section, tasks retain global manual ordering.

Upcoming remains a list view, not a calendar/planner UI.

## 4.5 Focus Home

Focus is an equal primary pillar.

Idle state:

```text
Focus                         Insights

              --:--

          Set Duration

          Attach Task

              Start
           (disabled)

------------------------------
4 day streak
```

Rules:

- no default 25m
- no presets
- no session count
- no mascot
- no progress ring requirement
- Start disabled until duration exists

## 4.6 Attach Task

From Focus:

```text
Attach Task

Search tasks

Today
...
Upcoming
...
```

Selection attaches task to current Focus run.

## 4.7 Task Bottom Sheet

Task tap opens reference-driven bottom sheet.

Core structure:

```text
Tomorrow
Next Week
No Date

-----------------------------
Date                >
Time                >
Focus Timer         >
Reminder            >
Repeat              >

[ Start Focus ]

Cancel            Done
```

No:

- deadline
- priority
- tags
- subtasks

### `Start Focus`

- visually prominent CTA
- disabled/unavailable until task Focus Timer exists
- opens Focus screen with task attached and saved duration prefilled

## 4.8 Task Creation

Floating `+` opens new-task sheet.

Suggested fields:

```text
Task title
Folder        Inbox
Date          None
Time          None
Focus Timer   None
Reminder      Off
Repeat        None
```

Defaults:

- Folder = Inbox
- Date = None
- Focus Timer = None
- Reminder = Off
- Repeat = None

Placement:

- no date -> Inbox
- date today -> Today
- future date -> Upcoming

## 4.9 Focus Running Screen

Task-linked:

```text
Focus

Finish report

              44:32

               Pause

                Stop
```

Standalone:

```text
Focus

              44:32

               Pause

                Stop
```

Keep screen deliberately sparse.

## 4.10 Completion Surface

Example:

```text
Focus Complete

Finish report
45 min completed

[ +5 min ]   [ +10 min ]

        Dismiss
```

Task remains unchanged.

## 4.11 Insights

Accessible from Focus top-right icon only.

Content:

```text
TODAY
3 Focus runs
2h 10m focused
5 tasks completed

THIS WEEK
12 Focus runs
8h 45m focused

STREAK
4 days

ACTIVITY
[ yearly grid ]
```

No monthly analytics or complex charts in V1.

## 4.12 Lists

Lists remains organization hub.

Structure:

```text
All
Today
Upcoming
Completed

MY FOLDERS
Inbox
Custom folders...

REMINDERS
Reminders

NOTION
Notion         Coming Soon
```

Today and Upcoming intentionally appear in both bottom navigation and Lists.

Bottom navigation provides fast access; Lists provides full organizational index.

## 4.13 Folder Screen

Each folder screen shows tasks assigned to that folder.

Rules:

- same global ordering
- same task gestures
- same task sheet
- `+` defaults new task to current folder

Folder actions:

- Create Folder
- Delete Folder

No Rename in V1.

Delete folder moves tasks to Inbox.

## 4.14 Completed

Completed tasks remain accessible and searchable.

Suggested grouping:

```text
Today
Yesterday
Earlier
```

## 4.15 Reminders

Reminders screen is a filtered task view, not a separate reminder data model.

Conceptually:

```text
tasks WHERE reminderTime != null
```

Tap reminder task -> normal task sheet.

## 4.16 Settings

Suggested V1 settings:

```text
GENERAL
Appearance
Default Folder
Notifications

FOCUS
Sound
Vibration

DATA
About local storage

INTEGRATIONS
Notion         Coming Soon

ABOUT
Version
Privacy
Feedback
```

Appearance:

- System (default)
- Light
- Dark

No Pro section in V1.

## 4.17 Route Map

Conceptual `go_router` map:

```text
/app
│
├── /today
│   └── /search
│
├── /upcoming
│
├── /focus
│   ├── /attach-task
│   └── /insights
│
├── /lists
│   ├── /all
│   ├── /completed
│   ├── /folder/:id
│   ├── /reminders
│   └── /settings
│
└── shared modal routes
    ├── task/create
    ├── task/:id
    ├── timer-picker
    ├── date-picker
    ├── time-picker
    ├── reminder-picker
    └── repeat-picker
```

## 4.18 Core User Journeys

### Quick Task

```text
Today -> + -> title -> Add
```

### Future Task

```text
+ -> title -> Date -> future date -> Add -> Upcoming
```

### Task-linked Focus

```text
Task -> bottom sheet -> Focus Timer -> Start Focus -> Start -> alarm -> Dismiss
```

### Standalone Focus

```text
Focus -> Set Duration -> Start -> alarm -> Dismiss
```

### Standalone Focus + Task

```text
Focus -> Set Duration -> Attach Task -> Start
```

### Search

```text
Today -> Search -> query -> result -> task sheet
```

---

# Section 5 — UI / Component Architecture and Design System

## 5.1 Design Direction

SyncTask should reuse SyncSpend's design-system engineering while adopting a stricter monochrome productivity visual language.

Visual identity:

> **Quiet · monochrome · editorial · functional · spacious**

Avoid:

- colorful productivity UI
- gradients
- gamification
- mascot visuals
- heavy Material-dashboard appearance
- excessive cards
- decorative illustrations

Primary hierarchy should come from:

- typography
- whitespace
- grouping
- neutral surfaces
- subtle motion

## 5.2 Color Foundation

### Light

```text
Background        #F2F2F7
Primary Surface   #FFFFFF
Primary Text      #000000
Secondary Text    #8E8E93
Divider           #E5E5EA
Strong Control    #000000
```

### Dark

```text
Background        #000000
Primary Surface   #1C1C1E
Secondary Surface #2C2C2E
Primary Text      #FFFFFF
Secondary Text    #8E8E93
Divider           #3A3A3C
Strong Control    #FFFFFF
```

Use semantic tokens rather than hardcoded widget colors.

Suggested extension:

```text
SyncTaskColorScheme
├── scaffold
├── surface
├── surfaceSecondary
├── textPrimary
├── textSecondary
├── divider
├── controlPrimary
├── controlForeground
├── destructive
└── activityIntensity*
```

A system destructive red may be retained for deletion semantics if needed; otherwise UI remains monochrome.

## 5.3 Typography

Inter everywhere.

Recommended hierarchy:

| Role | Size | Weight |
|---|---:|---:|
| Large screen heading | 28 | 700 |
| Main Focus timer | 64-72 | 600-700 |
| Section heading | 18-20 | 600 |
| Task title | 16 | 500 |
| Button | 15-16 | 600 |
| Body | 14-15 | 400 |
| Metadata | 12-13 | 400-500 |
| Small label | 11-12 | 500 |

Rules:

- letter spacing = 0
- timer digits should use stable/tabular numeral behavior where available
- maintain clear contrast in both themes

## 5.4 Spacing

Strict 4dp rhythm:

```text
4   micro
8   compact
12  row spacing
16  standard gutter
20  card/sheet padding
24  section gap
32  major separation
```

Primary screen gutter: ~16dp.

## 5.5 Shared Components

Recommended shared primitives:

```text
shared/widgets/
├── sync_header.dart
├── sync_icon_button.dart
├── sync_fab.dart
├── sync_bottom_nav.dart
├── sync_sheet.dart
├── sync_row.dart
├── sync_button.dart
├── active_focus_bar.dart
└── undo_snackbar.dart
```

Shared sheets/pickers:

```text
shared/sheets/
├── app_bottom_sheet.dart
├── option_sheet.dart
└── wheel_picker_sheet.dart
```

Feature-specific components stay feature-local.

## 5.6 App Headers

Examples:

```text
Today                       Search
Monday, August 31
```

```text
Focus                       Insights
```

```text
Lists                    ... Settings
```

Rules:

- no visually heavy Material AppBar
- 28dp strong heading
- compact icon visuals with >=44dp touch targets

## 5.7 Bottom Navigation

Four equal items:

```text
Today | Upcoming | Focus | Lists
```

No raised or special center Focus button.

Selected:

- primary icon/text

Unselected:

- secondary gray

## 5.8 Task Row

Minimal repeated component.

Suggested content:

```text
Task title
optional metadata
```

No persistent:

- checkbox
- priority indicator
- focus icon
- delete icon
- color label

Gestures:

- swipe right -> complete
- swipe left -> delete
- tap -> task sheet
- long press + drag -> reorder

## 5.9 Swipe Feedback

Right swipe reveals completion affordance.

Left swipe reveals delete affordance.

Full swipe commits action.

Then show Undo snackbar:

```text
Task completed        Undo
```

or:

```text
Task deleted          Undo
```

## 5.10 Floating Add Button

Reference direction:

- circular
- ~52-56dp
- black in light theme
- white in dark theme
- inverse `+`
- minimal shadow

Appears on task-oriented screens.

Not required on Focus, Insights, Settings, Search.

## 5.11 Task Bottom Sheet Geometry

Preserve reference-driven bottom-sheet pattern:

- dark modal veil
- full-width mobile sheet
- ~32dp top corners
- subtle handle
- no excessive shadow
- grouped rows
- high-contrast primary CTA

`Start Focus`:

Light:

```text
black fill + white text
```

Dark:

```text
white fill + black text
```

Disabled when Focus Timer unset.

## 5.12 Wheel Picker

Shared duration picker for:

- task Focus Timer
- standalone Focus
- per-run override

No preset chips.

Example:

```text
Focus Timer

  00      45
hours   minutes

Cancel        Done
```

## 5.13 Focus Screen Visual Rule

Old Toki visual identity does not transfer.

Transfer only:

- timer capability
- pause/resume
- alarm completion
- streak concept
- Focus history concept

Do not transfer:

- purple palette
- mascot
- preset-heavy UI
- session counters
- old Toki navigation/components

Focus screen should be visually sparse.

## 5.14 Insights Visual Rule

Use data typography and one activity grid instead of chart-heavy dashboard.

Example:

```text
Today
3 Focus runs
2h 10m focused
5 tasks completed
```

Activity grid uses monochrome intensity.

Light example:

```text
0 runs -> faint gray
1      -> light gray
2      -> medium gray
3      -> dark gray
4+     -> black
```

Dark mode reverses luminance appropriately.

## 5.15 Lists Screen Visual Rule

Keep close to uploaded SyncTask reference structure.

Example:

```text
All                  18
Today                 5
Upcoming              8
Completed            42

MY FOLDERS
Inbox                 3
Work                  5
College               4

REMINDERS
Reminders             >

NOTION
Notion       Coming Soon
```

Folder icons remain monochrome.

## 5.16 Empty States

No mascot or illustrations required.

Examples:

```text
Nothing for today
```

```text
Inbox is empty
```

```text
No Focus activity yet
Complete a timer to start building your activity.
```

## 5.17 Motion

Subtle and functional.

Suggested durations:

```text
Tap feedback       ~120ms
Content change     180-220ms
Sheet transition   240-280ms
Route transition   ~280ms
```

Allowed:

- opacity
- slight translation
- task collapse
- reorder animation
- bottom-sheet slide
- active Focus bar entrance

Avoid:

- confetti
- bounce-heavy motion
- particles
- timer pulsing
- decorative animation

## 5.18 Haptics

Subtle haptics may be used for:

- reorder threshold
- complete swipe threshold
- delete swipe threshold
- timer start
- timer pause/resume
- picker confirmation

Alarm vibration is separate and stronger.

## 5.19 Accessibility

Minimum requirements:

- >=44dp touch targets
- support text scaling
- semantic labels for icon-only controls
- reduced motion
- sufficient contrast
- screen-reader summaries for activity grid
- accessibility alternatives for swipe-only complete/delete

Because task complete/delete are gesture-first, expose equivalent accessibility actions/context operations even if no persistent visual button is shown.

## 5.20 Responsive Scope

V1 is phone-first Android.

Requirements:

- portrait optimized
- reasonable landscape support
- no tablet-specific redesign required
- avoid absolute positioning copied from iOS references
- reproduce visual relationships, not screenshot coordinates

---

# Section 6 — Feature / Domain Architecture and Riverpod Data Flow

## 6.1 Global Dependency Rule

```text
UI -> Controller/Notifier -> Repository/Service -> Drift / Android OS
```

Hard rules:

- UI does not access Drift directly.
- UI does not schedule Android alarms directly.
- Tasks do not execute Focus timers.
- Focus does not complete tasks.
- Insights does not mutate Tasks/Focus.
- Lists does not duplicate task storage.
- Search remains read-only.
- Settings does not own feature business logic.
- Notion never becomes source of truth.

## 6.2 Features

```text
features/
├── tasks/
├── focus/
├── insights/
├── lists/
├── search/
└── settings/
```

## 6.3 Tasks Feature

Owns:

- task CRUD
- completion
- deletion
- ordering
- folders
- scheduling
- reminders configuration
- recurrence
- stored task Focus Timer

Does not own active Focus execution.

Suggested structure:

```text
features/tasks/
├── data/
│   ├── task_repository.dart
│   ├── folder_repository.dart
│   └── task_dao.dart
│
├── domain/
│   ├── task.dart
│   ├── task_series.dart
│   ├── folder.dart
│   ├── recurrence_type.dart
│   └── services/
│       └── recurrence_engine.dart
│
├── providers/
│   ├── task_controller.dart
│   ├── today_tasks_provider.dart
│   ├── upcoming_tasks_provider.dart
│   ├── completed_tasks_provider.dart
│   └── folders_provider.dart
│
├── screens/
└── widgets/
```

### `TaskRepository`

Conceptual API:

```text
createTask()
updateTask()
deleteTask()
completeTask()
restoreTask()
getTask(id)
watchTodayTasks()
watchUpcomingTasks()
watchCompletedTasks()
watchFolderTasks(folderId)
reorderTask()
searchTasks()
```

## 6.4 Task Creation Flow

```text
TaskCreateSheet
      ↓
TaskController.create()
      ↓
validate
resolve folder/default Inbox
create series if recurring
create occurrence/task
persist Drift transaction
schedule reminder if configured
```

Reactive providers update UI automatically.

## 6.5 Task Update Flow

Task edits should persist as one cohesive operation rather than independent field writes.

```text
TaskSheet
   ↓
TaskController.update()
   ↓
TaskRepository
   ↓
Drift transaction
   ↓
Reminder reconciliation
   ↓
Reactive UI updates
```

## 6.6 Complete Flow

```text
Swipe right
   ↓
TaskController.complete(taskId)
   ↓
mark completed + completedAt
   ↓
cancel pending reminder
   ↓
if recurring: recurrence engine generates next valid future occurrence
   ↓
Undo snackbar
```

Undo restores task state and eligible reminder. For a recurring task, Undo must also remove/rollback any successor occurrence generated by the completion so the series returns to exactly one active occurrence.

## 6.7 Delete Flow

```text
Swipe left
   ↓
delete task occurrence
   ↓
if recurring: keep series, create next valid future occurrence
   ↓
Undo snackbar
```

Normal task deletes directly. For recurring tasks, Undo must restore the deleted occurrence and roll back any successor generated by the deletion so the one-active-occurrence invariant is preserved.

## 6.8 Recurrence Engine

```text
RecurrenceEngine
├── calculateNextDate()
├── ensureNextOccurrence()
├── createOccurrence()
└── stopSeries()
```

Primary invariant:

> One active occurrence maximum per recurrence series.

## 6.9 Folder Ownership

Folder is part of Tasks domain.

`Lists` only renders/navigates folder data.

Delete folder should use atomic transaction:

```text
move all folder tasks -> Inbox
then delete folder
```

No orphaned tasks.

## 6.10 Global Manual Ordering

Each task stores one `globalSortOrder`.

Same relative order is reused across applicable views.

Example:

```text
Global order: A < B < C
Today contains A, C
Today order remains A, C
```

Reordering one sortable view updates global order.

## 6.11 Focus Feature

Owns:

- duration selection
- optional task attachment
- active timer
- pause/resume/stop
- extension
- completion
- Focus history insertion

Suggested structure:

```text
features/focus/
├── data/
│   ├── focus_history_repository.dart
│   └── active_timer_repository.dart
│
├── domain/
│   ├── active_focus.dart
│   ├── focus_run.dart
│   └── focus_status.dart
│
├── providers/
│   ├── focus_controller.dart
│   ├── active_focus_provider.dart
│   └── focus_duration_provider.dart
│
├── screens/
└── widgets/
```

### `FocusController`

Conceptual API:

```text
setDuration()
attachTask()
detachTask()
start()
pause()
resume()
stop()
extend(5)
extend(10)
dismissCompletion()
restore()
```

Coordinates:

- ActiveTimerRepository
- FocusAlarmService
- FocusHistoryRepository

## 6.12 Focus History Repository

Only completed runs enter repository.

Conceptual operations:

```text
insertCompletedRun()
watchRecentRuns()
getRunsBetween()
getRunCountsByDay()
```

Cancelled/stopped Focus must never be inserted.

## 6.13 Insights Feature

Insights is read/reporting focused.

Suggested structure:

```text
features/insights/
├── data/
│   └── insights_repository.dart
├── domain/
│   ├── insights_summary.dart
│   └── activity_day.dart
├── providers/
│   ├── insights_provider.dart
│   └── activity_grid_provider.dart
├── screens/
└── widgets/
```

InsightsRepository may query:

- `focus_history`
- `tasks`

Outputs:

- todayFocusRuns
- weekFocusRuns
- todayFocusedDuration
- weekFocusedDuration
- todayCompletedTasks
- currentStreak
- yearActivity

Insights must not query controllers.

## 6.14 Streak Calculation

Streak is derived from `focus_history` rather than stored as mutable counter.

A day counts when >=1 completed Focus run exists for that local calendar date.

Cancelled/stopped Focus does not count.

## 6.15 Activity Grid Calculation

Derived mapping:

```text
local calendar date -> completed Focus run count
```

No activity cells stored in DB.

## 6.16 Lists Feature

Lists owns navigation/aggregation UI, not task persistence.

Suggested:

```text
features/lists/
├── providers/
│   └── list_summary_provider.dart
├── screens/
│   ├── lists_screen.dart
│   ├── folder_screen.dart
│   ├── all_tasks_screen.dart
│   └── reminders_screen.dart
└── widgets/
```

Counts are derived state; do not store dedicated list-count table.

## 6.17 Search Feature

Thin read-only feature.

```text
SearchField
  ↓
TaskSearchProvider
  ↓
TaskRepository.searchTasks(query)
  ↓
results
```

No separate search index in V1.

## 6.18 Settings Feature

Owns lightweight app preferences.

Suggested:

```text
features/settings/
├── data/
│   └── settings_repository.dart
├── domain/
│   └── app_settings.dart
├── providers/
│   └── settings_controller.dart
└── screens/
```

Potential settings:

```text
themeMode
notificationEnabled
focusSound
focusVibration
defaultFolderId?
```

Use SyncSpend-equivalent preference storage, not Drift unless relational requirements emerge.

## 6.19 Reminder Flow

Task stores reminder configuration.

Core notification service executes it.

```text
TaskController
   ↓ save task
TaskRepository
   ↓ commit DB
TaskReminderService.reconcile(task)
```

Operations:

- schedule
- reschedule
- cancel

Completing/deleting task cancels pending reminder.

Changing task date/time/reminder updates scheduled reminder.

## 6.20 Reminder Reconciliation

Drift remains source of truth.

On suitable startup/resume:

```text
query upcoming reminder tasks
→ verify/reconcile Android scheduled state
```

If notification permission is unavailable:

- task save must still succeed
- reminder scheduling failure is surfaced separately

## 6.21 Provider Philosophy

Use three categories intentionally.

### Stream / Read Providers

For persistent DB-backed UI:

```text
todayTasksProvider
upcomingTasksProvider
foldersProvider
completedTasksProvider
```

### Controllers / Notifiers

For user commands/workflows:

```text
TaskController
FocusController
SettingsController
```

### Derived Providers

For calculated presentation state:

```text
activeFocusBarProvider
listSummaryProvider
activityGridProvider
```

Avoid a giant global app provider.

## 6.22 Error Handling

### Database Failure

UI should receive safe product-language errors.

Example:

```text
Couldn't save task
```

Never display raw SQLite/Drift error text.

### Notification Permission Failure

Task still saves.

Example:

```text
Task saved. Reminder could not be scheduled.
```

### Focus Alarm Restriction

Timer remains valid; use best supported OS fallback.

### Corrupt Active Timer

```text
invalid/stale state
→ clear temporary timer
→ return Focus to idle
```

Do not create fake completed history.

## 6.23 Transaction Boundaries

Use Drift transactions for multi-row consistency.

Examples:

### Delete Folder

```text
move tasks -> Inbox
+ delete folder
```

### Create Recurring Task

```text
create series
+ create first occurrence
```

### Repeat -> None

```text
deactivate series
+ detach current task
```

## 6.24 Analytics / Privacy

Firebase Analytics/Crashlytics may be reused, but analytics must not include personal task content.

Allowed event examples:

```text
task_created
task_completed
folder_created
focus_started
focus_completed
focus_extended
insights_opened
```

Do not send:

- task title
- folder name
- reminder text
- search query
- personal content

## 6.25 Future Notion Boundary

Future integration should live independently:

```text
features/integrations/notion/
```

Architecture:

```text
Local TaskRepository
      ↓
NotionSyncCoordinator
      ↓
Notion API
```

Drift remains source of truth.

## 6.26 Future Monetization Boundary

V1 has no entitlement logic.

Future Pro may be introduced behind a dedicated entitlement boundary without redesigning Tasks/Focus core.

---

# Section 7 — Reliability, Testing, Migration, and V1 Acceptance Criteria

## 7.1 Reliability Objectives

V1 should prioritize correctness in five areas:

1. no task loss during CRUD/recurrence operations
2. no duplicate recurring occurrences
3. Focus timer remains accurate through background/process-kill scenarios
4. completed Focus history is recorded exactly once
5. reminders/alarm behavior remains consistent with stored local state

## 7.2 Test Layers

Recommended test strategy:

### Unit Tests

Cover pure logic:

- recurrence date calculation
- recurrence anchor changes
- next-valid-date calculation
- streak calculation
- activity-grid aggregation
- Focus state transitions
- duration extension calculations
- task ordering transformations

### Repository / Drift Tests

Cover:

- task CRUD
- folder delete -> move tasks to Inbox
- recurring task creation transaction
- recurrence series deactivation
- completion state
- delete/restore behavior
- Focus history insertion
- correct Today/Upcoming/Completed queries
- global order preservation

### Riverpod Controller Tests

Cover:

- TaskController workflows
- FocusController state machine
- SettingsController persistence
- error propagation
- reminder/focus alarm service coordination through mocks/fakes

### Widget Tests

Cover:

- task sheet fields
- Start Focus disabled without Focus Timer
- Search result rendering
- Insights summary rendering
- Lists sections
- Undo snackbar behavior
- Focus idle/running/paused states

### Android Integration / Device Tests

Required for:

- local notification scheduling
- reminder rescheduling
- reminder cancellation
- Focus alarm sound/vibration
- background timer completion
- lock-screen/high-priority notification behavior
- app process kill restoration
- notification permission denial
- exact-alarm restrictions where applicable

## 7.3 Recurrence Acceptance Matrix

### Daily

Given:

- recurring task anchored Monday

Expected:

- if Monday remains incomplete Tuesday, no Tuesday occurrence is created
- when current occurrence is completed/deleted Wednesday, engine selects next valid future daily date
- no backlog duplicates are generated

### Weekly

Given:

- recurrence anchored Monday

Expected:

- completion on Wednesday does not shift cadence to Wednesday
- next occurrence follows Monday cadence
- if user edits date to Wednesday, recurrence anchor changes to Wednesday

### Monthly

Expected:

- recurrence remains anchored to series date semantics
- next occurrence is future-valid
- month-end behavior when the anchor day does not exist in the next month (for example the 31st) was not decided in the approved design discussion; this edge case must be explicitly resolved before implementing monthly recurrence

### Repeat -> None

Expected:

- series inactive
- current occurrence survives
- current occurrence becomes non-recurring
- no future occurrence generated

### Delete Current Recurring Task

Expected:

- current occurrence deleted
- series remains
- next valid future occurrence generated
- Undo restores previous occurrence consistently and rolls back any successor occurrence created by the deletion

## 7.4 Focus State-Machine Tests

Required transitions:

```text
IDLE -> RUNNING
RUNNING -> PAUSED
PAUSED -> RUNNING
RUNNING -> IDLE via Stop
PAUSED -> IDLE via Stop
RUNNING -> RINGING at expiry
RINGING -> RUNNING via +5
RINGING -> RUNNING via +10
RINGING -> IDLE via Dismiss
```

Invalid transitions should be rejected or safely ignored.

Examples:

- cannot resume when idle
- cannot extend before ringing
- cannot dismiss completion twice
- cannot start second timer while one active

## 7.5 Focus History Idempotency

Critical requirement:

> One completed Focus run creates exactly one history record.

Test scenarios:

- dismiss completion once -> one record
- double-tap Dismiss -> one record
- app resumes during ringing -> no duplicate record
- extend +10 then dismiss -> one record
- extend +5 then +10 then dismiss -> one record
- stop before completion -> zero records
- app killed while running then restored -> zero records until true completion/dismiss

## 7.6 Process-Kill Restoration Tests

### Running Timer

Given:

- timer ends at 15:00
- app process killed at 14:30
- app reopened 14:40

Expected:

- timer restores with ~20 minutes remaining based on timestamp

### Paused Timer

Expected:

- paused remaining duration preserved
- timer does not progress while app absent

### Timer Expired While App Closed

Expected:

- Android alarm/notification handles expiry when possible
- reopening app resolves expired state safely
- no duplicate history insertion

### Corrupt State

Expected:

- temporary timer cleared
- app returns to idle
- no history fabricated

## 7.7 Device Reboot Acceptance

Given active timer before reboot:

Expected V1 behavior:

- no restoration after reboot
- stale timer state discarded at next launch
- no completed Focus history created automatically

## 7.8 Reminder Tests

Required scenarios:

- create task + reminder -> schedule notification
- edit date/time -> reschedule
- edit reminder -> reschedule
- complete task -> cancel
- delete task -> cancel
- Undo completion -> restore eligible reminder
- recurring task completes -> current reminder cancelled, next occurrence reminder scheduled
- notification permission denied -> task still persists

## 7.9 Task Gesture Tests

### Complete

- swipe right commits complete
- task moves to Completed
- Undo restores

### Delete

- swipe left deletes immediately
- Undo restores

### Accessibility

Equivalent semantic/context action must exist for users unable to perform swipe gesture.

## 7.10 Manual Ordering Tests

Global order must remain consistent across filtered views.

Example:

```text
Global: A, B, C, D
Today: A, C
Folder Work: B, C, D
```

Reordering must not produce duplicate order values or unstable query sorting.

Implementation should use deterministic secondary ordering where values tie.

## 7.11 Drift Migration Strategy

Even V1 should start with explicit schema versioning.

Requirements:

- `schemaVersion` maintained from first release
- migrations tested before release
- no destructive migration by default
- future Notion/Pro additions must not require resetting task/focus data

Recommended migration test fixtures:

- empty database
- populated normal tasks
- recurring tasks
- Focus history
- custom folders

## 7.12 Timezone / Date Handling

Task scheduling, streaks, activity grid, and reminders are date-sensitive.

Requirements:

- store absolute instants where appropriate
- derive user-facing calendar dates using current local timezone
- reminder scheduling uses timezone-aware values
- streak uses local calendar day boundaries
- activity grid uses local calendar dates

Timezone change should not create duplicate history records.

## 7.13 Analytics Validation

Before release, verify analytics payloads contain no user-entered content.

Must never log:

- task titles
- folder names
- reminder text
- search strings

Crashlytics breadcrumbs/errors should be reviewed for accidental user-content leakage.

## 7.14 Performance Acceptance

Targets are qualitative for V1:

- Today and Upcoming should feel immediate with normal personal task volumes
- task creation should reflect reactively without manual refresh
- drag/reorder should remain smooth
- Focus timer display should not trigger unnecessary whole-app rebuilds
- activity grid should be derived efficiently, ideally via aggregate query rather than loading all history into UI

## 7.15 Offline Acceptance

App must remain fully functional without network for:

- task CRUD
- folders
- recurrence
- Search
- reminders
- Focus
- Insights
- Settings

Only Firebase telemetry may wait/fail silently due to network.

Notion is non-functional/Coming Soon in V1 and cannot become runtime dependency.

## 7.16 Privacy Acceptance

V1 privacy expectations:

- no user login
- no task data stored on SyncTask server
- no mandatory cloud
- local DB is source of truth
- telemetry excludes user-entered content

## 7.17 UI Acceptance Criteria

### Visual

- monochromatic theme maintained
- no Toki purple visual language
- no mascot
- no session-counter language
- no default timer displayed on Focus idle state
- no priority/subtask controls

### Navigation

- bottom tabs exactly: Today / Upcoming / Focus / Lists
- Search accessible from Today header
- Insights accessible from Focus header
- Notion visible in Lists as Coming Soon

### Task Sheet

Must include:

- Tomorrow
- Next Week
- No Date
- Date
- Time
- Focus Timer
- Reminder
- Repeat
- Start Focus
- Cancel / Done

### Focus

- task-linked Focus requires saved duration
- standalone Focus requires manual duration selection
- duration picker is wheel-based
- pause/resume/stop work
- +5/+10 available at completion
- task state does not change automatically

## 7.18 V1 Release-Critical End-to-End Flows

All following flows must pass before production release.

### Flow A — Basic Task

```text
Create task
→ appears Inbox
→ assign today
→ appears Today
→ swipe complete
→ appears Completed
→ Undo restores
```

### Flow B — Upcoming Task

```text
Create future task
→ appears correct Upcoming section
→ edit date
→ moves to correct section
```

### Flow C — Folder

```text
Create folder
→ create task in folder
→ delete folder
→ task moves to Inbox
```

### Flow D — Reminder

```text
Create timed task + reminder
→ notification scheduled
→ edit time
→ notification rescheduled
→ complete task
→ notification cancelled
```

### Flow E — Recurring Task

```text
Create weekly task
→ first occurrence exists
→ leave overdue
→ no duplicate occurrence generated
→ complete current occurrence
→ next valid future occurrence generated
```

### Flow F — Task-linked Focus

```text
Task without Focus Timer
→ Start Focus blocked
→ assign Focus Timer
→ Start Focus
→ timer starts
→ pause
→ resume
→ background app
→ return
→ timer remains accurate
→ expiry alarm
→ +5
→ expiry alarm
→ Dismiss
→ exactly one history record
```

### Flow G — Standalone Focus

```text
Open Focus
→ no default duration
→ choose duration
→ Start
→ complete
→ Dismiss
→ Insights/streak update
```

### Flow H — Process Kill

```text
Start Focus
→ kill app process
→ reopen
→ timer restored from end timestamp
→ no duplicate history
```

### Flow I — Insights

After known set of Focus runs and task completions:

- today count correct
- week count correct
- focused time correct
- task completion count correct
- streak correct
- activity-grid intensity correct

### Flow J — Appearance

```text
System -> Light -> Dark
```

All primary screens/sheets/alarm surfaces remain legible and consistent.

---

# Product Rules Summary

## Tasks

- one folder per task
- Inbox default
- no priority
- no subtasks
- no tags
- one Date field only
- optional time
- max one reminder
- Daily/Weekly/Monthly recurrence
- manual global ordering
- swipe right complete
- swipe left delete

## Focus

- custom duration only
- wheel picker
- no default duration
- no preset buttons
- no session concept
- standalone allowed
- optional task attachment
- task-linked Focus requires saved timer
- pause/resume/stop
- +5/+10 at completion
- only completed runs enter Insights

## Recurrence

- one active occurrence per series
- waits for current occurrence completion/deletion
- no backlog generation
- cadence anchored to series schedule
- date edit resets anchor
- all recurring task edits apply to series
- Repeat -> None converts current occurrence to normal task

## Insights

- runs today
- runs this week
- focused time today/week
- tasks completed today count only
- streak
- yearly activity grid by completed Focus run count

## Navigation

```text
Today | Upcoming | Focus | Lists
```

- Search -> Today header
- Insights -> Focus header

## Data

- local-first
- no account
- fully offline
- Drift source of truth
- Notion later

## Monetization

- no Pro/paywall in V1

---

# Source / Design Basis

This PRD consolidates approved SyncTask product and architecture decisions from the design discussion, plus reusable engineering/design principles from the supplied SyncSpend `DESIGN.md` and `pubspec.yaml`.

Key reused SyncSpend principles include:

- Inter typography
- semantic color tokens
- 4dp spacing rhythm
- rounded sheets/surfaces
- restrained motion
- minimum touch-target discipline
- local-first architecture
- Riverpod + Drift + `go_router`
- local notifications + timezone support
- Firebase Crashlytics/Analytics infrastructure

SyncTask deliberately adapts those foundations into a stricter monochrome productivity identity rather than copying SyncSpend's finance-specific UI.

---

# Implementation Gate

This PRD defines V1 product behavior and architecture. Implementation should begin only after PRD review/approval. After approval, next step is a separate implementation plan decomposed into build phases, test checkpoints, migrations, and release verification.
