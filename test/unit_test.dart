import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:nsh_assistant/models/task.dart';
import 'package:nsh_assistant/models/media_item.dart';
import 'package:nsh_assistant/models/shamsi_event.dart';
import 'package:nsh_assistant/services/date_navigation_service.dart';
import 'package:nsh_assistant/services/task_reschedule_service.dart';
import 'package:nsh_assistant/services/task_stream_flow_service.dart';
import 'package:nsh_assistant/services/reorder_service.dart';
import 'package:nsh_assistant/services/media_ledger_cleanup_service.dart';
import 'package:nsh_assistant/services/dual_calendar_service.dart';
import 'package:nsh_assistant/services/web_typography_service.dart';
import 'package:nsh_assistant/services/media_label_service.dart';
import 'package:nsh_assistant/services/media_goal_sync_service.dart';
import 'package:nsh_assistant/theme/app_theme.dart';

void main() {
  group('Task Model & 3-State Transitions', () {
    test('Default task starts with pending status', () {
      final task = Task(id: '1', title: 'Buy groceries');
      expect(task.status, TaskStatus.pending);
      expect(task.category, TaskCategory.daily);
      expect(task.postponedCount, 0);
    });

    test('Postpone increment logic updates state', () {
      final task = Task(id: '1', title: 'Buy groceries');
      final postponed = task.copyWith(
        status: TaskStatus.postponed,
        postponedCount: task.postponedCount + 1,
      );
      expect(postponed.status, TaskStatus.postponed);
      expect(postponed.postponedCount, 1);
    });

    test('JSON serialization & deserialization is lossless', () {
      final task = Task(
        id: '42',
        title: 'Complete Math Essay',
        notes: '• Step 1\n• Step 2',
        category: TaskCategory.general,
        status: TaskStatus.done,
        orderIndex: 3,
        postponedCount: 2,
      );
      final json = task.toJson();
      final revived = Task.fromJson(json);

      expect(revived.id, task.id);
      expect(revived.title, task.title);
      expect(revived.notes, task.notes);
      expect(revived.category, task.category);
      expect(revived.status, task.status);
      expect(revived.orderIndex, task.orderIndex);
      expect(revived.postponedCount, task.postponedCount);
    });
  });

  group('MediaItem Metric & Progress Calculations', () {
    test('Progress ratio clamp and percentage calculation', () {
      final book = MediaItem(
        id: 'b1',
        type: MediaType.book,
        title: 'Klara and the Sun',
        releaseYear: 2021,
        progressCurrent: 172,
        progressTotal: 303,
      );
      expect(book.progressPercent, 57);
      expect(book.metricUnit, 'Pages');
      expect(book.metricDisplay, 'Pages: 172 / 303');
    });

    test('Zero total avoids division by zero', () {
      final game = MediaItem(
        id: 'g1',
        type: MediaType.videoGame,
        title: 'New Game',
        releaseYear: 2024,
        progressCurrent: 0,
        progressTotal: 0,
      );
      expect(game.progressRatio, 0.0);
      expect(game.progressPercent, 0);
    });

    test('Rating score gradients exist for all intervals', () {
      final lowScore = MediaItem(
        id: '1',
        type: MediaType.movie,
        title: 'Movie',
        releaseYear: 2020,
        progressCurrent: 10,
        progressTotal: 100,
        score: 3.0,
      );
      final highScore = lowScore.copyWith(score: 9.5);
      expect(lowScore.scoreGradient.length, 2);
      expect(highScore.scoreGradient.length, 2);
    });
  });

  group('Shamsi Events & Iranian Holiday Defaults', () {
    test('Default events contain Nowruz and official holidays', () {
      final events = ShamsiEvent.defaultEvents;
      expect(events.isNotEmpty, true);

      final nowruz = events.firstWhere((e) => e.jalaliMonth == 1 && e.jalaliDay == 1);
      expect(nowruz.isOfficialHoliday, true);
      expect(nowruz.title.contains('نوروز'), true);
    });

    test('Action checkpoint toggling works as intended', () {
      const birthday = ShamsiEvent(
        id: 'b1',
        title: 'Maryam Birthday',
        jalaliMonth: 8,
        jalaliDay: 23,
        actionChecked: false,
      );
      final checked = birthday.copyWith(actionChecked: true);
      expect(checked.actionChecked, true);
    });
  });

  group('1. DateNavigationService (Item 1)', () {
    test('Key formatting and parsing is lossless roundtrip', () {
      final original = Jalali(1403, 8, 23);
      final key = DateNavigationService.formatJalaliKey(original);
      expect(key, '1403-08-23');

      final parsed = DateNavigationService.parseJalaliKey(key);
      expect(parsed.year, 1403);
      expect(parsed.month, 8);
      expect(parsed.day, 23);
    });

    test('isSameDate and isToday work accurately', () {
      final now = Jalali.now();
      expect(DateNavigationService.isToday(now), true);
      expect(DateNavigationService.isSameDate(now, now.addDays(1)), false);
    });

    test('shiftDays navigates by offset or resets to today on 0', () {
      final base = Jalali(1403, 1, 15);
      expect(DateNavigationService.shiftDays(base, 1).day, 16);
      expect(DateNavigationService.shiftDays(base, -1).day, 14);
      expect(DateNavigationService.shiftDays(base, 7).day, 22);
      expect(DateNavigationService.isSameDate(DateNavigationService.shiftDays(base, 0), Jalali.now()), true);
    });

    test('getTasksForDate filters tasks for target Jalali date and today defaults', () {
      final today = Jalali.now();
      final todayKey = DateNavigationService.formatJalaliKey(today);
      final tomorrow = today.addDays(1);
      final tomorrowKey = DateNavigationService.formatJalaliKey(tomorrow);

      final tasks = [
        Task(id: '1', title: 'Task Today Explicit', category: TaskCategory.daily, targetDateJalali: todayKey),
        Task(id: '2', title: 'Task Today Implicit', category: TaskCategory.daily, targetDateJalali: null),
        Task(id: '3', title: 'Task Tomorrow', category: TaskCategory.daily, targetDateJalali: tomorrowKey),
        Task(id: '4', title: 'Backlog Task', category: TaskCategory.general, targetDateJalali: todayKey),
      ];

      final todayTasks = DateNavigationService.getTasksForDate(tasks, today);
      expect(todayTasks.map((t) => t.id).toList(), containsAll(['1', '2']));
      expect(todayTasks.map((t) => t.id).toList().contains('3'), false);
      expect(todayTasks.map((t) => t.id).toList().contains('4'), false);

      final tomorrowTasks = DateNavigationService.getTasksForDate(tasks, tomorrow);
      expect(tomorrowTasks.map((t) => t.id).toList(), ['3']);
    });
  });

  group('2. TaskRescheduleService (Item 2)', () {
    test('postponeOneDay advances task to tomorrow and increments count', () {
      final current = Jalali(1403, 5, 10);
      final task = Task(
        id: 't1',
        title: 'Review PR',
        status: TaskStatus.pending,
        postponedCount: 0,
        targetDateJalali: DateNavigationService.formatJalaliKey(current),
      );

      final updated = TaskRescheduleService.postponeOneDay(task, current);
      expect(updated.status, TaskStatus.postponed);
      expect(updated.postponedCount, 1);
      expect(updated.targetDateJalali, DateNavigationService.formatJalaliKey(current.addDays(1)));
    });

    test('postponeToDate sets arbitrary target Jalali date', () {
      final target = Jalali(1403, 5, 25);
      final task = Task(
        id: 't2',
        title: 'Submit taxes',
        status: TaskStatus.pending,
        postponedCount: 1,
      );

      final updated = TaskRescheduleService.postponeToDate(task, target);
      expect(updated.status, TaskStatus.postponed);
      expect(updated.postponedCount, 2);
      expect(updated.targetDateJalali, '1403-05-25');
    });
  });

  group('3. TaskStreamFlowService (Item 3)', () {
    test('promoteToDaily transfers backlog task to daily stream on given date', () {
      final targetDate = Jalali(1403, 8, 20);
      final task = Task(
        id: 'b1',
        title: 'General Idea',
        category: TaskCategory.general,
      );

      final promoted = TaskStreamFlowService.promoteToDaily(task, targetDate);
      expect(promoted.category, TaskCategory.daily);
      expect(promoted.targetDateJalali, DateNavigationService.formatJalaliKey(targetDate));
    });

    test('demoteToBacklog demotes daily task to backlog and clears date', () {
      final task = Task(
        id: 'd1',
        title: 'Daily Task',
        category: TaskCategory.daily,
        targetDateJalali: '1403-08-20',
        status: TaskStatus.postponed,
      );

      final demoted = TaskStreamFlowService.demoteToBacklog(task);
      expect(demoted.category, TaskCategory.general);
      expect(demoted.targetDateJalali, isNull);
      expect(demoted.status, TaskStatus.pending);
    });
  });

  group('4. ReorderService (Item 4)', () {
    test('reorderTasks updates orderIndex correctly', () {
      final items = [
        Task(id: 'a', title: 'A', orderIndex: 0),
        Task(id: 'b', title: 'B', orderIndex: 1),
        Task(id: 'c', title: 'C', orderIndex: 2),
      ];

      // Move C (index 2) to top (index 0)
      final reordered = ReorderService.reorderTasks(items, 2, 0);
      expect(reordered.map((t) => t.id).toList(), ['c', 'a', 'b']);
      expect(reordered[0].orderIndex, 0);
      expect(reordered[1].orderIndex, 1);
      expect(reordered[2].orderIndex, 2);
    });

    test('reorderMedia updates customOrder correctly', () {
      final items = [
        MediaItem(id: 'm1', type: MediaType.book, title: 'Book 1', releaseYear: 2020, progressCurrent: 0, progressTotal: 100, customOrder: 0),
        MediaItem(id: 'm2', type: MediaType.book, title: 'Book 2', releaseYear: 2021, progressCurrent: 0, progressTotal: 100, customOrder: 1),
        MediaItem(id: 'm3', type: MediaType.book, title: 'Book 3', releaseYear: 2022, progressCurrent: 0, progressTotal: 100, customOrder: 2),
      ];

      // Move m1 to bottom
      final reordered = ReorderService.reorderMedia(items, 0, 3);
      expect(reordered.map((m) => m.id).toList(), ['m2', 'm3', 'm1']);
      expect(reordered[0].customOrder, 0);
      expect(reordered[1].customOrder, 1);
      expect(reordered[2].customOrder, 2);
    });
  });

  group('5. MediaLedgerCleanupService (Item 5)', () {
    test('Unit labels map correctly to all media types', () {
      expect(MediaLedgerCleanupService.unitLabelFor(MediaType.book), 'Pages');
      expect(MediaLedgerCleanupService.unitLabelFor(MediaType.tvShow), 'Episodes');
      expect(MediaLedgerCleanupService.unitLabelFor(MediaType.movie), 'Minutes');
      expect(MediaLedgerCleanupService.unitLabelFor(MediaType.videoGame), 'Chapters');

      expect(MediaLedgerCleanupService.unitInputLabelFor(MediaType.book), 'Total Pages');
      expect(MediaLedgerCleanupService.unitInputLabelFor(MediaType.tvShow), 'Total Episodes');
      expect(MediaLedgerCleanupService.unitInputLabelFor(MediaType.movie), 'Total Minutes');
      expect(MediaLedgerCleanupService.unitInputLabelFor(MediaType.videoGame), 'Total Chapters / Missions');
    });

    test('Cover cache stores and retrieves URLs correctly', () async {
      final service = MediaLedgerCleanupService();
      await service.cacheCoverArt('med_123', 'https://example.com/cover.jpg');
      expect(service.getCachedCoverArt('med_123'), 'https://example.com/cover.jpg');
      expect(service.getCachedCoverArt('unknown'), isNull);
    });
  });

  group('6. DualCalendarService (Item 6)', () {
    test('Persian digits conversion works correctly', () {
      expect(DualCalendarService.toPersianDigits(1403), '۱۴۰۳');
      expect(DualCalendarService.toPersianDigits(25), '۲۵');
    });

    test('Persian weekdays map correctly from Saturday to Friday', () {
      expect(DualCalendarService.getPersianWeekdayName(1), 'شنبه');
      expect(DualCalendarService.getPersianWeekdayName(7), 'جمعه');
    });

    test('Bilingual date combined formatting includes both Shamsi and Gregorian', () {
      final date = Jalali(1403, 8, 23);
      final combined = DualCalendarService.combinedDate(date);
      expect(combined.contains('آبان'), true);
      expect(combined.contains('۱۴۰۳'), true);
      expect(combined.contains('('), true);
      expect(combined.contains(')'), true);
    });

    test('isCheckpointCompleted checks actionChecked flag', () {
      const pendingEvent = ShamsiEvent(id: 'e1', title: 'E1', jalaliMonth: 1, jalaliDay: 1, actionChecked: false);
      const doneEvent = ShamsiEvent(id: 'e2', title: 'E2', jalaliMonth: 1, jalaliDay: 1, actionChecked: true);

      expect(DualCalendarService.isCheckpointCompleted(pendingEvent), false);
      expect(DualCalendarService.isCheckpointCompleted(doneEvent), true);
    });
  });

  group('7. WebTypographyService & Font Switching (Task 1)', () {
    test('Configured web fonts list contains all required font families', () {
      expect(WebTypographyService.configuredWebFonts, contains('Vazirmatn'));
      expect(WebTypographyService.configuredWebFonts, contains('Comic Neue'));
      expect(WebTypographyService.configuredWebFonts, contains('Quicksand'));
      expect(WebTypographyService.configuredWebFonts, contains('Fira Code'));
    });

    test('Google Fonts CSS URL contains all web font families', () {
      final url = WebTypographyService.googleFontsCssUrl;
      expect(url.contains('Vazirmatn'), true);
      expect(url.contains('Comic+Neue'), true);
      expect(url.contains('Quicksand'), true);
      expect(url.contains('Fira+Code'), true);
    });

    test('verifyFontResolution returns true for all AppFontStyle variants', () {
      for (final font in AppFontStyle.values) {
        expect(WebTypographyService.verifyFontResolution(font), true);
      }
    });

    test('ThemeData explicitly maps font across TextTheme styles', () {
      final theme = AppTheme.createTheme(ThemeVibe.deepAmethyst, AppFontStyle.comicSans);
      final family = AppTheme.getFontFamilyName(AppFontStyle.comicSans);
      final fallback = AppTheme.getFontFallbackList(AppFontStyle.comicSans);

      expect(
        WebTypographyService.verifyTextThemeApplied(theme.textTheme, family, fallback),
        true,
      );
    });
  });

  group('8. MediaLabelService & Custom Tags (Task 4)', () {
    test('Preset labels contain standard presets', () {
      expect(MediaLabelService.presetLabels, contains('Sci-Fi'));
      expect(MediaLabelService.presetLabels, contains('Drama'));
      expect(MediaLabelService.presetLabels, contains('Horror'));
      expect(MediaLabelService.presetLabels, contains('Masterpiece'));
      expect(MediaLabelService.presetLabels, contains('RPG'));
      expect(MediaLabelService.presetLabels, contains('Ongoing'));
    });

    test('addLabel appends new tag, trims whitespace, and ignores duplicates', () {
      final initial = ['Sci-Fi', 'Drama'];

      final added = MediaLabelService.addLabel(initial, '  Horror  ');
      expect(added, ['Sci-Fi', 'Drama', 'Horror']);

      // Duplicate case-insensitive
      final duplicate = MediaLabelService.addLabel(added, 'sci-fi');
      expect(duplicate.length, 3);

      // Empty string
      final empty = MediaLabelService.addLabel(added, '   ');
      expect(empty.length, 3);
    });

    test('removeLabel removes tag case-insensitively', () {
      final list = ['Sci-Fi', 'Drama', 'RPG'];
      final removed = MediaLabelService.removeLabel(list, 'drama');
      expect(removed, ['Sci-Fi', 'RPG']);
    });

    test('getSuggestions excludes assigned labels and combines pools', () {
      final current = ['Sci-Fi', 'CustomTag'];
      final extraPool = ['CustomTag', 'Indie', 'Drama'];

      final suggestions = MediaLabelService.getSuggestions(current, extraPool);
      expect(suggestions, contains('Drama'));
      expect(suggestions, contains('Indie'));
      expect(suggestions, contains('Horror'));
      expect(suggestions.contains('Sci-Fi'), false);
      expect(suggestions.contains('CustomTag'), false);
    });

    test('updateMediaLabels applies new label list to MediaItem', () {
      final item = MediaItem(
        id: 'm1',
        type: MediaType.book,
        title: 'Dune',
        releaseYear: 1965,
        progressCurrent: 100,
        progressTotal: 500,
        labels: ['Sci-Fi'],
      );

      final updated = MediaLabelService.updateMediaLabels(item, ['Sci-Fi', 'Masterpiece']);
      expect(updated.labels, ['Sci-Fi', 'Masterpiece']);
    });
  });

  group('9. MediaGoalSyncService & Auto Progress Sync (Tasks 3 & 5)', () {
    test('remainingUnits calculates remaining amount accurately', () {
      final item = MediaItem(
        id: 'm1',
        type: MediaType.book,
        title: 'Book A',
        releaseYear: 2020,
        progressCurrent: 120,
        progressTotal: 300,
      );
      expect(MediaGoalSyncService.remainingUnits(item), 180.0);

      // If current exceeds total, returns 0
      final completed = item.copyWith(progressCurrent: 350);
      expect(MediaGoalSyncService.remainingUnits(completed), 0.0);
    });

    test('validateGoalAmount enforces positive amount and remaining boundary', () {
      final item = MediaItem(
        id: 'm1',
        type: MediaType.book,
        title: 'Book A',
        releaseYear: 2020,
        progressCurrent: 50,
        progressTotal: 100,
      );

      expect(MediaGoalSyncService.validateGoalAmount(null, item), isNotNull);
      expect(MediaGoalSyncService.validateGoalAmount(0, item), isNotNull);
      expect(MediaGoalSyncService.validateGoalAmount(-5, item), isNotNull);
      expect(MediaGoalSyncService.validateGoalAmount(55, item), isNotNull);
      expect(MediaGoalSyncService.validateGoalAmount(25, item), isNull);
      expect(MediaGoalSyncService.validateGoalAmount(50, item), isNull);
    });

    test('generateGoalTaskTitle uses category-bound verbs and units', () {
      final book = MediaItem(id: '1', type: MediaType.book, title: 'Dune', releaseYear: 1965, progressCurrent: 0, progressTotal: 500);
      final show = MediaItem(id: '2', type: MediaType.tvShow, title: 'Succession', releaseYear: 2018, progressCurrent: 0, progressTotal: 39);
      final movie = MediaItem(id: '3', type: MediaType.movie, title: 'Oppenheimer', releaseYear: 2023, progressCurrent: 0, progressTotal: 180);
      final game = MediaItem(id: '4', type: MediaType.videoGame, title: 'Elden Ring', releaseYear: 2022, progressCurrent: 0, progressTotal: 30);

      expect(MediaGoalSyncService.generateGoalTaskTitle(book, 25), 'Read 25 Pages of Dune');
      expect(MediaGoalSyncService.generateGoalTaskTitle(show, 3), 'Watch 3 Episodes of Succession');
      expect(MediaGoalSyncService.generateGoalTaskTitle(movie, 45), 'Watch 45 Minutes of Oppenheimer');
      expect(MediaGoalSyncService.generateGoalTaskTitle(game, 2), 'Play 2 Chapters/Missions of Elden Ring');
    });

    test('createLinkedTask binds all properties properly', () {
      final item = MediaItem(
        id: 'med_99',
        type: MediaType.book,
        title: '1984',
        releaseYear: 1949,
        progressCurrent: 10,
        progressTotal: 300,
      );

      final task = MediaGoalSyncService.createLinkedTask(
        item: item,
        amount: 20,
        todayKey: '1403-08-25',
        orderIndex: 2,
        notes: 'Read during lunch',
      );

      expect(task.linkedMediaId, 'med_99');
      expect(task.mediaUnitsToAdvance, 20.0);
      expect(task.mediaTitle, '1984');
      expect(task.targetDateJalali, '1403-08-25');
      expect(task.orderIndex, 2);
      expect(task.notes, 'Read during lunch');
      expect(task.status, TaskStatus.pending);
      expect(task.category, TaskCategory.daily);
    });

    test('advanceProgress increments and caps at total', () {
      final item = MediaItem(
        id: '1',
        type: MediaType.book,
        title: 'Test',
        releaseYear: 2020,
        progressCurrent: 80,
        progressTotal: 100,
      );

      final advanced = MediaGoalSyncService.advanceProgress(item, 15);
      expect(advanced.progressCurrent, 95.0);

      final capped = MediaGoalSyncService.advanceProgress(item, 30);
      expect(capped.progressCurrent, 100.0);
    });

    test('revertProgress decrements and floors at zero', () {
      final item = MediaItem(
        id: '1',
        type: MediaType.book,
        title: 'Test',
        releaseYear: 2020,
        progressCurrent: 20,
        progressTotal: 100,
      );

      final reverted = MediaGoalSyncService.revertProgress(item, 15);
      expect(reverted.progressCurrent, 5.0);

      final floored = MediaGoalSyncService.revertProgress(item, 25);
      expect(floored.progressCurrent, 0.0);
    });

    test('Notification and celebration templates match specification', () {
      final item = MediaItem(
        id: '1',
        type: MediaType.book,
        title: 'Klara and the Sun',
        releaseYear: 2021,
        progressCurrent: 172,
        progressTotal: 303,
      );

      final note = MediaGoalSyncService.scheduledNotification(item, 25);
      expect(note, '🎯 Scheduled: 25 Pages of Klara and the Sun for Today!');

      final celebration = MediaGoalSyncService.celebrationMessage(item);
      expect(celebration.contains('🎉 Progress updated: Klara and the Sun is now at 172/303 Pages'), true);
    });
  });
}
