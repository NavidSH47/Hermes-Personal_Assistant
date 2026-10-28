import '../models/task.dart';
import 'storage_service.dart';

/// Service for managing task stream flow rules.
/// Currently provides:
///  * `demoteTask` – move a task from Today back to Backlog/Orbit.
class TaskStreamFlowService {
  final StorageService storage;

  TaskStreamFlowService(this.storage);

  void demoteTask(Task task) {
    // Set status back to pending and remove any Today-specific flag.
    final demoted = task.copyWith(status: TaskStatus.pending);
    storage.updateTask(demoted);
  }
}
