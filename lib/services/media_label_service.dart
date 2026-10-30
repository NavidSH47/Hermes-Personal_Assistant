import '../models/media_item.dart';

/// Service for managing entertainment custom labels, presets, and tags.
class MediaLabelService {
  /// Standard preset tags across all entertainment categories.
  static const List<String> presetLabels = [
    'Sci-Fi',
    'Drama',
    'Horror',
    'Masterpiece',
    'RPG',
    'Ongoing',
  ];

  /// Appends a new label to the list if not already present (case-insensitive).
  static List<String> addLabel(List<String> currentLabels, String newLabel) {
    final trimmed = newLabel.trim();
    if (trimmed.isEmpty) return List<String>.from(currentLabels);

    final exists = currentLabels.any(
      (l) => l.trim().toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) return List<String>.from(currentLabels);

    return [...currentLabels, trimmed];
  }

  /// Removes a label from the list (case-insensitive).
  static List<String> removeLabel(List<String> currentLabels, String labelToRemove) {
    final target = labelToRemove.trim().toLowerCase();
    return currentLabels
        .where((l) => l.trim().toLowerCase() != target)
        .toList();
  }

  /// Returns unused tag suggestions from the preset list and any extra pool tags.
  static List<String> getSuggestions(
    List<String> currentLabels, [
    List<String>? extraPool,
  ]) {
    final lowerCurrent = currentLabels.map((l) => l.trim().toLowerCase()).toSet();
    final combinedPool = <String>[...presetLabels, ...?extraPool];
    final suggestions = <String>[];
    final seen = <String>{};

    for (final tag in combinedPool) {
      final lower = tag.trim().toLowerCase();
      if (!lowerCurrent.contains(lower) && !seen.contains(lower)) {
        seen.add(lower);
        suggestions.add(tag);
      }
    }
    return suggestions;
  }

  /// Applies updated labels to a MediaItem and returns a new copy.
  static MediaItem updateMediaLabels(MediaItem item, List<String> labels) {
    return item.copyWith(labels: labels);
  }
}
