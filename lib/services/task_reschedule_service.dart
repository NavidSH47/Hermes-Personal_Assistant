import '../models/task.dart';
import 'storage_service.dart';

/// Service handling advanced task rescheduling.
/// Provides two actions:
///  * `postponeOneDay` – moves a task to the next calendar day.
///  * `postponeToDate` – moves a task to an arbitrary target date.
class TaskRescheduleService {
  final StorageService storage;

  TaskRescheduleService(this.storage);

  /// Moves the given task to tomorrow (ISO date string) and updates its status.
  void postponeOneDay(Task task) {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    final iso = _isoDate(tomorrow);
    _moveTask(task, iso);
  }

  /// Moves the task to a specific [target] date (DateTime).
  void postponeToDate(Task task, DateTime target) {
    final iso = _isoDate(target);
    _moveTask(task, iso);
  }

  void _moveTask(Task task, String isoDate) {
    // Remove from current list and add to target date list via StorageService.
    storage.removeTask(task.id);
    final newTask = task.copyWith(status: TaskStatus.postponed);
    storage.saveTask(newTask, isoDate);
  }

  String _isoDate(DateTime dt) => dt.toIso8601String().split('T').first;
}
