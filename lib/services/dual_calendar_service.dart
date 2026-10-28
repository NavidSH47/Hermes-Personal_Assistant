import 'package:intl/intl.dart';
import '../models/shamsi_event.dart';

/// Service providing bilingual date strings and checkpoint UI helpers.
class DualCalendarService {
  /// Returns a combined Solar Hijri & Gregorian date string.
  /// Example: "جمعه ۲۳ آبان ۱۴۰۳ (Fri, 14 Nov 2024)"
  static String combinedDate(DateTime gregorian) {
    // Convert to Shamsi using the shamsi_date package if available.
    // Here we fallback to a simple placeholder.
    final shamsi = _toShamsi(gregorian);
    final gregStr = DateFormat('EEE, d MMM yyyy').format(gregorian);
    return '$shamsi ($gregStr)';
  }

  /// Returns true if the given event's checkpoint should be displayed with a strikethrough.
  static bool isCheckpointCompleted(ShamsiEvent event) => event.actionChecked;

  // Placeholder conversion – replace with proper Shamsi conversion library.
  static String _toShamsi(DateTime dt) {
    // Simple static placeholder; real implementation uses shamsi_date.
    return 'Shamsi(${dt.year}-${dt.month}-${dt.day})';
  }
}
