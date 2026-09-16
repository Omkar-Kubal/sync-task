# SyncTasks — Receipt Feature Specification

Version: 1.0  
Date: 9 September 2026  
Status: Product baseline locked; implementation not started.  
Filename: `recieptfeature.md` (requested spelling retained).

## 1. Purpose and authority

Build an optional visual reward for completed work in SyncTasks. Users select completed tasks, optionally personalise a receipt with a drawing or photo, generate it, enjoy a paper-printing interaction, and keep or share it.

This document consolidates the entire receipt discussion into a development specification: reference analysis, alternatives considered, revenue decisions, placement, composer, animation, storage, and two development phases. It is a decision record rather than a verbatim chat transcript. Superseded proposals are retained in Section 23 to prevent accidental implementation.

Authority order:

1. Latest explicit user decisions in this conversation.
2. Current attached `synctasks(2).md` and current Today/Lists screenshots.
3. Behaviours agreed and refined in this document.
4. Generated mockups as visual direction, not exact implementation contracts.
5. External reference website/video as inspiration only.

Product choices below are the locked baseline. Technical architecture, timing values, limits, and recovery policies fill implementation gaps; these are specified defaults, not claims that existing repository code has been inspected. Inspect the actual project before selecting dependency versions or changing shared architecture.

## 2. Existing app and boundaries

SyncTasks currently targets Android with Flutter/Dart. Its supplied specification names Drift, Riverpod, GoRouter, Android home widgets, local notifications, Firebase Crashlytics, and privacy-aware Firebase Analytics.

Bottom navigation remains **Today · Lists**, icons only. Upcoming, Search, Settings, Completed, Reminders, and Insights remain supporting flows. Existing task capture, folders, scheduling, recurrence, multi-select, widget, and completion insights stay intact and free.

**No timer is part of this feature or this plan.** Do not add focus sessions, Pomodoro, work duration, breaks, start/stop controls, time-based squares, or effort percentages. Older Focus-related app concepts do not govern this build.

Receipt generation must never complete, reopen, reschedule, or otherwise mutate a task. Completing a task must never require a receipt, signature, purchase, camera permission, or animation.

## 3. Locked product and revenue decisions

| Item | Locked behaviour |
| --- | --- |
| Free allowance | 3 newly generated receipts per calendar week |
| Pro | Unlimited receipt generation for ₹199 one-time purchase in India |
| Subscription | None |
| Receipt types | Same functionality for Free and Pro; only generation allowance differs |
| Personalisation | Drawing/signature, photo, or no artwork |
| Free experience | Complete personalisation, print animation, saving, history, and image sharing |
| Allowance consumption | Successful first save of a new receipt only |
| Non-consuming actions | Preview, cancel, drawing/photo attempts, edit existing receipt, replay, reopen, download/share |
| Existing functionality | All current task features remain free |
| Storage | Local-first; no account or content cloud service required |
| Navigation | No additional bottom tab |

The limit is **3 receipts/week**, not three daily receipts, three tasks, three signatures, or one receipt/day. Users can create three on the same day. One receipt may contain one task or several. Generating another receipt from the same tasks is allowed and consumes another slot.

₹199 is the selected launch price, not proven willingness to pay. Configure it in Play Console; display the store-provided localized price in production. Other markets use configured local equivalents. The UI must not claim a purchasable price when product loading has failed.

## 4. Reference observations and adaptation

The supplied screenshots show a Photo/Hand drawn selector, camera permission and preview, capture/retake, a monochrome halftone result, freehand drawing with a clearing control, a sign-off action, and final paper containing artwork and task information. The earlier video additionally demonstrated paper bending and a session summary.

Adapt these elements:

- Optional personal artwork as the centrepiece of the reward.
- Monochrome dotted/thermal treatment for photos and drawings.
- Paper reveal, subtle curl, touch response, and sharing.
- Saved receipt collection integrated with existing Completed/Insights data.

Do not copy the timer, break count, time chart, “100% on task,” session vocabulary, browser permission dialog, or the reference’s heavy raised-plastic styling. Use native Android permission behaviour and SyncTasks’ calm, flat UI. Only the receipt paper/viewer receives physical depth.

## 5. Navigation and entry points

| Location | Entry | Destination and selection |
| --- | --- | --- |
| Today | `2 completed today · Create receipt →` | Composer with today's completed tasks preselected |
| Lists → Completed | Selection action `Create receipt` | Composer with selected completed occurrences |
| Lists → Insights | `Create receipt` for displayed period | Composer with completions in that period |
| Lists → Receipts | Receipt-history row | Saved history; Create receipt opens completed-task selector |
| Settings → SyncTasks Pro | Price or Pro status | Purchase sheet or owned-state details with restore |

### 5.1 Today placement

Place one subtle row below the final active task, aligned with task-title text. Use a small outlined receipt icon, secondary-colour completion count, and black Create receipt action. Keep an adequate touch target even though visual text is compact.

- Show after at least one completion on the current local day, including originally overdue or undated tasks completed today.
- Reflect completion timestamp, not scheduled date.
- When all active tasks are complete, put it beneath the empty-state message.
- Update count when a completion is undone.
- No automatic modal, additional floating button, upgrade badge, or persistent notification.
- Existing top controls, task-add button, and bottom navigation remain unchanged.

### 5.2 Lists placement

Organisation hub order: **All → Today → Upcoming → Completed → Receipts → Insights**.

Receipts uses an outlined paper icon and right chevron, matching current row spacing and separators. No Pro lock, quota badge, or task counter on this row. It is visible even with no receipts or no remaining quota. Preserve My Folders, Inbox, Reminders, and existing navigation.

### 5.3 Completed and Insights

Reuse existing multi-select where possible. Receipt selection includes only completed task occurrences. A recurring successor is a separate task/occurrence and is not automatically included.

An Insights entry uses the displayed date range, not an independently calculated competing week. No matching completions means an empty explanation, not a blank receipt. Existing insights remain available without purchasing.

### 5.4 Suggested routes

Follow actual GoRouter naming conventions; these are proposed route responsibilities, not required literal paths:

| Route | Responsibility |
| --- | --- |
| `/receipts` | History and empty state |
| `/receipts/new` | Composer consuming a draft/selection ID |
| `/receipts/:id` | Saved receipt detail |
| `/receipts/:id/edit` | Edit an existing saved receipt |

Use sheets for artwork and purchase, and the existing task-selection surface where practical. Do not put task titles, image bytes, or serialized drawings into navigation URLs.

## 6. Creation flow and receipt options

Flow: **Entry → select completed tasks → compose → optionally personalise → Generate receipt → durable save → printing animation → saved detail**.

One task, today, weekly, and custom selections are entry presets over one model, not separate premium products or rendering systems.

| Option | Default and behaviour |
| --- | --- |
| Tasks | Entry-specific preselection; user can remove/add completed tasks |
| Order | Completion time ascending, with stable ID tie-break; no drag reordering in first release |
| Title | `Today’s wins` for Today; `This week’s wins` for weekly preset; otherwise `Completed tasks` |
| Custom title | Editable, trimmed; empty falls back to default; 80-character input limit |
| Artwork | None until user adds it; personalisation sheet initially selects Hand drawn |
| Drawing | Signature, doodle, or illustration with Undo and Clear |
| Photo | Camera or picker, crop, monochrome processing, contrast, replace/retake |
| Folder labels | Off by default; optional toggle |

Only one artwork type per receipt in the first release. Changing type replaces artwork in the draft after confirmation if the previous artwork would be lost. No automatic reuse of a prior signature.

At least one completed task is required. Support ordinary long selections without silently truncating names or dropping tasks; rendering/export pagination is described below. There is no commercial limit on task count inside a receipt.

## 7. Composer screen

Use a full-screen composer, rather than putting a long receipt into a cramped bottom sheet.

Contents, top to bottom:

1. Back action and `Create receipt` heading.
2. Allowance: `2 of 3 free receipts left this week` or `Unlimited receipts` for Pro.
3. Editable title and `3 tasks selected · Edit`.
4. Scrollable preview with the same typography and layout used for output.
5. `Add photo or drawing` artwork affordance marked Optional.
6. Folder-label display option in a compact secondary area.
7. Fixed bottom `Generate receipt` action respecting safe areas and keyboard.

Generation is disabled while selection is empty or an image operation is unfinished. Disable repeated submission during a save. Back with dirty changes offers Discard/Keep editing; an autosaved draft can resume after process death. Drafts consume nothing and do not appear as completed history entries.

Resolve the earlier ambiguity between “Save receipt” and “Generate receipt”: **Generate receipt is the sole first-save action**. There is no second save step after printing. Editing uses **Save changes**.

Previewing remains free even when exhausted. Show remaining allowance honestly. Selecting Generate with zero remaining opens the purchase sheet and retains the draft. After a successful purchase, return to the intact composer; let the user tap Generate again rather than generating unexpectedly.

## 8. Artwork sheet

### 8.1 Shared structure

Heading `Personalise`, close action, two segments **Hand drawn · Photo**, generous canvas/preview, contextual controls, and **Use drawing** or **Use photo**. Closing without applying preserves the composer’s prior artwork.

### 8.2 Drawing

- Finger/stylus input; black ink and clean light canvas.
- Normalized vector strokes for resolution-independent rendering.
- Undo most recent stroke; Clear all.
- Prevent vertical sheet scrolling from stealing active drawing gestures.
- One sensible brush width initially; no palette, stickers, brush marketplace, or complex editor.
- Empty canvas cannot apply artwork; users can close and generate without it.
- Capture black ink cleanly; apply a light print treatment during receipt rendering without making handwriting illegible.

### 8.3 Photo

- Explicit source actions: Take photo / Choose photo.
- Ask camera permission only as a consequence of Take photo. Never on screen entry or app startup.
- Use Android-supported picker behaviour for gallery selection; do not demand broad photo-library access unnecessarily.
- Handle cancel, denied permission, unavailable camera, and returning from the external camera.
- Provide crop with a consistent receipt artwork aspect ratio (initial default 4:3), orientation correction, and a contrast slider.
- Process locally: decode → orient → crop/downsample → grayscale/contrast → ordered dot/halftone rendering.
- Retake/Replace before applying; keep original photo outside the app untouched.
- Store only the cropped source needed for future adjustment and processed artwork; do not retain full-resolution uncropped originals unnecessarily.
- Remove location/EXIF metadata from derived output.
- Permission denial leaves Hand drawn and no-artwork paths available.

## 9. Receipt content and canonical layout

One canonical template in the first release. Free and Pro have identical rendering.

Order:

1. Small actual SyncTasks logo; restrained brand label.
2. Receipt title.
3. Completion date or date range for selected tasks.
4. Optional artwork.
5. Dotted divider.
6. Completed task rows, with optional folder subtitles.
7. Dotted divider.
8. `3 tasks completed` total.
9. Small receipt display number and `Generated ...` timestamp.

The preview, printing texture, saved detail, thumbnail, and export must be derived from the same render document. Do not reproduce the generated concept board’s inconsistencies: its composer omitted the title inside the paper and placed artwork differently from the finished receipt. This written order overrides those illustrative differences.

No-artwork receipts collapse the artwork space. Long titles wrap; Unicode and emoji use a suitable fallback font. Count tasks, not folders or days. Paper may use a restrained monospace font for metadata while surrounding app UI follows existing typography. Off-white app, white paper, black ink, subtle edge/shadow; no colourful decorations or mandatory watermark upgrade.

Receipt numbers are presentation identifiers, not purchase receipts or proof of verified work. Distinguish completion dates from generation dates. Saved receipts reflect user-recorded completion, not independent validation.

## 10. Animation specification and stack

The printing interaction is part of Phase 2’s first complete release, not a paid extra or disposable prototype.

### 10.1 Choreography

| Moment | Default target | Behaviour |
| --- | --- | --- |
| Save in progress | Actual operation duration | Button progress; do not pretend the print succeeded |
| Enter viewer | About 150 ms | Settle background and narrow printer slit |
| Feed paper | About 900–1,200 ms | Paper translates downward through a clip under the slit |
| Settle | About 180–250 ms | Small damped curl/rotation and shadow settle |
| Finish | One light haptic | Reveal Share receipt and Done |
| Touch interaction | Immediate | Bounded drag bend/tilt; damped spring on release |
| Replay | User-selected | Same reveal, no write or quota consumption |

Timing targets may be tuned after device testing without changing the flow. No default printing sound. A saved receipt opens immediately on subsequent visits; Replay lives in overflow. Reduced-motion preference uses a brief fade and disables drag deformation. Haptics respect app/platform settings.

Back during reveal safely exits: the receipt is already saved and stays in history. App backgrounding pauses visual work; resuming can show the saved result directly. Never delay persistence until animation completion.

### 10.2 Recommended Flutter implementation

- `AnimationController`, `Tween`, `CurvedAnimation`, and `AnimatedBuilder` for coordinated feed and controls.
- `Stack`, clipping, and translation for the printer slot and paper reveal.
- `CustomPainter`/Canvas for paper silhouette, dotted separators, edge, and artwork.
- `GestureDetector` and transforms for bounded touch response.
- Flutter spring simulation for release settling; `HapticFeedback` for finish.
- `RepaintBoundary` or a rendered picture/texture to isolate expensive static receipt content.

Flutter’s animation APIs support coordinated explicit animations; use the built-in stack rather than a separate timeline dependency. [Flutter animation overview](https://docs.flutter.dev/ui/animations/overview)

Phase 2 animation implementation first proves feed + subtle curl + drag tilt on a representative Android device. A segmented textured-paper mesh may then provide local bending. A simple whole-card transform must not be described as full physical paper simulation. Avoid rebuilding/reprocessing the receipt on each frame.

Fragment shaders are an optional rendering enhancement, not the baseline dependency. Flutter supports fragment shaders with documented constraints; they do not automatically supply paper physics. Do not require Rive, Lottie, a WebView, a JavaScript renderer, or a 3D game engine for dynamic task content. [Flutter shader documentation](https://docs.flutter.dev/ui/design/graphics/fragment-shaders)

### 10.3 Long receipts and accessibility

Keep controls outside the animated paper. For long content, animate the visible leading portion and transition to a scrollable flat view; do not shrink the whole receipt until text becomes unreadable. Distinguish vertical scroll from horizontal/edge drag so play gestures do not block reading.

Screen-reader users receive task content and actions through semantic widgets independent of Canvas rendering. Announce success once, not per animation frame. Respect large text, safe areas, contrast, and touch-target sizes. Static sharing excludes printer slot, app controls, quota, and shadows that waste export space.

## 11. Storage model

Drift is the source of truth for saved receipt records. App-private files hold images and thumbnails; drafts use a separate local store/table. Never depend on a camera cache or exported share file as the sole source.

Suggested entities (adapt names to the project):

| Entity | Fields and responsibility |
| --- | --- |
| `receipts` | UUID, unique creation operation ID, display number, title, created/updated UTC timestamps, display timezone/offset, selected date bounds, artwork type/reference, folder-label flag, template version, revision |
| `receipt_items` | Receipt ID, position, original task/occurrence reference, title snapshot, folder snapshot, completion UTC timestamp and display offset |
| `receipt_artwork` | Receipt ID, normalized stroke data or relative cropped-source/processed-image paths, crop/contrast parameters, renderer version |
| `receipt_usage_events` | Unique operation ID, receipt ID, UTC event time, week bucket, free/Pro grant type; independent of receipt deletion |
| `receipt_drafts` | Draft ID, source entry, selected references, composer options, temporary asset references, last edited time |
| `pro_entitlement` | Product ID, state, last verified timestamp, necessary billing references; no user task content |

Use UUIDs for identity; display sequence numbers are not primary keys. Store relative asset paths so directories can move. Index receipt history by creation time, items by receipt ID, and usage by week. Task links must not cascade-delete snapshots.

Drift transactions coordinate database writes, but cannot atomically commit filesystem changes. The following staged protocol is required. [Drift transactions](https://drift.simonbinder.eu/dart_api/transactions/)

### 11.1 Reliable generation sequence

1. Create/reuse an operation UUID for this Generate attempt; disable duplicate UI submissions.
2. Validate selected tasks are still completed and source media is readable. If selection changed externally, ask user to review; do not silently remove tasks.
3. Render/process media in staging files. This does not consume allowance.
4. Move verified assets into their final app-private paths. They may be temporarily unreferenced.
5. In one serialized database transaction: recheck entitlement and allowance, insert receipt and snapshots, attach asset references, insert exactly one usage event.
6. Commit; discard draft; trigger animation from committed receipt ID.
7. If transaction fails, retain recoverable draft and delete unreferenced staged/final assets. If process dies, cleanup reconciles unreferenced assets on a later launch.

A unique operation constraint makes retries idempotent. On ambiguous recovery, query by operation ID before trying another insertion. If the receipt exists, open it rather than charge another slot. Serialize creation attempts so concurrent composers cannot exceed free allowance.

Thumbnail failure must not invalidate a successfully saved receipt: regenerate thumbnails lazily. Filesystem cleanup should target known unreferenced receipt assets, never arbitrary user files.

### 11.2 Snapshot, edit, undo, and delete policy

Saved receipts are historical snapshots. Later renaming, moving, deleting, or reopening a task does not silently alter existing paper. This supersedes the early proposal that task undo would automatically invalidate/delete a receipt. An unsaved draft, however, must revalidate current completion at generation.

- Edit opens the same receipt ID and preserves its first creation date/display number.
- Save changes updates its revision, artwork/render output, and updated timestamp without consuming allowance.
- Existing snapshots remain readable if the original task is gone.
- When adding new tasks during edit, require those added tasks to be completed.
- Save as new creates a different receipt and consumes one slot.
- Delete requires confirmation, removes owned artwork and cached exports, and preserves usage accounting.
- Already shared copies cannot be recalled by local deletion.

Allowing free edits, including selection edits, means a user can repeatedly repurpose one receipt. This is an explicit consequence of the agreed edit rule; do not add an unapproved edit paywall. Commercial scarcity concerns additional saved receipt identities, not every change to content.

### 11.3 Persistence scope

Saved data survives app restarts and migrations. It is local-first, not guaranteed to survive uninstall, app-data clearing, or device loss. Purchase restoration restores entitlement, not locally lost receipts. Backup/sync of editable receipts is outside this release. Align Android backup exclusions with existing policy so cropped personal photos are not silently uploaded contrary to product expectations.

## 12. Allowance and weekly reset

Week starts **Monday 00:00 local time**, ending at next Monday. No rollover of unused slots. Calculate boundaries using calendar/timezone logic, not a fixed 168-hour duration across daylight-saving transitions.

- New successful generation consumes one event irrespective of task count or selected historical dates.
- Week is determined at commit time; preview before midnight does not reserve a prior-week slot.
- Reopen, replay, export, share, edits, failed save, and canceled draft consume zero.
- Deletion never refunds a slot.
- Pro grants are unlimited and do not consume free slots.
- If Pro later becomes invalid, count free grants already used in the current week; retain access to all saved receipts.

Persist the active week interval and timezone context. An ordinary timezone change must not immediately grant another three receipts: keep the established interval until its end, then compute the next interval using the current local zone. Clock rollback must not erase a bucket or usage ledger. Show an exact reset date in the UI.

This is an on-device allowance, not an account-wide or tamper-proof quota. Reinstallation/data clearing, modified clients, and deliberate clock manipulation cannot be robustly prevented without a server identity and trusted time. Accept this first-release tradeoff; do not introduce accounts/device fingerprinting into the task experience.

## 13. Purchase and entitlement behaviour

Use one Android non-consumable permanent upgrade, suggested ID `synctasks_pro_lifetime` (confirm against any existing SKU). No consumable receipt credits and no subscription.

Purchase sheet:

- `Unlimited receipts`.
- `₹199 once` using localized store price at runtime.
- Explanation: Free includes 3 receipts/week; Pro removes the limit.
- Purchase action, Restore purchases, close action.
- If exhausted: `3 of 3 free receipts used` and reset date.

Use Flutter `in_app_purchase` for product queries, purchase stream, non-consumable purchase, and restore. Validate purchased/restored events before granting entitlement; complete eligible purchases after delivery and handle retries. Do not unlock for pending/canceled transactions. [Official Flutter purchase package](https://pub.dev/packages/in_app_purchase)

Production design default: a small purchase-verification endpoint with no task/photo/receipt content; use existing infrastructure if present. Its responsibility is verifying store transactions and reporting entitlement. Keep credentials on the server. This is a billing dependency, not receipt cloud storage. Final hosting choice and credentials depend on the actual project environment and must be configured in Phase 2; a client-only “success” flag is not a substitute for verification.

Cache the last verified entitlement for offline receipt creation. A network failure alone must not revoke Pro. Reconcile purchases when connectivity/store access returns; apply actual revocation when verified. First purchase and fresh-install restoration require store connectivity. Product-unavailable and pending states preserve drafts and offer retry.

## 14. Receipt history, sharing, and export

History uses newest-generated first, with date groups, thumbnail, title, task count, and artwork preview. Empty copy: `Your completed work, worth keeping.` Action: `Create receipt`. No generated sample receipts mixed into production history.

Detail shows the paper immediately, Share receipt, Done/back, and overflow: Edit, Replay animation, Save as new, Delete. Save as new is subject to quota; replay is not.

Render a clean PNG locally and invoke Android sharing. Use `share_plus` for the platform share sheet, subject to project compatibility. Sharing a file does not create another saved receipt. [share_plus documentation](https://pub.dev/packages/share_plus)

Provide a separate Save image action through an appropriate Android destination flow if required by current app patterns; do not conflate Share with guaranteed gallery saving. No broad storage permission solely for app-private generation.

Default export width: 1,200 px, dynamically measured height with wrapped text. Implement tiled rendering or split exports for very long selections; provisional safe bound is 16 megapixels per image, to be tuned against the lowest supported device. If split, number parts and repeat a small identity header; never omit content. Preview and animated texture may use lower resolution than export.

Clean temporary share files later without deleting them while another app may still read them. Store thumbnails as derived cache; retain source snapshots and artwork for regeneration. No PDF, video export, public URL, or automatic social posting in this release.

## 15. Technical stack and responsibility boundaries

| Layer | Choice | Notes |
| --- | --- | --- |
| App | Flutter/Dart, Android | Reuse repository's supported versions |
| State | Riverpod | Draft, history, entitlement, allowance providers/controllers |
| Navigation | GoRouter | Existing route and sheet conventions |
| Persistence | Drift/SQLite | Receipts, item snapshots, usage ledger, migrations |
| Private files | Existing file service; `path_provider` if needed | Stable media paths and temporary staging |
| Capture/pick | `image_picker` | Camera/picker, cancellation and Android lost-result recovery |
| Crop | Simple Flutter crop UI | Reuse existing dependency if available; avoid adding a full editor |
| Image processing | Dart image-processing library or existing equivalent, version-reviewed | CPU halftone/crop work off UI isolate; never ImageGen/API |
| Drawing | Gesture input + normalized paths + CustomPainter | No signature-as-a-service |
| Paper renderer | Shared layout model, Canvas/TextPainter or existing render service | Consistent preview, texture, export |
| Animation | Flutter explicit animations, clipping, Canvas, spring simulation | Optional mesh/shader refinement |
| Share | `share_plus` | Android share sheet |
| Purchase | `in_app_purchase` + minimal verification service | Non-consumable Pro and restore |
| Observability | Existing Firebase Analytics/Crashlytics | Safe event data only |

`image_picker` documentation describes Android process-death/lost-result recovery and temporary camera-file behaviour; recover results and copy chosen media to owned storage before relying on it. [image_picker documentation](https://pub.dev/packages/image_picker)

Do not blindly upgrade dependencies to latest. Check actual Flutter/Dart, minSdk, targetSdk, Java, Gradle, and Android plugin compatibility. Example: current purchase package documentation lists Android SDK 24+; compare against SyncTasks' current support floor before adopting that version. Dependency versions belong in the repository lockfile after validation, not guessed here.

Suggested module responsibilities:

- `ReceiptRepository`: snapshots, revisions, history, transactions, cleanup references.
- `ReceiptDraftController`: editable selection and artwork state, draft recovery.
- `ReceiptGenerationService`: validation, staged assets, idempotent commit.
- `ReceiptQuotaService`: clock abstraction, week intervals, usage accounting.
- `ProEntitlementService`: store events, validation, cached access.
- `ReceiptRenderer`: deterministic document layout and artwork composition.
- `ReceiptAnimationController`: visual progress and gestures only; no quota mutations.
- `ReceiptExportService`: render/export/share lifecycle.

These are conceptual boundaries, not a demand for eight single-method classes. Match existing architecture and avoid unnecessary abstraction.

## 16. Privacy and telemetry

No task titles, folder names, signatures, photos, crop sources, search text, notes, or rendered images in analytics, crash breadcrumbs, or billing verification requests. Receipt generation and photo processing are entirely on-device.

Optional safe events: entry opened, generation succeeded/failed, share initiated, limit reached, upgrade opened, purchase completed/restored. Include only approved coarse attributes such as entry source, artwork type, and Free/Pro state. Do not log purchase tokens. Share events should mean the share sheet was invoked unless the platform actually confirms completion.

Do not add engagement notifications, daily nagging, or receipt reminders in this release. The user initiates the ritual.

## 17. Development Phase 1 — UI entries and navigation shells

### Objective

Integrate discoverable receipt entry points into the existing app without claiming real generation, saving, or billing exists. This phase is a reviewable UI/navigation change, not a shipped half-functional paid feature.

### Deliverables

1. Today conditional receipt row under active tasks, driven by existing completion data where available.
2. Receipts row between Completed and Insights in Organisation hub.
3. Completed multi-select Create receipt action.
4. Insights period entry.
5. Settings SyncTasks Pro entry.
6. Route scaffolding to empty history and a minimal composer shell accepting selection context.
7. Development-only sample states for no completions, some completions, history empty, and long lists.

Do not implement real photo permissions, drawing engine, media processing, printing physics, persisted receipt schema, usage deduction, store purchase, or share export in Phase 1. Do not represent fixture quota as a real user entitlement.

Use a feature flag/internal build while destinations are incomplete. Navigation shells can communicate upcoming functionality in internal QA, but release builds must not expose a broken Generate/Purchase button. The detailed composer/artwork/printing mockups are design references for Phase 2, not an expansion of Phase 1 into the whole feature.

### Phase 1 sequence

| Step | Work | Verification |
| --- | --- | --- |
| P1.1 | Inspect existing theme, routes, completion providers, widgets | Map actual touchpoints; no unrelated redesign |
| P1.2 | Add Today row and Lists row | Compare supplied screenshots; verify positioning and scrolling |
| P1.3 | Add Completed/Insights/Settings entries | Selection/range context is passed correctly |
| P1.4 | Add shells and feature flag | Back navigation and disabled states are honest |
| P1.5 | Visual/device review | Light/dark if supported, large text, long task lists |

### Phase 1 acceptance gate

- Today row appears only for today's real completions and updates after undo.
- Lists order, existing counters, folder/reminder sections, and bottom tabs remain correct.
- No new timer, bottom tab, purchase request, or receipt permission prompt.
- Existing task completion, recurrence, quick add, and search behaviour are unaffected.
- Every new entry reaches the intended shell and returns safely.
- Fake data cannot reach production persistence or billing.

## 18. Development Phase 2 — Actual end-to-end integration

### Objective

Deliver the complete receipt experience from task selection through purchase entitlement, durable generation, animation, history, and sharing.

### Ordered work packages (all belong to Phase 2)

| Step | Work | Depends on |
| --- | --- | --- |
| P2.1 | Models, Drift migration, draft and snapshot repositories, clock/quota contracts | Phase 1 route map |
| P2.2 | Composer, task selection, title/folder options, canonical renderer | P2.1 |
| P2.3 | Drawing/photo sheets, halftone processing, media recovery | P2.2 |
| P2.4 | Transactional/idempotent generation and usage ledger | P2.1–P2.3 |
| P2.5 | Printer reveal, settle, touch response, reduced motion | Stable renderer and saved result |
| P2.6 | History/detail, edit/delete, replay, image share/save | Durable receipt model |
| P2.7 | Billing product, verification endpoint, purchase/restore, quota paywall | Entitlement contract; store setup |
| P2.8 | Failure recovery, accessibility, privacy, Android performance and regression checks | Complete vertical flow |
| P2.9 | Internal release validation and remove placeholder states | All acceptance gates |

Prove a vertical slice early: one completed task → text-only receipt → local commit → reveal → reopen. Then add artwork and billing without changing the generation contract.

### Phase 2 acceptance gate

- A free user generates three receipts in a week; a fourth requires Pro or the next reset.
- One/multiple tasks and different entry sources share the same quota.
- Drawing, photo, and text-only creation work without network.
- No permission is needed for drawing or text-only creation.
- Generation survives duplicate taps, process interruption, and thumbnail failure without double charging.
- A committed receipt remains saved if animation is interrupted.
- Pro purchase and restore grant unlimited access only after validation.
- Verified Pro continues offline; temporary verification failure does not remove access.
- History, edits, exports, and replay remain accessible at zero allowance.
- No task content is sent to Firebase or billing services.
- Existing app flows pass targeted regression checks.

## 19. Meaningful verification matrix

| Scenario | Expected result |
| --- | --- |
| Zero completed tasks | No Today entry; selector explains empty state |
| One task vs 40 selected tasks | Correct snapshots/count; long content readable/exported |
| Recurring task completion | Only selected completed occurrence included |
| Undo before generation | Composer requests selection review; no quota consumed |
| Undo/delete after generation | Historical receipt remains intact |
| Double Generate tap | One receipt and one event |
| Crash before transaction | No consumed slot; recover draft/clean assets |
| Crash after commit | Reopen existing receipt by operation ID |
| Camera canceled/denied | Return safely; drawing/text available |
| Android process killed during picker | Recover pending media result or explain recovery failure |
| Corrupt/large/rotated photo | Controlled failure or correct downsample/orientation; UI responsive |
| Sunday→Monday | Exactly one new calendar allowance; commit time governs |
| Clock/timezone change | No ledger deletion or accidental immediate refill |
| Delete receipt | Slot not refunded |
| Edit or replay | No new slot |
| Save as new | New slot and ID |
| Fourth free generation | Purchase sheet; draft preserved |
| Pending/canceled purchase | No Pro grant; original draft remains |
| Restore on fresh install | Pro restored; no claim that lost local receipts return |
| Offline verified Pro | Unlimited local generation remains available |
| Reduced motion / large text | Accessible fade and readable controls |
| Long export | No clipped task rows or silent truncation |

Automated tests should target ledger/idempotency, week boundaries, migrations, entitlement transitions, and snapshot preservation. Widget tests should cover conditional entries and critical composer states. Use actual Android device/emulator checks for camera/picker lifecycle, sharing, Play test purchases, and animation. Avoid tests that merely duplicate widget implementation.

Performance goal: smooth interaction at the tested device refresh rate, with a practical 60 fps baseline where supported. Profile in profile/release mode; a 60 Hz frame has about 16.7 ms budget. Do not decode/halftone photos or rebuild full paper layout on every animation frame. Benchmark large artwork and long receipts on a lower-end supported device before shipping.

## 20. UI copy baseline

| Context | Copy |
| --- | --- |
| Today | `2 completed today · Create receipt` |
| Lists | `Receipts` |
| Composer | `Create receipt` |
| Free quota | `2 of 3 free receipts left this week` |
| Pro quota | `Unlimited receipts` |
| Add artwork | `Add photo or drawing` / `Optional` |
| Artwork | `Personalise` / `Hand drawn` / `Photo` |
| Apply artwork | `Use drawing` / `Use photo` |
| First save | `Generate receipt` |
| Printing | `Printing your wins…` |
| Result | `Your receipt` / `Share receipt` / `Done` |
| Gesture hint | `Drag to play` (show once; omit for reduced motion) |
| Exhausted | `3 of 3 free receipts used` plus actual reset date |
| Upgrade | `Unlimited receipts` / localized price + `once` |
| Edit | `Save changes` |

Use pluralization and localization helpers, not string concatenation for all counts. Task content remains user-authored and is not translated automatically.

## 21. Exclusions and later possibilities

Excluded from both phases: timer, sessions, breaks, productivity scoring, mandatory signing, subscriptions, receipt-credit packs, paid-only artwork, new bottom tab, AI image generation, cloud receipt accounts, public feed, physical printer integration, PDF/video export, notification campaigns, automatic daily generation.

Possible later work after real usage: additional monochrome templates for all or revised packaging, richer paper deformation, milestone presets, editable backup, animated export. None is a dependency for the locked release. Do not assume permission to redesign the revenue model or charge for these extras.

## 22. Reference inventory

- `synctasks(2).md`: current product/stack baseline.
- Current Today screenshot: title/date, top calendar/search/settings controls, task rows, +, Today/Lists bottom navigation.
- Current Lists screenshot: Organisation hub, Completed/Insights, My Folders, Reminders.
- Generated Today mockup: subtle receipt action below remaining tasks.
- Generated Lists mockup: Receipts between Completed and Insights.
- Reference website screenshots: Photo/camera, halftone preview, Hand drawn, final paper.
- Reference video: tangible paper interaction; timing/session content is excluded.
- Generated four-screen board: Compose → Personalise → Printing → Receipt. Illustrative; canonical Section 9 overrides inconsistencies.
- Reference URL: https://taskrecipets.vercel.app/ — supplied visual evidence was used; the site was not successfully live-audited during this conversation.

This document is self-contained. These references explain the design origin and are not runtime dependencies or permission to reuse another site's source code/assets.

## 23. Conversation decision history and superseded proposals

| Discussion stage | Outcome |
| --- | --- |
| Website identification | Direct site access failed; uploaded video established task-to-receipt concept |
| Initial feasibility | Optional receipt fits SyncTasks; retain fast normal completion |
| Daily vs per-task | Daily was initially preferred; later user explicitly chose a general 3-receipt weekly quota |
| First free/Pro proposal | Free daily receipts; paid weekly/custom/styles at ₹199 — rejected by user as weak value |
| Full paywall vs allowance | User preferred attachment through limited full experience; 3/week selected |
| Revenue lock | Free 3 receipts/week, complete experience; Pro unlimited, ₹199 once |
| App scope correction | No timer; current Today/Lists architecture overrides older Focus concepts |
| Today placement | Compact row under remaining tasks; no completion popup |
| Lists placement | Receipts between Completed and Insights |
| Reference screenshots | Add optional Photo and Hand drawn modes with thermal treatment |
| User selected items 3 and 4 | Prioritized composer/generation and animation design, not deletion of storage/billing requirements |
| Four-screen design | Compose, Personalise, Printing, Receipt; visual mockup only, no implementation claim |
| Current request | Consolidate full scope into two phases: UI entries, then full integration |

Conflict resolutions fixed for development:

1. General receipts, not daily-only allowance.
2. Pro removes quantity limit; no separate paid receipt types/styles in launch baseline.
3. Generate receipt saves before animation; no post-animation save required.
4. Saved receipts are snapshots; task undo does not destroy them.
5. Preview is free at zero quota; enforcement occurs at Generate/commit.
6. Photo and drawing are optional and included for Free.
7. Basic printer reveal and touch response are required; advanced physical simulation is optional refinement.
8. Phase 1 is entry/navigation work; composer engine and reward implementation are Phase 2.
9. Receipt paper is a personal keepsake, not evidence of tracked hours or independently verified completion.

## 24. Development start checklist

- [ ] Read repository instructions and existing app architecture.
- [ ] Confirm current Today/Lists navigation against supplied baseline.
- [ ] Identify completion timestamp and recurring occurrence identity in schema.
- [ ] Identify existing entitlement/billing service, if any, and reuse it.
- [ ] Confirm dependency compatibility and minimum supported Android version.
- [ ] Implement Phase 1 only, review entry placement, then proceed to Phase 2.
- [ ] Configure Play product and purchase verification before claiming monetisation is complete.
- [ ] Keep this spec updated if implementation evidence requires a behaviour change; do not silently substitute a prior rejected option.

End state: a user completes work normally, chooses a receipt, personalises it or skips artwork, generates it once, enjoys the reveal, and can reopen/share it later. Three new receipts per week are free; a one-time Pro purchase removes the limit.
