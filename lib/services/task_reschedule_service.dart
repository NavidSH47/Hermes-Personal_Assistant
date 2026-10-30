import 'package:shamsi_date/shamsi_date.dart';
import '../models/task.dart';
import 'date_navigation_service.dart';

/// Service handling advanced task rescheduling.
/// Supports:
///  * Single-tap Postpone: Transfers task to following day (relative to current date).
///  * Long-press Postpone: Transfers task to an arbitrary target future date.
class TaskRescheduleService {
  /// Postpones a task to tomorrow (1 day after [currentDate]).
  static Task postponeOneDay(Task task, Jalali currentDate) {
    final tomorrow = currentDate.addDays(1);
    return task.copyWith(
      status: TaskStatus.postponed,
      postponedCount: task.postponedCount + 1,
      targetDateJalali: DateNavigationService.formatJalaliKey(tomorrow),
    );
  }

  /// Postpones a task to an arbitrary target future date.
  static Task postponeToDate(Task task, Jalali targetDate) {
    return task.copyWith(
      status: TaskStatus.postponed,
      postponedCount: task.postponedCount + 1,
      targetDateJalali: DateNavigationService.formatJalaliKey(targetDate),
    );
  }
}
