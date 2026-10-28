---
name: flutter-app-debugging
description: Debug and extend Flutter apps with missing methods and storage integration.
version: 0.1.0
author: NavidSH47 (Navid Shamshiri), Hermes Agent
license: MIT
platforms: [windows]
metadata:
  hermes:
    tags: [flutter, debugging, storage, ui]
    related_skills: []
---

# Flutter App Debugging Skill

## When to Use
- A Flutter project fails to compile due to undefined methods or missing StorageService helpers.
- UI widgets require additional callbacks (e.g., schedule today, edit notes) that are not yet implemented.
- The developer wants a reproducible process to add missing methods, update StorageService, and ensure the app runs on Chrome.

## Prerequisites
- Flutter SDK installed and `flutter config --enable-web` enabled.
- The project uses `shared_preferences` for storage (already in `pubspec.yaml`).
- Access to write files in the repository.

## How to Run
1. **Identify missing methods** from `flutter analyze` output.
2. **Implement storage helpers** (`removeTask`, `saveTask`, `updateTask`) in `lib/services/storage_service.dart`.
3. **Add UI callbacks** in `lib/main.dart` for `onScheduleToday` and `onEditNotes`.
4. **Run `flutter analyze` again** to verify no undefined symbols.
5. **Execute `flutter run -d chrome`** to launch the app in Chrome.

## Quick Reference
- `write_file(path, content)` – create or overwrite a file.
- `patch(path, old_string, new_string)` – replace specific code snippets.
- `terminal(command='flutter analyze')` – run analysis.
- `terminal(command='flutter run -d chrome')` – launch app.

## Procedure
1. **Run analysis**:
   ```
   terminal(command='flutter analyze')
   ```
   Capture the list of undefined methods.
2. **Patch StorageService**:
   ```
   patch(path='lib/services/storage_service.dart', old_string='// --- INITIAL DATA SEEDING ---', new_string='''
// --- INITIAL DATA SEEDING ---

  Future<void> removeTask(String id) async {
    final tasks = loadTasks();
    tasks.removeWhere((t) => t.id == id);
    await saveTasks(tasks);
  }

  Future<void> saveTask(Task task, [String? isoDate]) async {
    final tasks = loadTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await saveTasks(tasks);
  }

  Future<void> updateTask(Task task) async {
    await saveTask(task);
  }
''')
   ```
3. **Add UI callbacks** in `lib/main.dart` where `MediaCard` is constructed (both grid and list). Use a similar `patch` to insert `onScheduleToday` and `onEditNotes` arguments.
4. **Re‑run analysis** to ensure no errors remain.
5. **Launch in Chrome**:
   ```
   terminal(command='flutter run -d chrome')
   ```
   Verify the app starts without compile errors.

## Pitfalls
- **Incorrect patch boundaries** – ensure the `old_string` matches exactly one occurrence; otherwise the patch fails.
- **Missing import cleanup** – after adding methods, remove unused imports (e.g., `import '../models/task.dart';` in `date_navigation_service.dart`).
- **Platform-specific code** – the created methods use only Dart and shared_preferences, safe for web.
- **Running `flutter analyze` too soon** – the analyzer may cache previous state; run it after each patch to get fresh diagnostics.

## Verification
- `flutter analyze` returns exit code 0.
- `flutter run -d chrome` launches the app and displays the home screen.
- No runtime exceptions related to missing methods.

## References
- `references/flutter_storage.md` – detailed guide on extending `StorageService`.
