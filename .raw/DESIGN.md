# Design System: SyncSpend Android
**Project ID:** `syncspend`

## 1. Visual Theme & Atmosphere
SyncSpend is a quiet, local-first finance utility with an intentionally restrained interface. The dominant mood is focused, minimal, and tactile: surfaces are broad, readable, and rounded; visual noise is kept low so money amounts, categories, and actions remain easy to scan.

The core app uses an iOS-like neutral Material 3 language rather than a colorful finance-dashboard style. Light mode feels airy and soft with pale system gray backgrounds and white surfaces. Dark mode is stark and OLED-friendly, pairing true black scaffolds with charcoal cards. The app should feel fast and calm, not gamified or decorative.

The product personality comes from bold Inter headings, generous white space, rounded cards, pill controls, compact icons, and small moments of motion. Data visualization is monochrome and utilitarian: bars, pies, legends, and summary rows should prioritize legibility over ornament. Pro surfaces add a warm premium accent, but only in paid or locked-feature contexts.

## 2. Color Palette & Roles
- **Light System Mist (#F2F2F7):** Light-mode scaffold and navigation background. It creates the soft app canvas behind cards.
- **Pure White Surface (#FFFFFF):** Light-mode cards, sheets, grouped settings sections, onboarding expense objects, and elevated content containers.
- **Ink Black (#000000):** Light-mode primary text, high-contrast action fills, onboarding emphasis, and dark-mode background.
- **Charcoal Surface (#1C1C1E):** Dark-mode cards and primary light-mode action fill. Use for important neutral surfaces and strong controls.
- **Deep Control Gray (#2C2C2E):** Dark-mode icon wells, dividers, input fills, and inactive pill backgrounds.
- **Sheet Edge Gray (#3A3A3C):** Dark-mode sheet borders and subtle separation around modal layers.
- **Secondary System Gray (#8E8E93):** Secondary labels, hints, top-bar icons, and supporting copy in both themes.
- **Muted System Gray (#636366):** Dark-mode tertiary copy, chart axis labels, and low-priority metadata.
- **Soft Divider Gray (#E5E5EA):** Light-mode dividers, borders, icon wells, and input fills.
- **Faint Muted Gray (#AEAEB2):** Light-mode tertiary labels, quiet helper text, and chart axis labels.
- **Dark Chart Ink (#1C1C1E):** Light-mode bar-chart marks and primary chart geometry.
- **White Chart Ink (#FFFFFF):** Dark-mode bar-chart marks and primary chart geometry.
- **Pro Amber (#D59B27 light, #F3C45B dark):** Premium emphasis for Pro checkout, status chips, and feature accents.
- **Pro Warm Ivory (#FFFCF7):** Light Pro sheet background. It separates monetization surfaces from the neutral app shell.
- **Pro Deep Night (#151515):** Dark Pro sheet background for richer, premium-feeling modal surfaces.
- **Modal Veil (#B8000000):** Bottom-sheet barrier color. It makes modal flows feel decisive without hiding context completely.

Use `AppColorScheme` semantic tokens for all app UI. Do not hardcode colors in widgets. Dynamic Material You colors may feed `ColorScheme`, but SyncSpend's own surfaces, text, cards, charts, and Pro tokens remain anchored by the app extension.

## 3. Typography Rules
SyncSpend uses **Inter** everywhere. The type system is crisp, modern, and compact, with no negative letter spacing. All styles should keep `letterSpacing: 0`.

Large app moments use heavy Inter: `h1` and major metrics are 28-32 dp with 700 weight, short line heights, and strong contrast. Screen titles, card titles, and row labels use medium-to-semibold weights from 13-24 dp. Body and metadata stay compact at 12-15 dp with softened secondary color.

Money values should read as data, not decoration. Use bold, one-line, scale-down text for totals and row amounts so long localized currency strings never overflow. Section labels are small, uppercase-feeling in hierarchy even when not transformed, and usually use muted gray to keep cards dominant.

## 4. Component Stylings
* **Buttons:** Primary actions are high-contrast filled controls: black on light surfaces and white on dark surfaces. Main CTAs are pill-shaped with 28 dp corners and at least 56-58 dp height. Floating add actions are circular, using the inverse foreground/background pair. Small save actions may be square 44 dp icon buttons using the filled-button theme. Text buttons stay quiet and inherit primary text color unless indicating destructive or system-error action.
* **Cards/Containers:** Standard cards are flat neutral rectangles with generously rounded 20-24 dp corners, no visible shadow, and 16-20 dp padding. Grouped lists use one continuous rounded card with 1 dp dividers inset after icons. Onboarding and welcome surfaces may use larger 28-34 dp rounding and soft shadows for a more celebratory first-run feel.
* **Inputs/Forms:** Forms live inside rounded card sections. Text fields are borderless, separated by subtle dividers, and use row-style labels rather than boxed input chrome. Bottom sheets use a transparent route background, a dark modal veil, a sheet surface, and 32 dp top corners. Picker sheets cap height and use compact list rows.
* **Navigation:** The home top bar is pill-based. The account selector is a stadium control with a thin border. Search, analytics, and settings sit inside a grouped pill with compact 36 dp icon buttons. Full screens use centered titles with a close icon on the left.
* **Rows & Lists:** Expense rows use 52 dp rounded-square icon wells, 16 dp horizontal rhythm, one-line titles, muted metadata, and right-aligned one-line amounts. Settings rows use smaller 36 dp icon wells and chevrons for drill-in actions. Pressable rows gently scale to 0.985 and fade to 88% opacity on touch.
* **Charts:** Charts are monochrome. Bar charts use 36 dp bars with rounded top corners and faint grid lines. Pie sections interpolate between chart ink and muted gray. Legends use tiny circular swatches, compact labels, and right-aligned amounts.
* **Badges & Pills:** Pills use fully rounded 100+ dp radii. Payment labels, sync statuses, dates, Pro markers, and section toggles should use compact horizontal padding and muted fills. Status chips may add low-alpha color fills and fine borders.
* **Pro Surfaces:** Pro UI keeps the app's neutral typography and rounded geometry but shifts into warm ivory/gold in light mode or deep black/gold in dark mode. Use logo-led hero lockups, premium texture assets only where already established, gold emphasis for purchase affordances, and clear lifetime ownership copy.

## 5. Layout Principles
Use a strict 4 dp spacing rhythm. Screen gutters are usually 16 dp, section gaps are 20-24 dp, internal card padding is 16-20 dp, and compact row gaps are 4-12 dp. Avoid dense nested panels; the hierarchy should come from surface grouping, spacing, typography, and dividers.

The first screen should be the working product, not a marketing page. Home centers on the monthly spend card, then latest expenses, with the add action always immediately available. Analytics can be denser, but it should remain organized into clear, scrollable sections with sticky headers only when they improve navigation.

Motion should be subtle and functional: ease-out cubic fades and small upward slides for routes, 120 ms press feedback, 220 ms content transitions, and 280 ms route transitions. Respect reduced-motion settings by shortening animated durations to near-instant.

Design every money-bearing layout for long values, alternate currency symbols, and text scaling. Use one-line fitting for totals and right-aligned amounts. Let secondary copy truncate before primary labels or amounts. Maintain 44 dp minimum touch targets for icon actions and larger targets for primary CTAs.
