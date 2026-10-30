import '../models/media_item.dart';
import 'storage_service.dart';

/// Service handling media ledger clean-ups:
///  * Unit-label string bindings based on media type (Pages, Episodes, Minutes, Chapters).
///  * Cover art cache persistence across app restarts.
class MediaLedgerCleanupService {
  final StorageService? storage;

  MediaLedgerCleanupService([this.storage]);

  /// Returns the base metric unit name for a given MediaType.
  static String unitLabelFor(MediaType type) {
    switch (type) {
      case MediaType.book:
        return 'Pages';
      case MediaType.tvShow:
        return 'Episodes';
      case MediaType.movie:
        return 'Minutes';
      case MediaType.videoGame:
        return 'Chapters';
    }
  }

  /// Returns the input label for the Total Units field in Add/Edit dialogs.
  static String unitInputLabelFor(MediaType type) {
    switch (type) {
      case MediaType.book:
        return 'Total Pages';
      case MediaType.tvShow:
        return 'Total Episodes';
      case MediaType.movie:
        return 'Total Minutes';
      case MediaType.videoGame:
        return 'Total Chapters / Missions';
    }
  }

  /// Returns the input label for the Current Progress field in Update dialogs.
  static String currentUnitInputLabelFor(MediaType type) {
    switch (type) {
      case MediaType.book:
        return 'Current Page';
      case MediaType.tvShow:
        return 'Current Episode';
      case MediaType.movie:
        return 'Current Minute';
      case MediaType.videoGame:
        return 'Current Chapter';
    }
  }

  /// In-memory cache for cover art paths/URLs.
  static final Map<String, String> _coverArtCache = {};

  /// Caches a cover art URL or path for a media item.
  Future<void> cacheCoverArt(String mediaId, String coverUrl) async {
    _coverArtCache[mediaId] = coverUrl;
    if (storage != null) {
      await storage!.saveCoverCache(mediaId, coverUrl);
    }
  }

  /// Retrieves the cached cover art URL or path.
  String? getCachedCoverArt(String mediaId) {
    if (_coverArtCache.containsKey(mediaId)) {
      return _coverArtCache[mediaId];
    }
    if (storage != null) {
      final cached = storage!.loadCoverCache(mediaId);
      if (cached != null) {
        _coverArtCache[mediaId] = cached;
        return cached;
      }
    }
    return null;
  }
}
