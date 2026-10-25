import 'package:flutter_test/flutter_test.dart';
import 'package:nsh_assistant/models/task.dart';
import 'package:nsh_assistant/models/media_item.dart';
import 'package:nsh_assistant/models/shamsi_event.dart';

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
}
