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
5. **Streamlined Navigation:** Unified top app bar combining brand identity, vibe picker, and segmented switcher (`📝 Daily Pulse` / `🎬 Entertainment`). No duplicate bottom navigation bars.

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
- Mini Shamsi month calendar drawer.
- Two distinct task sections:
  - **Today's Focus:** Tasks scheduled for today, featuring three-state actions (`Done`, `Tomorrow`, `Cancel`).
  - **Orbit / Backlog:** Floating general tasks with a 1-tap "Assign to Today" action.

### 4.2 Entertainment Ledger
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
- **On-Hold Mode:** Dimmed visual state, filterable from active queue.
