import '../models/media_item.dart';
import '../models/task.dart';

/// Service for validating, creating, and synchronizing media daily goals and tasks.
class MediaGoalSyncService {
  /// Calculates the remaining units left until completion.
  static double remainingUnits(MediaItem item) {
    final remaining = item.progressTotal - item.progressCurrent;
    return remaining < 0 ? 0.0 : remaining;
  }

  /// Formats double unit amount cleanly (e.g. 25.0 -> '25', 2.5 -> '2.5').
  static String formatUnits(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toString();
  }

  /// Action verb bound to media category.
  static String actionVerbFor(MediaType type) {
    switch (type) {
      case MediaType.book:
        return 'Read';
      case MediaType.tvShow:
      case MediaType.movie:
        return 'Watch';
      case MediaType.videoGame:
        return 'Play';
    }
  }

  /// Validates input amount against boundary constraints (amount > 0 and <= remaining).
  static String? validateGoalAmount(double? amount, MediaItem item) {
    if (amount == null || amount <= 0) {
      return 'Amount must be greater than 0.';
    }
    final remaining = remainingUnits(item);
    if (amount > remaining) {
      return 'Amount exceeds remaining ${item.metricUnit} (${formatUnits(remaining)} left).';
    }
    return null;
  }

  /// Generates a descriptive task title (e.g. "Read 25 Pages of Klara and the Sun").
  static String generateGoalTaskTitle(MediaItem item, double amount) {
    final verb = actionVerbFor(item.type);
    final formatted = formatUnits(amount);
    return '$verb $formatted ${item.metricUnit} of ${item.title}';
  }

  /// Creates a daily task linked to a media item.
  static Task createLinkedTask({
    required MediaItem item,
    required double amount,
    required String todayKey,
    required int orderIndex,
    String notes = '',
  }) {
    return Task(
      id: 'task_media_${DateTime.now().millisecondsSinceEpoch}',
      title: generateGoalTaskTitle(item, amount),
      notes: notes,
      category: TaskCategory.daily,
      status: TaskStatus.pending,
      orderIndex: orderIndex,
      targetDateJalali: todayKey,
      linkedMediaId: item.id,
      mediaUnitsToAdvance: amount,
      mediaTitle: item.title,
    );
  }

  /// Increments media progress by task units, capped at progressTotal.
  static MediaItem advanceProgress(MediaItem item, double units) {
    final newCurrent = (item.progressCurrent + units).clamp(0.0, item.progressTotal);
    return item.copyWith(progressCurrent: newCurrent);
  }

  /// Decrements media progress by task units, floored at 0.0.
  static MediaItem revertProgress(MediaItem item, double units) {
    final newCurrent = (item.progressCurrent - units).clamp(0.0, item.progressTotal);
    return item.copyWith(progressCurrent: newCurrent);
  }

  /// Notification message shown upon goal scheduling.
  static String scheduledNotification(MediaItem item, double amount) {
    final formatted = formatUnits(amount);
    return '🎯 Scheduled: $formatted ${item.metricUnit} of ${item.title} for Today!';
  }

  /// Celebratory notification message shown upon checking task Done.
  static String celebrationMessage(MediaItem item) {
    final cur = formatUnits(item.progressCurrent);
    final tot = formatUnits(item.progressTotal);
    return '🎉 Progress updated: ${item.title} is now at $cur/$tot ${item.metricUnit} (${item.progressPercent}%)!';
  }
}
