# Upcoming Views Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Agenda, Week, Overdue, No date, and Folders view modes to the existing Upcoming screen.

**Architecture:** Keep the feature local to the Upcoming surface. Add repository query support for all active tasks, then let the screen filter/group in presentation helpers so existing task row editing/completion/deletion behavior stays unchanged.

**Tech Stack:** Flutter, Riverpod FutureProvider, Drift repository, flutter_test widget tests.

**Spec:** `docs/superpowers/specs/2026-09-07-upcoming-views-design.md`

## Global Constraints

- Do not change bottom navigation destinations or layout.
- Do not reintroduce Focus screen, Focus timer, Focus routes, or Focus analytics.
- Preserve existing task row edit, complete, and delete actions.

---

### Task 1: Upcoming view-mode tests and query source

**Files:**
- Modify: `test/features/tasks/upcoming_screen_test.dart`
- Modify: `lib/features/tasks/data/task_repository.dart`
- Modify: `lib/features/tasks/providers/upcoming_tasks_provider.dart`
- Modify: `lib/features/tasks/screens/upcoming_screen.dart`

**Interfaces:**
- Consumes: `TaskRepository.listAllActiveTasks()` returns active tasks including overdue and no-date rows.
- Produces: Upcoming view chips with labels `Agenda`, `Week`, `Overdue`, `No date`, and `Folders`.

- [ ] **Step 1: Write failing widget tests**

Add tests that create future, overdue, no-date, and foldered tasks, then tap the new chips and assert visible grouping/text.

- [ ] **Step 2: Run failing tests**

Run: `flutter test test/features/tasks/upcoming_screen_test.dart --reporter compact`
Expected: FAIL because the view chips do not exist yet.

- [ ] **Step 3: Implement minimal query/screen support**

Change `upcomingTasksProvider` to read all active tasks and add local view-mode filtering/grouping in `UpcomingScreen`.

- [ ] **Step 4: Run targeted tests**

Run: `flutter test test/features/tasks/upcoming_screen_test.dart --reporter compact`
Expected: PASS.

- [ ] **Step 5: Run full verification**

Run: `flutter analyze` and `flutter test --reporter compact`.
Expected: analyzer reports no issues and tests report all passed.