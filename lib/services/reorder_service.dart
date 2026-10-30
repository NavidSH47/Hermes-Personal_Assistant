import '../models/task.dart';
import '../models/media_item.dart';

/// Service handling reordering of tasks and media items for both desktop (pointer)
/// and mobile (touch) compatibility.
class ReorderService {
  /// Reorders a list of tasks and updates each item's orderIndex.
  static List<Task> reorderTasks(List<Task> items, int oldIndex, int newIndex) {
    final list = List<Task>.from(items);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(orderIndex: i);
    }
    return list;
  }

  /// Reorders a list of media items and updates each item's customOrder.
  static List<MediaItem> reorderMedia(
      List<MediaItem> items, int oldIndex, int newIndex) {
    final list = List<MediaItem>.from(items);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(customOrder: i);
    }
    return list;
  }
}
