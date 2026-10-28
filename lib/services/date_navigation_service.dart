import 'package:intl/intl.dart';

/// Placeholder service for persisting daily task registries and navigating dates.
/// Currently stores tasks in memory; integration with StorageService will be added later.
class DateNavigationService {
  // Map of ISO date string (YYYY-MM-DD) to list of task IDs.
  final Map<String, List<String>> _dateTaskMap = {};

  /// Registers a task to a specific date.
  void registerTask(String isoDate, String taskId) {
    final list = _dateTaskMap.putIfAbsent(isoDate, () => []);
    if (!list.contains(taskId)) list.add(taskId);
  }

  /// Retrieves task IDs for the given date.
  List<String> tasksForDate(String isoDate) => _dateTaskMap[isoDate] ?? [];

  /// Returns a formatted display string for the navigation bar.
  static String formatDate(DateTime date) {
    // Example: "Fri, 23 Nov 2023"
    return DateFormat('EEE, d MMM yyyy').format(date);
  }
}
