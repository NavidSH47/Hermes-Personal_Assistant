# Software Design Document (SDD)
## Project: NSH Assistant (Lightweight Android Personal Assistant)
**Version:** 1.0.0  
**Target Platform:** Android (API 26+)  
**Repository:** Local git repository initialized (`main`)

---

## 1. System Overview & Core Principles
NSH Assistant is a zero-latency, local-first daily companion combining:
1. **Contextual Day-Planner & Shamsi Agenda:** Solar Hijri calendar integration, official holidays, custom birthdays/events with action checkpoints.
2. **Split-Stream Task Engine ("Daily Pulse"):** Today's Focus vs. Backlog/Orbit, multi-line notes, 3-state execution (`Done`, `Postponed -> Tomorrow`, `Canceled`), and drag-reordering.
3. **Unified Entertainment Tracker:** Books, TV Shows, Movies, and Video Games with metric progress tracking, half-point gradient ratings (1.0 - 10.0), cover art editing, and on-hold states.
4. **Adaptive Aesthetics & Themes:** Built-in dynamic color vibe themes + custom accent capability:
   - **Purples:** Deep Amethyst (`#9333ea`), Deep Lavender High-Contrast (`#e9d5ff` on obsidian violet), Imperial Purple & Gold (`#9333ea` + `#fbbf24`), Ultraviolet Twilight (`#9333ea` + `#f97316`), Cyber Violet (`#8b5cf6`).
   - **Oranges:** Solar Tangerine (`#ea580c`), Sunset Amber (`#f97316`).
   - **Snowy / Frost:** Arctic Frost (`#38bdf8` / icy frost white `#f0f9ff`).
   - **Others:** Isfahan Cyan / Persian Turquoise (`#00e5ff`), Emerald Cyan (`#10b981`), Nordic Slate (`#60a5fa`).
5. **Dynamic Typography & Font Manager:** Built-in font family selector allowing instant runtime font switching:
   - **Default Sans:** Modern clean system font (`Vazirmatn` + system UI).
   - **Comic Sans:** Playful Latin typography (`Comic Sans MS` / `Comic Neue`) with Persian text rendered cleanly in the default sans font (`Vazirmatn`).
   - **Rounded Bold:** Smooth, friendly soft-cornered font (`Arial Rounded MT Bold` / `Quicksand`).
   - **Tech Mono:** Code/terminal fixed-width styling (`Cascadia Code` / `Fira Code` / `Consolas`).
   - **Editorial Serif:** Classic literary typography (`Georgia` / `Cambria`).
   - **Vazirmatn:** Native Persian/Solar Hijri typography optimized for bilingual rendering.
6. **Consolidated Settings Side Menu:** Slide-over drawer accessed via a gear button (`⚙️`) in the top bar containing both the Color Vibe themes and Typography settings.
7. **Streamlined Navigation & Dual-View Entertainment:** Unified top app bar combining brand identity, settings button, and segmented stream switcher. Entertainment ledger supports both **List View** (horizontal details) and **Grid View** (2-column poster-first cards). No duplicate bottom navigation bars.

---

## 2. Framework Comparison & Selection

| Framework | Pros | Cons | Verdict |
| :--- | :--- | :--- | :--- |
| **React Native (Expo)** | Instant live testing on physical Android via Expo Go (scan QR code, zero Android Studio setup required), modern TS/React, instant web preview. | Relies on JS bridge (now minimal with New Architecture). | **Top Pick for rapid development & ease of running** |
| **Kotlin + Jetpack Compose** | Pure 100% native Android, modern declarative UI. | Heavy Gradle build times, complex dev environment setup. | Best if 100% native Kotlin is strictly required |
| **Flutter (Dart)** | High-performance 120fps Skia/Impeller canvas, mature Shamsi packages (`shamsi_date`). | Learning Dart required. | Solid cross-platform pick |
| **NestJS** | Enterprise server-side framework (Node.js/TS). | Not for mobile apps; server backend only. NSH Assistant is local-first. | N/A (Client does not require a remote server) |

---

## 3. Data Models

### 3.1 Task Entity (`tasks`)
- `id`: UUID (Primary Key)
- `title`: String
- `notes`: String? (Multi-line text / Markdown)
- `category`: Enum (`daily`, `general`)
- `target_date`: String? (Jalali `YYYY-MM-DD`, null if general backlog)
- `status`: Enum (`pending`, `done`, `postponed`, `canceled`)
- `order_index`: Integer (for reordering within view)
- `postponed_count`: Integer (default 0)
- `linked_media_id`: String? (ID of linked MediaItem for daily habit tracking)
- `media_units_to_advance`: Double? (Units to increment upon checking Done)
- `created_at`: Timestamp
- `updated_at`: Timestamp

### 3.2 Shamsi Event & Holiday Entity (`shamsi_events`)
- `id`: UUID
- `title`: String
- `jalali_month`: Integer (1-12)
- `jalali_day`: Integer (1-31)
- `is_official_holiday`: Boolean
- `is_enabled`: Boolean (User can toggle off unneeded holidays)
- `is_custom`: Boolean (User-added birthdays/anniversaries)
- `action_checked`: Boolean (Checkpoint state for current year)
- `category`: Enum (`holiday`, `birthday`, `custom_date`)

### 3.3 Media Item Entity (`media_items`)
- `id`: UUID
- `type`: Enum (`book`, `tv_show`, `movie`, `video_game`)
- `title`: String
- `release_year`: Integer
- `cover_url`: String?
- `local_cover_path`: String?
- `personal_notes`: String? (User review, quotes, and thoughts)
- `labels`: List<String> (Universal custom tags: e.g. "Horror", "Sci-Fi", "Ongoing", "Masterpiece")
- `progress_current`: Double (pages, episodes, minutes, chapters)
- `progress_total`: Double
- `score`: Double? (Range: 1.0 - 10.0, step: 0.5)
- `is_on_hold`: Boolean (default: false)
- `custom_order`: Integer
- `created_at`: Timestamp

---

## 4. UI Architecture & Features

### 4.1 Daily Pulse & Shamsi Agenda
- Pinned Agenda Header displaying Solar Hijri date (e.g. `جمعه ۲۳ آبان ۱۴۰۳`).
- Event and holiday chips with action checkpoints `[ ]` / `[✓]` (e.g. Mary's Birthday -> call or send gift).
- **Accurate RTL Calendar Grid:** The Shamsi calendar drawer and month views flow strictly **Right-to-Left (RTL)** from Saturday (`شنبه`, far right) to Friday (`جمعه`, far left with red holiday highlight). Month 1st day aligns dynamically to its true weekday. Includes month switcher (`‹ Next` / `Prev ›`) and clear "Today" marker.
- **Quick Date Navigation Bar:** Pinned navigation buttons: `[ « Week ]`, `[ ‹ Day ]`, `[ Today ]`, `[ Day › ]`, `[ Week » ]` for quick hopping between dates.
- **Preloaded Holiday Library:** Comprehensive pre-seeded database of Iranian public holidays (Nowruz, Islamic holidays, national days) + notable cultural/global days.
- **Clean English UI:** Modal headers, buttons, and placeholders are kept in clean English, with Persian preserved for native calendar strings and titles.
- **Two Distinct Task Sections:**
  - **Today's Focus:** Tasks scheduled for today, featuring three-state actions (`Done`, `Tomorrow`, `Cancel`).
  - **Orbit / Backlog:** Floating general tasks with a 1-tap "Assign to Today" action (no auto-transfer on scroll).

### 4.2 Entertainment Ledger & Media Daily Goals
- **Presentation Modes:** Toggle between **List View** (horizontal details, action controls) and **Grid View** (2-column poster-first layout with cover prominence).
- **Media as To-Do Task ("Schedule for Today"):** Any media item can be scheduled as a daily goal (e.g. "Watch 3 episodes of Succession" or "Read 25 pages of Klara and the Sun"). It creates a linked task in Today's Focus; checking it **Done** automatically syncs and advances the media item's progress counter.
- **Personal Notes / Descriptions:** In-place editable notes on every media item for reviews, favorite quotes, and viewing logs.
- **Universal Custom Labels:** Multi-select custom tags applied across all 4 categories (e.g. `Horror`, `Sci-Fi`, `Ongoing`, `Masterpiece`, `RPG`) with an instant filter bar.
- **Progress Units:**
  - Books: `Pages`
  - TV Shows: `Episodes`
  - Movies: `Minutes`
  - Games: `Chapters / Missions`
- **Dynamic Score Gradient Scale:**
  - `1.0 - 3.5`: Crimson to Amber (`#E53935` -> `#FF7043`)
  - `4.0 - 6.5`: Amber to Chartreuse (`#FFA000` -> `#C0CA33`)
  - `7.0 - 8.5`: Teal to Emerald (`#26A69A` -> `#43A047`)
  - `9.0 - 10.0`: Deep Emerald to Royal Violet (`#2E7D32` -> `#7E57C2`)
- **Cover Management:** Local image file picker, direct image URL, or removal fallback with title initials.
### 4.3 Improvement Phase & In-Flight Enhancements
The project is currently in the **active refinement and UX polishing phase**, targeting the following items:
1. **Interactive Date Navigation & Day Tasks History:**
   - Quick navigation bar (`« Week`, `‹ Day`, `Today`, `Day ›`, `Week »`) bound to persistent daily task registries.
   - Preserves completed and unfinished states as the user shifts across historical or future dates.
2. **Advanced Task Rescheduling & Postponing:**
   - Single-tap `Postpone`: Automatically transfers task to the following day and hides it from today's list.
   - Long-press `Postpone`: Triggers side/modal calendar grid to pick any arbitrary target future date.
3. **Task Stream Flow Rules:**
   - Prevention of accidental auto-scrolling/focus transitions into Today's list.
   - Bidirectional movement: Ability to demote Today tasks back to General Backlog/Orbit.
4. **Desktop & Mobile Reordering Compatibility:**
   - Pointer and drag-and-drop listener fixes for Flutter web (Chrome) and touch gesture listeners on mobile.
5. **Media Ledger Cleanups:**
   - Removal of overlapping on-hold text labels over release year badges (relies cleanly on accent border and checkbox state).
   - Local cover art disk/cache persistence (prevents redundant network re-fetching across app restarts).
   - Dynamic unit label binding in the Add/Edit dialog based on selected media type (Pages, Episodes, Minutes, Chapters).
6. **Dual Calendar Integration & Event Checkpoints:**
   - Bilingual date display: Solar Hijri (Shamsi) paired with its Gregorian date equivalent.
   - Visual strikethrough styling for completed checkpoints in calendar event reminders.

---

## 5. Verification & Test Suite
- **Unit & Logic Tests (`test/unit_test.dart`):** Validates task state transitions (Done, Postponed, Canceled), media model serialization/deserialization, label filtering, and media-to-task progress sync.
- **Build Targets:** Android APK/Bundle, Web (CanvasKit/HTML renderer), and Windows Desktop.
