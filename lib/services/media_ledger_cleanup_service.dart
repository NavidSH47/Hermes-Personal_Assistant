import '../models/media_item.dart';
import 'storage_service.dart';

/// Service handling media ledger clean‑ups.
///  * Removes overlapping on‑hold label over the release‑year badge.
///  * Persists local cover‑art files to a cache directory.
///  * Updates unit‑label strings in the Add/Edit dialog based on media type.
class MediaLedgerCleanupService {
  final StorageService storage;

  MediaLedgerCleanupService(this.storage);

  // Placeholder: actual UI adjustments will be done in MediaCard widget.
  void fixOnHoldLabelOverlap() {}

  // Stores a downloaded cover image to a local cache folder.
  Future<void> cacheCoverArt(String url, String mediaId) async {
    // Implementation would download the image and write to
    // `<app_dir>/cache/cover_$mediaId.jpg` – left as a stub for now.
  }

  // Returns the appropriate unit label for the given media type.
  String unitLabelFor(MediaItem item) {
    switch (item.type) {
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
}
