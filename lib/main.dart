import 'package:flutter/material.dart';
import 'models/task.dart';
import 'models/shamsi_event.dart';
import 'models/media_item.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'widgets/shamsi_agenda_banner.dart';
import 'widgets/task_card.dart';
import 'widgets/media_card.dart';
import 'widgets/settings_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.init();
  runApp(NSHAssistantApp(storage: storage));
}

class NSHAssistantApp extends StatefulWidget {
  final StorageService storage;

  const NSHAssistantApp({super.key, required this.storage});

  @override
  State<NSHAssistantApp> createState() => _NSHAssistantAppState();
}

class _NSHAssistantAppState extends State<NSHAssistantApp> {
  late ThemeVibe _currentVibe;
  late AppFontStyle _currentFont;

  @override
  void initState() {
    super.initState();
    _currentVibe = widget.storage.loadThemeVibe();
    _currentFont = widget.storage.loadFontStyle();
  }

  void _updateThemeVibe(ThemeVibe vibe) {
    setState(() => _currentVibe = vibe);
    widget.storage.saveThemeVibe(vibe);
  }

  void _updateFontStyle(AppFontStyle font) {
    setState(() => _currentFont = font);
    widget.storage.saveFontStyle(font);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NSH Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.createTheme(_currentVibe, _currentFont),
      home: HomeScreen(
        storage: widget.storage,
        currentVibe: _currentVibe,
        currentFont: _currentFont,
        onSelectVibe: _updateThemeVibe,
        onSelectFont: _updateFontStyle,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final StorageService storage;
  final ThemeVibe currentVibe;
  final AppFontStyle currentFont;
  final Function(ThemeVibe) onSelectVibe;
  final Function(AppFontStyle) onSelectFont;

  const HomeScreen({
    super.key,
    required this.storage,
    required this.currentVibe,
    required this.currentFont,
    required this.onSelectVibe,
    required this.onSelectFont,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _currentTab = 'notes';
  String _mediaFilter = 'all';
  String _mediaSort = 'custom';
  bool _isMediaGrid = false;

  late List<Task> _tasks;
  late List<ShamsiEvent> _events;
  late List<MediaItem> _mediaItems;

  @override
  void initState() {
    super.initState();
    _tasks = widget.storage.loadTasks();
    _events = widget.storage.loadShamsiEvents();
    _mediaItems = widget.storage.loadMediaItems();
    _isMediaGrid = widget.storage.loadMediaViewMode() == 'grid';
  }

  VibePalette get _palette =>
      AppTheme.vibes[widget.currentVibe] ??
      AppTheme.vibes[ThemeVibe.deepAmethyst]!;

  void _setTaskStatus(Task task, TaskStatus status) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        int newPostponedCount = task.postponedCount;
        if (status == TaskStatus.postponed &&
            task.status != TaskStatus.postponed) {
          newPostponedCount++;
        }
        _tasks[index] = task.copyWith(
          status: status,
          postponedCount: newPostponedCount,
        );
      }
    });
    widget.storage.saveTasks(_tasks);
  }

  void _assignTaskToToday(Task task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(category: TaskCategory.daily);
      }
    });
    widget.storage.saveTasks(_tasks);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task moved to Today\'s Focus!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
    widget.storage.saveTasks(_tasks);
  }

  void _openAddTaskModal(TaskCategory category) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _palette.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                category == TaskCategory.daily
                    ? 'Add Task for Today'
                    : 'Add to General Backlog',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _palette.textMain,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                autofocus: true,
                style: TextStyle(color: _palette.textMain),
                decoration: InputDecoration(
                  hintText: 'What needs to get done?',
                  hintStyle: TextStyle(color: _palette.textDim),
                  filled: true,
                  fillColor: _palette.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _palette.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                maxLines: 3,
                style: TextStyle(color: _palette.textMain),
                decoration: InputDecoration(
                  hintText:
                      'Add extra details, checklist bullets, or notes (optional)...',
                  hintStyle: TextStyle(color: _palette.textDim),
                  filled: true,
                  fillColor: _palette.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _palette.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: _palette.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _palette.accentPrimary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (title.isNotEmpty) {
                        final newTask = Task(
                          id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          notes: notesController.text.trim(),
                          category: category,
                        );
                        setState(() {
                          _tasks.insert(0, newTask);
                        });
                        widget.storage.saveTasks(_tasks);
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Save Task',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleShamsiCheckpoint(ShamsiEvent event) {
    setState(() {
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] =
            event.copyWith(actionChecked: !event.actionChecked);
      }
    });
    widget.storage.saveShamsiEvents(_events);
  }

  void _addShamsiEvent(ShamsiEvent newEvent) {
    setState(() {
      _events.add(newEvent);
    });
    widget.storage.saveShamsiEvents(_events);
  }

  void _toggleMediaOnHold(MediaItem item, bool isOnHold) {
    setState(() {
      final index = _mediaItems.indexWhere((m) => m.id == item.id);
      if (index != -1) {
        _mediaItems[index] = item.copyWith(isOnHold: isOnHold);
      }
    });
    widget.storage.saveMediaItems(_mediaItems);
  }

  void _showUpdateProgressDialog(MediaItem item) {
    final currentController =
        TextEditingController(text: item.progressCurrent.toInt().toString());
    final totalController =
        TextEditingController(text: item.progressTotal.toInt().toString());
    double selectedScore = item.score ?? 8.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dCtx, setDState) {
            return AlertDialog(
              backgroundColor: _palette.bgElevated,
              title: Text(
                'Update: ${item.title}',
                style: TextStyle(
                  color: _palette.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Metric: ${item.metricUnit}',
                    style: TextStyle(
                      color: _palette.accentPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: currentController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: _palette.textMain),
                          decoration: InputDecoration(
                            labelText: 'Current',
                            labelStyle: TextStyle(color: _palette.textMuted),
                            filled: true,
                            fillColor: _palette.bgSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: totalController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: _palette.textMain),
                          decoration: InputDecoration(
                            labelText: 'Total',
                            labelStyle: TextStyle(color: _palette.textMuted),
                            filled: true,
                            fillColor: _palette.bgSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score (1-10):',
                        style: TextStyle(
                          color: _palette.textMain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '⭐ ${selectedScore.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: _palette.accentPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: selectedScore,
                    min: 1.0,
                    max: 10.0,
                    divisions: 18,
                    activeColor: _palette.accentPrimary,
                    onChanged: (val) {
                      setDState(() => selectedScore = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: _palette.textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _palette.accentPrimary,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final cur =
                        double.tryParse(currentController.text) ?? item.progressCurrent;
                    final tot =
                        double.tryParse(totalController.text) ?? item.progressTotal;
                    setState(() {
                      final index = _mediaItems.indexWhere((m) => m.id == item.id);
                      if (index != -1) {
                        _mediaItems[index] = item.copyWith(
                          progressCurrent: cur,
                          progressTotal: tot,
                          score: selectedScore,
                        );
                      }
                    });
                    widget.storage.saveMediaItems(_mediaItems);
                    Navigator.pop(dCtx);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCoverDialog(MediaItem item) {
    final urlController = TextEditingController(text: item.coverUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _palette.bgElevated,
          title: Text(
            'Cover Art: ${item.title}',
            style: TextStyle(
              color: _palette.textMain,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: urlController,
                style: TextStyle(color: _palette.textMain),
                decoration: InputDecoration(
                  labelText: 'Image Web URL',
                  hintText: 'https://...',
                  labelStyle: TextStyle(color: _palette.textMuted),
                  filled: true,
                  fillColor: _palette.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Remove Cover (Use Placeholder)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _palette.bgSurface,
                  foregroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    final index = _mediaItems.indexWhere((m) => m.id == item.id);
                    if (index != -1) {
                      _mediaItems[index] = item.copyWith(coverUrl: '');
                    }
                  });
                  widget.storage.saveMediaItems(_mediaItems);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: _palette.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _palette.accentPrimary,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final url = urlController.text.trim();
                setState(() {
                  final index = _mediaItems.indexWhere((m) => m.id == item.id);
                  if (index != -1) {
                    _mediaItems[index] = item.copyWith(coverUrl: url);
                  }
                });
                widget.storage.saveMediaItems(_mediaItems);
                Navigator.pop(ctx);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMediaDialog() {
    final titleController = TextEditingController();
    final yearController =
        TextEditingController(text: DateTime.now().year.toString());
    final totalController = TextEditingController(text: '100');
    MediaType selectedType = MediaType.book;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dCtx, setDState) {
            return AlertDialog(
              backgroundColor: _palette.bgElevated,
              title: Text(
                'Add Media Item',
                style: TextStyle(
                  color: _palette.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<MediaType>(
                      initialValue: selectedType,
                      dropdownColor: _palette.bgElevated,
                      style: TextStyle(color: _palette.textMain),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: _palette.textMuted),
                        filled: true,
                        fillColor: _palette.bgSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: MediaType.book,
                          child: Text('📖 Book'),
                        ),
                        DropdownMenuItem(
                          value: MediaType.tvShow,
                          child: Text('📺 TV Show'),
                        ),
                        DropdownMenuItem(
                          value: MediaType.movie,
                          child: Text('🎬 Movie'),
                        ),
                        DropdownMenuItem(
                          value: MediaType.videoGame,
                          child: Text('🎮 Video Game'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDState(() => selectedType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: _palette.textMain),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: _palette.textMuted),
                        filled: true,
                        fillColor: _palette.bgSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: yearController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: _palette.textMain),
                            decoration: InputDecoration(
                              labelText: 'Release Year',
                              labelStyle: TextStyle(color: _palette.textMuted),
                              filled: true,
                              fillColor: _palette.bgSurface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: totalController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: _palette.textMain),
                            decoration: InputDecoration(
                              labelText: 'Total Units',
                              labelStyle: TextStyle(color: _palette.textMuted),
                              filled: true,
                              fillColor: _palette.bgSurface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: _palette.textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _palette.accentPrimary,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      final year = int.tryParse(yearController.text) ?? 2024;
                      final total = double.tryParse(totalController.text) ?? 100;
                      final newItem = MediaItem(
                        id: 'media_${DateTime.now().millisecondsSinceEpoch}',
                        type: selectedType,
                        title: title,
                        releaseYear: year,
                        progressCurrent: 0,
                        progressTotal: total,
                      );
                      setState(() {
                        _mediaItems.insert(0, newItem);
                      });
                      widget.storage.saveMediaItems(_mediaItems);
                      Navigator.pop(dCtx);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Task> get _dailyTasks =>
      _tasks.where((t) => t.category == TaskCategory.daily).toList();

  List<Task> get _backlogTasks =>
      _tasks.where((t) => t.category == TaskCategory.general).toList();

  List<MediaItem> get _filteredMediaItems {
    var list = _mediaItems.where((m) {
      if (_mediaFilter == 'all') return true;
      if (_mediaFilter == 'book' && m.type == MediaType.book) return true;
      if (_mediaFilter == 'tvShow' && m.type == MediaType.tvShow) return true;
      if (_mediaFilter == 'movie' && m.type == MediaType.movie) return true;
      if (_mediaFilter == 'videoGame' && m.type == MediaType.videoGame) {
        return true;
      }
      return false;
    }).toList();

    switch (_mediaSort) {
      case 'score':
        list.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
        break;
      case 'progress':
        list.sort((a, b) => b.progressRatio.compareTo(a.progressRatio));
        break;
      case 'year':
        list.sort((a, b) => b.releaseYear.compareTo(a.releaseYear));
        break;
      case 'name':
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'custom':
      default:
        list.sort((a, b) => a.customOrder.compareTo(b.customOrder));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _palette.bgCanvas,
      endDrawer: SettingsDrawer(
        currentVibe: widget.currentVibe,
        currentFont: widget.currentFont,
        palette: _palette,
        onSelectVibe: widget.onSelectVibe,
        onSelectFont: widget.onSelectFont,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: BoxDecoration(
                color: _palette.bgSurface,
                border: Border(bottom: BorderSide(color: _palette.borderSubtle)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            _palette.accentGradient.createShader(bounds),
                        child: const Text(
                          '⚡ NSH Assistant',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _palette.bgElevated,
                            border: Border.all(color: _palette.borderSubtle),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.settings,
                                size: 14,
                                color: _palette.textMuted,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Appearance',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _palette.textMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: _palette.bgElevated,
                      border: Border.all(color: _palette.borderSubtle),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentButton(
                            label: '📝 Daily Pulse',
                            isActive: _currentTab == 'notes',
                            onTap: () => setState(() => _currentTab = 'notes'),
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentButton(
                            label: '🎬 Entertainment',
                            isActive: _currentTab == 'entertainment',
                            onTap: () =>
                                setState(() => _currentTab = 'entertainment'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _currentTab == 'notes'
                  ? _buildDailyPulseView()
                  : _buildEntertainmentView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _palette.bgSurface : Colors.transparent,
          border: isActive
              ? Border.all(color: _palette.borderSubtle)
              : null,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? _palette.textMain : _palette.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyPulseView() {
    final daily = _dailyTasks;
    final backlog = _backlogTasks;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ShamsiAgendaBanner(
          events: _events,
          palette: _palette,
          onToggleCheckpoint: _toggleShamsiCheckpoint,
          onAddEvent: _addShamsiEvent,
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '📌 Today\'s Focus',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _palette.textMain,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _palette.bgElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${daily.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _palette.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => _openAddTaskModal(TaskCategory.daily),
              child: Text(
                '+ Add for Today',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _palette.accentPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (daily.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No tasks scheduled for today. Add one above!',
              style: TextStyle(
                fontSize: 12,
                color: _palette.textDim,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...daily.map((task) {
            return TaskCard(
              key: ValueKey(task.id),
              task: task,
              palette: _palette,
              onStatusChange: (status) => _setTaskStatus(task, status),
              onDelete: () => _deleteTask(task),
            );
          }),
        const SizedBox(height: 14),
        Divider(color: _palette.borderSubtle),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '🪐 Orbit & Backlog',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _palette.textMain,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _palette.bgElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${backlog.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _palette.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => _openAddTaskModal(TaskCategory.general),
              child: Text(
                '+ Add Backlog',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _palette.accentPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (backlog.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Backlog is clear! Relax and enjoy.',
              style: TextStyle(
                fontSize: 12,
                color: _palette.textDim,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...backlog.map((task) {
            return TaskCard(
              key: ValueKey(task.id),
              task: task,
              palette: _palette,
              onStatusChange: (status) => _setTaskStatus(task, status),
              onAssignToToday: () => _assignTaskToToday(task),
              onDelete: () => _deleteTask(task),
            );
          }),
      ],
    );
  }

  Widget _buildEntertainmentView() {
    final mediaList = _filteredMediaItems;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryPill('all', '✨ All'),
              const SizedBox(width: 6),
              _buildCategoryPill('book', '📚 Books'),
              const SizedBox(width: 6),
              _buildCategoryPill('tvShow', '📺 TV Shows'),
              const SizedBox(width: 6),
              _buildCategoryPill('movie', '🎬 Movies'),
              const SizedBox(width: 6),
              _buildCategoryPill('videoGame', '🎮 Video Games'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tracking ${mediaList.length} Items',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _palette.textMuted,
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: _palette.bgElevated,
                    border: Border.all(color: _palette.borderSubtle),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() => _isMediaGrid = false);
                          widget.storage.saveMediaViewMode('list');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: !_isMediaGrid
                                ? _palette.bgSurface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.view_agenda_outlined,
                            size: 14,
                            color: !_isMediaGrid
                                ? _palette.textMain
                                : _palette.textDim,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() => _isMediaGrid = true);
                          widget.storage.saveMediaViewMode('grid');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _isMediaGrid
                                ? _palette.bgSurface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.grid_view,
                            size: 14,
                            color: _isMediaGrid
                                ? _palette.textMain
                                : _palette.textDim,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _mediaSort,
                    dropdownColor: _palette.bgElevated,
                    style: TextStyle(
                      fontSize: 11,
                      color: _palette.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'custom',
                        child: Text('Custom Order'),
                      ),
                      DropdownMenuItem(
                        value: 'score',
                        child: Text('Highest Score'),
                      ),
                      DropdownMenuItem(
                        value: 'progress',
                        child: Text('Most Progress'),
                      ),
                      DropdownMenuItem(
                        value: 'year',
                        child: Text('Release Year'),
                      ),
                      DropdownMenuItem(
                        value: 'name',
                        child: Text('Name (A-Z)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _mediaSort = val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: _showAddMediaDialog,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _palette.accentPrimary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '+ Add',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (mediaList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No media entries found in this category.',
                style: TextStyle(
                  fontSize: 12,
                  color: _palette.textDim,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else if (_isMediaGrid)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: mediaList.length,
            itemBuilder: (context, index) {
              final item = mediaList[index];
              return MediaCard(
                key: ValueKey(item.id),
                item: item,
                palette: _palette,
                isGrid: true,
                onToggleOnHold: (val) => _toggleMediaOnHold(item, val),
                onUpdateProgress: () => _showUpdateProgressDialog(item),
                onEditCover: () => _showEditCoverDialog(item),
              );
            },
          )
        else
          ...mediaList.map((item) {
            return MediaCard(
              key: ValueKey(item.id),
              item: item,
              palette: _palette,
              isGrid: false,
              onToggleOnHold: (val) => _toggleMediaOnHold(item, val),
              onUpdateProgress: () => _showUpdateProgressDialog(item),
              onEditCover: () => _showEditCoverDialog(item),
            );
          }),
      ],
    );
  }

  Widget _buildCategoryPill(String filterKey, String label) {
    final isActive = _mediaFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _mediaFilter = filterKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _palette.textMain : _palette.bgElevated,
          border: Border.all(
            color: isActive ? _palette.textMain : _palette.borderSubtle,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? _palette.bgCanvas : _palette.textMuted,
          ),
        ),
      ),
    );
  }
}

