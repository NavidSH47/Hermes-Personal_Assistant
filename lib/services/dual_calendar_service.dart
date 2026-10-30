import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../models/shamsi_event.dart';

/// Service providing bilingual (Solar Hijri & Gregorian) dates and checkpoint UI helpers.
class DualCalendarService {
  static const List<String> shamsiMonthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const List<String> persianWeekdays = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  /// Converts an English integer to Persian digits.
  static String toPersianDigits(int number) {
    const farsiDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return number
        .toString()
        .split('')
        .map((ch) {
          final idx = int.tryParse(ch);
          return idx != null ? farsiDigits[idx] : ch;
        })
        .join();
  }

  /// Returns Persian weekday name: 1 = شنبه (Saturday) to 7 = جمعه (Friday).
  static String getPersianWeekdayName(int weekday) {
    if (weekday >= 1 && weekday <= 7) {
      return persianWeekdays[weekday - 1];
    }
    return '';
  }

  /// Converts Jalali date to Persian string: e.g. "جمعه ۲۳ آبان ۱۴۰۳"
  static String toShamsiString(Jalali jalali) {
    final w = getPersianWeekdayName(jalali.weekDay);
    final d = toPersianDigits(jalali.day);
    final m = shamsiMonthNames[jalali.month - 1];
    final y = toPersianDigits(jalali.year);
    return '$w $d $m $y';
  }

  /// Converts Jalali date to Gregorian equivalent string: e.g. "Fri, 13 Nov 2026"
  static String toGregorianString(Jalali jalali) {
    final dt = jalali.toDateTime();
    return DateFormat('EEE, d MMM yyyy').format(dt);
  }

  /// Returns a combined bilingual Solar Hijri & Gregorian date string.
  /// Example: "جمعه ۲۳ آبان ۱۴۰۳ (Fri, 13 Nov 2026)"
  static String combinedDate(Jalali jalali) {
    final shamsi = toShamsiString(jalali);
    final greg = toGregorianString(jalali);
    return '$shamsi ($greg)';
  }

  /// Checks if an event checkpoint is completed.
  static bool isCheckpointCompleted(ShamsiEvent event) => event.actionChecked;
}
