# Hermes-Personal_Assistant (NSH Assistant)

An offline-first personal assistant and daily companion combining a contextual Solar Hijri (Shamsi) agenda, split-stream task engine ("Daily Pulse"), and an entertainment ledger (Books, TV Shows, Movies, Video Games).

Developed with Flutter (Android, Web, Windows).

---

## Current Architecture & Completed Features

1. **Contextual Day-Planner & Solar Hijri Agenda:**
   - Accurate RTL calendar grid (`شنبه` to `جمعه`) with Friday holiday indicators.
   - Comprehensive Iranian holiday catalogue + custom birthday/anniversary checkpoints.
   - Quick date navigation controls (`« Week`, `‹ Day`, `Today`, `Day ›`, `Week »`).
   - Dual calendar support: Solar Hijri (Jalali) display paired with Gregorian conversion.

2. **Daily Pulse Task Management:**
   - Split-stream layout: **Today's Focus** vs. **General Orbit / Backlog**.
   - Three-state workflow (`Done`, `Postpone`, `Cancel`) with multi-line notes.
   - Task demotion/promotion between Today and Backlog.
   - Postponing flow: tap moves to the following day and out of today's list; long-press opens calendar picker.

3. **Entertainment Tracker & Habits:**
   - 4 media categories: Books (pages), TV Shows (episodes), Movies (minutes), Games (chapters/missions).
   - Dynamic label based on media type for total units.
   - Half-point rating system (1.0 to 10.0) with dynamic gradient accents.
   - Dual display modes: List view and poster-first Grid view.
   - Universal custom tag/label filtering (`Horror`, `Sci-Fi`, `Masterpiece`, etc.).
   - In-place editable personal notes and reviews per item.
   - **Media-as-Task Habit Linking:** Schedule media units as daily goals; completing the task advances media progress automatically.
   - Local cover art caching.

4. **Design System & Typography:**
   - 11 curated color vibe palettes (Deep Amethyst, Imperial Purple & Gold, Ultraviolet Twilight, Arctic Frost, etc.).
   - Instant runtime typography switcher with Persian fallback support (`Vazirmatn`).
   - Consolidated settings drawer accessible from the unified top app bar.

---

## Repository & Documentation
- Detailed architectural specs and data models: see [`SDD.md`](./SDD.md).
- Interactive prototype preview: `prototype.html`.
Automated test suite: flutter test.

### Running the app in Chrome (desktop)

1. Ensure web support is enabled:
   ```
   flutter config --enable-web
   ```
2. Get dependencies:
   ```
   flutter pub get
   ```
3. Launch the app in Chrome:
   ```
   flutter run -d chrome
   ```
   (Chrome must be installed and in your PATH.)
