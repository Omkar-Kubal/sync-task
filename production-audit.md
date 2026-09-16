# SyncTasks Pre-Production Android Audit

Date checked: 2026-09-15  
Repository: `D:\AppyLabs\sync-task`  
Branch / commit: `v2/synctasks` / `094ee15`  
Recommendation: **NOT READY**

## 1. Scope, Environment, And Limitations

Audited the Flutter Android app from source, tests, release artifacts, and a release APK running on an emulator. I did not modify application code, delete production data, publish anything, or perform real purchases.

Build identity inspected:

- App ID: `com.appylab.synctasks`
- Version: `1.0.0` / versionCode `1`
- Release APK: `build\app\outputs\flutter-apk\app-release.apk`, 73.8 MB, download-size estimate 39.8 MB
- Release AAB: `build\app\outputs\bundle\release\app-release.aab`, 67.8 MB
- minSdk / targetSdk: `24` / `36`
- Release debuggable: `false`
- Play Billing client manifest version: `8.0.0`
- Device tested: `emulator-5554`, Android `17` / SDK `37`, 1080x2400 @ 420 dpi, package target SDK `36`

Verification run:

- `flutter analyze`: PASS, no issues
- `flutter test`: PASS, 288/288 tests
- `flutter build appbundle --release`: PASS, built `app-release.aab`
- `flutter build apk --release`: PASS, built fresh `app-release.apk`
- `flutter pub outdated`: PASS command, many older constrained dependencies reported
- Release install: PASS on emulator

Limitations:

- Play Console was not accessible, so Data Safety, app content, app-access instructions, content rating, pricing/product setup, closed testing gates, pre-launch reports, and store listing checks are **BLOCKED**.
- No authorized Play license-test account/sandbox purchase environment was available, so purchase success/cancel/pending/refund/revocation/restore against Play are **BLOCKED**. I did not make purchases.
- No previous published version APK/AAB was available, so upgrade/migration from production is **BLOCKED**.
- The emulator had system instability (`Digital Wellbeing` and `System UI` ANR dialogs) and stylus-handwriting overlays. I separated those as environment limitations, but the app-specific permission prompt, core task flow, receipt flow, and paywall were still testable afterward.

Official documentation checked on 2026-09-15:

- [Google Play target API level requirements](https://developer.android.com/google/play/requirements/target-sdk)
- [Google Play Billing Library release notes](https://developer.android.com/google/play/billing/release-notes)
- [Google Play Billing deprecation FAQ](https://developer.android.com/google/play/billing/deprecation-faq)
- [Android notification runtime permission](https://developer.android.com/develop/ui/views/notifications/notification-permission)
- [Android app data backup](https://developer.android.com/identity/data/autobackup)
- [Google Play Data safety](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Advertising ID policy/help](https://support.google.com/googleplay/android-developer/answer/6048248)

## 2. Feature Inventory

Implemented or declared in code/tests:

- Onboarding, splash, Today, Lists, list detail, Upcoming, Search, Settings, Insights
- Task CRUD, completion/restore, delete, bulk actions, folders, recurrence, reminders
- Local Drift database with migrations through schema version 5
- Local notifications and reminder scheduling
- Android widgets: progress, inbox quick-add, today list
- Quick Add overlay activity from widget
- Receipt composer/history/detail, receipt quota, drawing/photo personalization
- One-time lifetime receipt unlock via Google Play Billing
- Firebase Crashlytics and Analytics
- App theme, haptics, sounds

Not found / not applicable:

- Subtasks: **NOT APPLICABLE**
- Sync/back-end user accounts: **NOT APPLICABLE** from inspected code
- Ads UI: **NOT APPLICABLE**, but ad/advertising permissions are present via SDKs and must be declared if collected
- Focus timer UI: **NOT APPLICABLE for release surface**; routing redirects `/focus` to Today and tests assert focus is not exposed

## 3. Coverage Matrix

| Area | Status | Evidence |
|---|---:|---|
| Repo/docs/build config inventory | PASS | `README.md`, `synctasks.md`, `pubspec.yaml`, Gradle files inspected |
| Static analysis | PASS | `flutter analyze` no issues |
| Unit/widget tests | PASS | `flutter test` 288/288 passed |
| Release AAB build | PASS | `app-release.aab` built in 223.9s |
| Release APK build/install | PASS | Fresh `app-release.apk` installed on emulator |
| Manifest/package facts | PASS | apkanalyzer: app id, SDKs, permissions, debuggable false |
| First launch/onboarding | FAIL | Immediate notification permission prompt before onboarding; denial flow required two denials before onboarding appeared |
| Task create/complete | PASS with caveat | Created `Audit task`, completed it; emulator handwriting had to be disabled |
| Receipt composer | PASS opening | Composer opened and preselected completed task |
| Receipt generation | FAIL | Generate tap did not save a receipt; history still “No receipts yet” |
| Paywall unavailable billing state | PASS with risk | Disabled purchase and showed “Payments are not available,” but hardcoded `₹199` remained |
| Real purchase success/cancel/pending | BLOCKED | No license-test Play environment; no purchases made |
| Restore purchase with real Play account | BLOCKED | No license-test Play environment |
| Widgets on launcher | NOT TESTED | Emulator/system instability; only code/static tests covered widgets |
| Notification delivery/deep links | BLOCKED/PARTIAL | Permission prompt tested; scheduled delivery not verified |
| Upgrade from previous release | BLOCKED | No previous release artifact |
| Play Console declarations/listing | BLOCKED | No Console access |
| Performance | PARTIAL | Startup `am start -W` captured but first run contaminated by system ANR; no reliable jank/Perfetto metric |

Evidence artifacts are under `archive\production-audit-2026-09-15\`.

## 4. Prioritized Findings

### F-001 High: Receipt generation does not persist on device

Category: Monetization / data integrity / receipt feature  
Affected feature: Receipt generation

Evidence:

- Release composer opened with selected completed task: `archive\production-audit-2026-09-15\16-receipt-composer.xml`
- After tapping Generate, app landed on Lists: `archive\production-audit-2026-09-15\17-after-generate-receipt.xml`
- Opening Receipts afterward showed “No receipts yet”: `archive\production-audit-2026-09-15\18-receipts-from-lists.xml`
- Code expects `generateReceipt`, `_printingReceipt`, then navigation to `/receipts/$receiptId`: `lib\features\receipts\screens\receipt_composer_screen.dart:141`

Expected: Generate saves one receipt and opens printing/detail/history with that receipt.  
Actual: No saved receipt was visible after generate attempt.  
Impact: Core receipt feature and paid quota/paywall value proposition are unreliable; this is a release blocker.  
Suspected root cause: Device tap/navigation path or bottom action interaction differs from widget tests; no Flutter fatal was present in logcat.  
Fix: Add an integration test on emulator for “complete task -> create receipt -> generate -> receipt detail/history contains receipt”; inspect hit testing/navigation around `ReceiptBottomActionBar` and receipt route transitions.  
Regression check: On release APK, generate three free receipts, verify each row in history, quota increments, process restart preserves receipts, and fourth generation opens paywall.

### F-002 High: First launch asks notification permission before onboarding and denial disrupts app entry

Category: Permissions / onboarding / UX  
Affected feature: First launch, notifications

Evidence:

- Permission prompt: `archive\production-audit-2026-09-15\04-after-systemui-wait.xml`
- First denial returned to launcher: `archive\production-audit-2026-09-15\05-after-notification-deny.xml`
- Relaunch prompted again with “Don’t allow”: `archive\production-audit-2026-09-15\06-relaunch-after-deny.xml`
- Onboarding appeared only after second denial: `archive\production-audit-2026-09-15\07-after-second-deny.xml`
- Startup calls notification initialization immediately: `lib\main.dart:32`
- Initialization requests Android notification permission: `lib\core\notifications\notification_service.dart:83`

Expected: First launch explains the app, then asks notification permission contextually when user enables reminders/notifications. Denial should return to onboarding/app.  
Actual: Permission prompt appears before onboarding and denial can leave user at launcher.  
Impact: Poor first-run conversion, increased permanent notification denial, possible pre-launch report issue.  
Root cause: `NotificationService.initialize()` is kicked off at app startup and calls `requestNotificationsPermission()`.  
Fix: Defer notification permission request until Settings/reminder setup, preserve denied state, and ensure denial resumes the app.  
Regression check: Fresh install on Android 13+ launches onboarding with no OS permission prompt; creating a reminder triggers contextual prompt and denial leaves user in app.

### F-003 High: Paywall displays hardcoded `₹199` when Play billing/catalog is unavailable

Category: Purchases / store claims / localization  
Affected feature: Receipt Pro paywall

Evidence:

- Paywall on non-Play emulator: `archive\production-audit-2026-09-15\20-paywall.xml`
- UI shows “Lifetime, ₹199” and disabled “Unlock for ₹199” while also saying payments unavailable.
- Hardcoded fallback price: `lib\features\receipts\widgets\receipt_pro_paywall_sheet.dart:280` and `:429`
- Product ID: `lib\features\receipts\pro\receipt_pro_products.dart:3`

Expected: If Play product details are unavailable, do not present a regional price claim; show unavailable/loading/retry.  
Actual: Hardcoded INR price appears without product details.  
Impact: Mismatch between store price and app paywall can cause purchase rejection or user trust issues.  
Fix: Only render price from `ProductDetails.price`; when unavailable, replace lifetime card/button price with “Price unavailable” and keep checkout disabled.  
Regression check: Test no catalog, catalog error, INR catalog, non-INR catalog, pending, restored, and purchased states.

### F-004 Medium: Release build disables minification and resource shrinking

Category: Release configuration / size / reverse engineering  
Affected feature: Release artifact

Evidence:

- `isMinifyEnabled = false`, `isShrinkResources = false`: `android\app\build.gradle.kts:55`
- Release APK 77,376,099 bytes; AAB 71,131,615 bytes; estimated download 39,790,954 bytes.

Expected: Pre-production release should intentionally decide R8/resource shrinking with keep rules validated.  
Actual: Shrinking is off.  
Impact: Larger download/install size and easier reverse engineering.  
Fix: Enable minification/resource shrinking in a release-candidate branch, add keep rules for Flutter/Firebase/Billing/notifications only as needed, and run release smoke tests.  
Regression check: Build installable release APK/AAB, verify Crashlytics mapping upload, Billing, notifications, widgets, receipt photo capture, and app startup.

### F-005 Medium: Merged release manifest includes sensitive/privacy-relevant permissions not declared in source manifest

Category: Privacy / Play Console declarations  
Affected feature: SDK integrations

Evidence from release APK:

- `com.google.android.gms.permission.AD_ID`
- `android.permission.ACCESS_ADSERVICES_AD_ID`
- `android.permission.ACCESS_ADSERVICES_ATTRIBUTION`
- `com.android.vending.BILLING`
- `android.permission.INTERNET`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `FOREGROUND_SERVICE`, `VIBRATE`, install-referrer
- Source manifest declares only notifications, boot completed, camera feature, widgets/provider: `android\app\src\main\AndroidManifest.xml:1`

Expected: Every collected/shared data type and SDK purpose is reflected in Play Data Safety and permissions declarations.  
Actual: Console cannot be verified; AD ID/ad-services permissions are present even though app has no ads UI.  
Impact: Inaccurate Data Safety or undeclared AD ID use can block release.  
Fix: Verify Firebase Analytics/Crashlytics collection, remove AD ID if not needed or disclose it accurately, and align Play Console declarations.  
Regression check: Inspect merged manifest after SDK updates and compare to Data Safety answers.

### F-006 Medium: Local-first private data backup policy is not explicit

Category: Privacy / data retention / restore integrity  
Affected feature: Local database and settings

Evidence:

- SQLite DB stored in app documents: `lib\core\database\app_database.dart:123`
- Release manifest does not explicitly show `allowBackup`, `dataExtractionRules`, or `fullBackupContent`.
- App stores task titles, folders, completion history, receipt snapshots, photo paths, and settings.

Expected: A task/privacy app explicitly chooses backup behavior and tests restore/migration.  
Actual: Backup policy is implicit and backup/restore was not tested.  
Impact: Private tasks/receipts may be backed up/restored unexpectedly, or restored data may not match migration assumptions.  
Fix: Decide product policy: disable backup, or add data extraction rules excluding caches/photos as appropriate; document Data Safety.  
Regression check: Fresh install -> create data -> device backup/restore or `bmgr` test -> verify database, widgets, reminders, and entitlements reconcile.

### F-007 Medium: Accessibility gaps in input/actions

Category: Accessibility / UX  
Affected feature: Create task sheet and receipt title fields

Evidence:

- Task title `EditText` is NAF with empty `content-desc`: `archive\production-audit-2026-09-15\09-create-sheet.xml`
- Inner submit button is also NAF, although parent has `Submit task`.
- Receipt title field has text but empty content-desc: `archive\production-audit-2026-09-15\16-receipt-composer.xml`

Expected: TalkBack announces labels, values, and actions clearly.  
Actual: Some controls rely on hints/parent semantics and are flagged by UIAutomator.  
Impact: Accessibility quality issue and possible Play pre-launch accessibility warning.  
Fix: Add explicit `Semantics(label: ...)` for text fields and merge/exclude nested button semantics consistently.  
Regression check: UIAutomator dump has no NAF for primary task/receipt controls; TalkBack order is verified manually.

### F-008 Medium: Camera receipt capture is not lifecycle-safe

Category: Lifecycle / data loss  
Affected feature: Receipt photo personalization

Evidence:

- `pendingPhotoResult` and `pendingPhotoFile` are in-memory only: `android\app\src\main\kotlin\com\appylab\synctasks\MainActivity.kt:14`
- Uses deprecated `startActivityForResult`: `MainActivity.kt:30`
- Temp file is created before camera launch: `MainActivity.kt:62`

Expected: Camera capture survives process death/configuration and cleans orphan temp files.  
Actual: If process dies while camera is open, pending callback/file state is lost.  
Impact: User may lose photo attachment or leave orphan files.  
Fix: Use Activity Result API or persist pending file URI; clean abandoned `receipt_photos` temp files.  
Regression check: Start camera, background/kill app, return/cancel, verify no crash and no orphan file accumulation.

### F-009 Low: Release logs and AppOps noise should be reviewed

Category: Observability / release polish  
Affected feature: Sounds/widgets/SDKs

Evidence:

- Repeated release logcat: `AppOps: attributionTag not declared in manifest of com.appylab.synctasks`
- Native widget code uses `Log.d` unconditionally: `android\app\src\main\kotlin\com\appylab\synctasks\SyncTasksWidget.kt:63`

Expected: Release logcat should be low-noise and actionable.  
Actual: No fatal crash, but repeated platform warnings and native debug logs exist.  
Impact: Low direct user impact; can obscure real issues and pre-launch reports.  
Fix: Gate native widget logs behind `BuildConfig.DEBUG` and identify SDK/source of AppOps attribution warnings.  
Regression check: Release smoke logcat has no repeated app-owned warnings during core flows.

## 5. Release Blockers

1. Receipt generation must persist and open/show receipts reliably. Current release device test failed.
2. First-run notification permission request must be deferred/contextual and denial must keep user in-app.
3. Purchase/paywall pricing must come from Play product details or be hidden when unavailable.
4. Play Console Data Safety, permissions, pricing/product, and store listing claims must be verified before release.

## 6. Recommended Remediation Order

1. Fix receipt generation device failure; add emulator integration test.
2. Move notification permission request out of startup; retest first launch and denied state.
3. Remove hardcoded fallback price from paywall; verify product IDs and real catalog.
4. Decide backup/privacy policy and align manifest plus Data Safety.
5. Audit merged permissions and remove/declare AD ID/ad-services as appropriate.
6. Enable or intentionally defer R8/resource shrinking with documented rationale.
7. Run full accessibility pass with TalkBack and large text.
8. Run purchase sandbox tests and Play Console checks.

## 7. Cleanup Candidates

Do not delete without owner approval:

- `archive\qa-*`, `archive\qa-artifacts\...`: Large historical QA evidence; keep if useful, otherwise move to external artifact storage.
- `.dart_tool`, `build`, `android\.gradle`, `android\.kotlin`: Generated/cache directories are present in workspace and total several GB; should not be committed.
- `android\app\src\main\kotlin\com\example`: Empty package path; cleanup candidate if truly unused.
- `android\key.properties`: Contains signing references/secrets; ensure it is ignored and never committed.
- `lib\features\lists\screens\black_placeholder_screen.dart`: Still routed by `/lists/more` but tests say unavailable Notion placeholder is hidden; confirm whether dead.

## 8. Manual Checks Requiring Developer Or Console Access

- Play Console app bundle upload validation and pre-launch report.
- Target API, device catalog, ABI/screen support from Play Console.
- Data Safety: tasks/receipts, analytics, crash logs, AD ID, diagnostics, purchase data.
- Privacy policy URL and in-app support/about links.
- Content rating and audience selection.
- App-access instructions: likely no login, but confirm.
- In-app product `synctasks_receipts_unlimited_lifetime`: type one-time/non-consumable, active regions, localized price, tax, availability.
- License-test purchases: success, cancellation, pending, restore, refund/revocation.
- Store listing screenshots/descriptions: ensure receipt/paywall and local-first claims match actual app.
- Account deletion: likely not applicable because no accounts; confirm Console answer.

## 9. Exact Checks Needed After Remediation

- Fresh install release APK on Android 13, 14, 15, 16/17 emulator or device:
  - no notification prompt before onboarding
  - complete onboarding
  - create task with whitespace, long text, emoji, Unicode
  - schedule today/tomorrow/custom date/reminder/repeat
  - complete, undo/restore, delete
  - search, lists, completed, insights
  - force-stop/relaunch and verify persistence
- Receipt flow:
  - generate 1, 2, 3 free receipts and verify history/detail after restart
  - fourth free generation opens paywall
  - catalog unavailable hides price
  - sandbox purchase unlocks and acknowledges
  - restore after reinstall/device change
- Notifications:
  - deny permission, allow permission, schedule reminder, tap deep link, reboot/reschedule
- Widgets:
  - add each widget, resize, quick add, complete from widget, app sync after process death
- Privacy/security:
  - merged manifest permissions diff reviewed
  - backup/restore policy tested
  - logcat checked for user content leakage
- Release:
  - `flutter analyze`
  - `flutter test`
  - `flutter build appbundle --release`
  - Play Console internal test upload
  - pre-launch report reviewed
  - Play Billing sandbox matrix passed
