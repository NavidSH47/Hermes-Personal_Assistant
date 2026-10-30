import 'package:shamsi_date/shamsi_date.dart';
import '../models/task.dart';
import 'date_navigation_service.dart';

/// Service managing task stream flow rules and bidirectional transfers
/// between Daily Focus and General Backlog/Orbit.
class TaskStreamFlowService {
  /// Promotes a task from General Backlog/Orbit to Today's Focus on [date].
  static Task promoteToDaily(Task task, Jalali date) {
    return task.copyWith(
      category: TaskCategory.daily,
      targetDateJalali: DateNavigationService.formatJalaliKey(date),
    );
  }

  /// Demotes a Daily Focus task back to General Backlog/Orbit.
  static Task demoteToBacklog(Task task) {
    return task.copyWith(
      category: TaskCategory.general,
      clearTargetDate: true,
      status: task.status == TaskStatus.postponed
          ? TaskStatus.pending
          : task.status,
    );
  }
}
