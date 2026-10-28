import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/shamsi_event.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';

class StorageService {
  static const String _keyTasks = 'nsh_tasks_v1';
  static const String _keyEvents = 'nsh_shamsi_events_v1';
  static const String _keyMedia = 'nsh_media_items_v1';
  static const String _keyVibe = 'nsh_theme_vibe_v1';
  static const String _keyFont = 'nsh_app_font_v1';
  static const String _keyMediaView = 'nsh_media_view_mode_v1';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- THEME & FONT ---
  ThemeVibe loadThemeVibe() {
    final name = _prefs.getString(_keyVibe);
    if (name == null) return ThemeVibe.deepAmethyst;
    return ThemeVibe.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ThemeVibe.deepAmethyst,
    );
  }

  Future<void> saveThemeVibe(ThemeVibe vibe) async {
    await _prefs.setString(_keyVibe, vibe.name);
  }

  AppFontStyle loadFontStyle() {
    final name = _prefs.getString(_keyFont);
    if (name == null) return AppFontStyle.defaultSans;
    return AppFontStyle.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppFontStyle.defaultSans,
    );
  }

  Future<void> saveFontStyle(AppFontStyle font) async {
    await _prefs.setString(_keyFont, font.name);
  }

  String loadMediaViewMode() {
    return _prefs.getString(_keyMediaView) ?? 'list';
  }

  Future<void> saveMediaViewMode(String mode) async {
    await _prefs.setString(_keyMediaView, mode);
  }

  // --- TASKS ---
  List<Task> loadTasks() {
    final raw = _prefs.getString(_keyTasks);
    if (raw == null) {
      return _initialSampleTasks();
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _initialSampleTasks();
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final raw = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyTasks, raw);
  }

  // --- SHAMSI EVENTS ---
  List<ShamsiEvent> loadShamsiEvents() {
    final raw = _prefs.getString(_keyEvents);
    if (raw == null) {
      return ShamsiEvent.defaultEvents;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ShamsiEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return ShamsiEvent.defaultEvents;
    }
  }

  Future<void> saveShamsiEvents(List<ShamsiEvent> events) async {
    final raw = jsonEncode(events.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyEvents, raw);
  }

  // --- MEDIA ITEMS ---
  List<MediaItem> loadMediaItems() {
    final raw = _prefs.getString(_keyMedia);
    if (raw == null) {
      return _initialSampleMedia();
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _initialSampleMedia();
    }
  }

  Future<void> saveMediaItems(List<MediaItem> items) async {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyMedia, raw);
  }

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
    // Same as saveTask for simplicity
    await saveTask(task);
  }

  List<Task> _initialSampleTasks() {
    return [
      Task(
        id: 't_media_1',
        title: 'Watch 3 episodes of Succession (Season 3 finale)',
        notes: 'Will advance series progress from 32 to 35 episodes automatically upon completion!',
        category: TaskCategory.daily,
        status: TaskStatus.pending,
        orderIndex: 0,
        linkedMediaId: 'm_2',
        mediaUnitsToAdvance: 3,
        mediaTitle: 'Succession',
      ),
      Task(
        id: 't_1',
        title: 'Submit History Homework & Essay Draft',
        notes: 'Must cover the Safavid architecture section. Verify citations and upload PDF to LMS.',
        category: TaskCategory.daily,
        status: TaskStatus.pending,
        orderIndex: 1,
      ),
      Task(
        id: 't_2',
        title: 'Groceries & Lunch Preparation',
        notes: '• Olive oil, basmati rice, mint, fresh lemons\n• Start cooking by 11:30 AM',
        category: TaskCategory.daily,
        status: TaskStatus.pending,
        orderIndex: 2,
      ),
      Task(
        id: 't_3',
        title: 'Research Computer Vision project topic',
        notes: 'Compare YOLOv11 vs RT-DETR for real-time edge devices. Prepare 3 bullet ideas.',
        category: TaskCategory.general,
        status: TaskStatus.pending,
        orderIndex: 0,
      ),
      Task(
        id: 't_4',
        title: 'Car periodic oil change & inspection',
        notes: 'Check filter and tire pressure at local workshop this weekend.',
        category: TaskCategory.general,
        status: TaskStatus.pending,
        orderIndex: 1,
      ),
    ];
  }

  List<MediaItem> _initialSampleMedia() {
    return [
      MediaItem(
        id: 'm_1',
        type: MediaType.book,
        title: 'Klara and the Sun',
        releaseYear: 2021,
        personalNotes:
            'Poignant exploration of love, loneliness and AI consciousness from Klara\'s perspective.',
        labels: ['Sci-Fi', 'Masterpiece'],
        progressCurrent: 172,
        progressTotal: 303,
        score: 8.5,
        isOnHold: false,
        customOrder: 0,
      ),
      MediaItem(
        id: 'm_2',
        type: MediaType.tvShow,
        title: 'Succession',
        releaseYear: 2023,
        personalNotes:
            'Incredible writing and tension. Watching Season 3 finale this week.',
        labels: ['Drama', 'Ongoing', 'Masterpiece'],
        progressCurrent: 32,
        progressTotal: 39,
        score: 9.5,
        isOnHold: false,
        customOrder: 1,
      ),
      MediaItem(
        id: 'm_3',
        type: MediaType.movie,
        title: 'Dune: Part Two',
        releaseYear: 2024,
        personalNotes: 'Sound design and cinematography are top-tier in IMAX.',
        labels: ['Sci-Fi'],
        progressCurrent: 75,
        progressTotal: 166,
        score: 7.0,
        isOnHold: false,
        customOrder: 2,
      ),
      MediaItem(
        id: 'm_4',
        type: MediaType.videoGame,
        title: 'Elden Ring',
        releaseYear: 2022,
        personalNotes: 'Stuck at Radahn fight. Taking a break for a while.',
        labels: ['RPG', 'Ongoing'],
        progressCurrent: 8,
        progressTotal: 32,
        score: 4.5,
        isOnHold: true,
        customOrder: 3,
      ),
    ];
  }
}
