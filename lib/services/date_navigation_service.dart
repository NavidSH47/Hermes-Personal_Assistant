import 'package:shamsi_date/shamsi_date.dart';
import '../models/task.dart';
import 'dual_calendar_service.dart';

/// Service handling persistent daily task registries and date navigation.
class DateNavigationService {
  /// Formats a Jalali date into a standard registry key: "YYYY-MM-DD"
  static String formatJalaliKey(Jalali date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses a "YYYY-MM-DD" key back into a Jalali date.
  static Jalali parseJalaliKey(String key) {
    try {
      final parts = key.split('-');
      if (parts.length == 3) {
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);
        return Jalali(y, m, d);
      }
    } catch (_) {}
    return Jalali.now();
  }

  /// Checks if two Jalali dates represent the same calendar day.
  static bool isSameDate(Jalali a, Jalali b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if the given Jalali date is today.
  static bool isToday(Jalali date) {
    return isSameDate(date, Jalali.now());
  }

  /// Shifts a date by a given number of days.
  /// Passing days = 0 returns today's Jalali date.
  static Jalali shiftDays(Jalali current, int days) {
    if (days == 0) return Jalali.now();
    return current.addDays(days);
  }

  /// Filters tasks belonging to a specific Jalali date.
  /// If a daily task has no targetDateJalali, it belongs to today.
  static List<Task> getTasksForDate(List<Task> allTasks, Jalali date) {
    final key = formatJalaliKey(date);
    final today = isToday(date);

    return allTasks.where((task) {
      if (task.category != TaskCategory.daily) return false;
      if (task.targetDateJalali == null || task.targetDateJalali!.isEmpty) {
        return today;
      }
      return task.targetDateJalali == key;
    }).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  /// Returns a bilingual formatted date string for the navigation bar and header.
  static String formatBilingual(Jalali date) {
    return DualCalendarService.combinedDate(date);
  }
}
