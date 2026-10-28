import 'package:flutter/widgets.dart';

/// Service handling reordering of lists for both desktop (pointer) and mobile (touch).
/// Provides a generic wrapper to be used with ReorderableListView.
class ReorderService {
  /// Returns a callback for ReorderableListView that updates the provided list.
  static void Function(int oldIndex, int newIndex) reorderCallback<T>(
      List<T> items, VoidCallback onUpdated) {
    return (int oldIndex, int newIndex) {
      // Adjust index for moving downwards.
      if (oldIndex < newIndex) newIndex -= 1;
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      onUpdated();
    };
  }
}
