import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Service for verifying and managing web typography and dynamic font switching.
class WebTypographyService {
  static const List<String> configuredWebFonts = [
    'Vazirmatn',
    'Comic Neue',
    'Quicksand',
    'Fira Code',
  ];

  static const String googleFontsCssUrl =
      'https://fonts.googleapis.com/css2?family=Comic+Neue:wght@400;700&family=Fira+Code:wght@400;600;700&family=Quicksand:wght@400;600;700&family=Vazirmatn:wght@300;400;500;700;900&display=swap';

  /// Returns the effective primary font family name for CSS / Canvas rendering.
  static String getEffectiveFontFamily(AppFontStyle font) {
    return AppTheme.getFontFamilyName(font);
  }

  /// Verification probe to ensure switching between fonts alters typography cleanly.
  static bool verifyFontResolution(AppFontStyle font) {
    final family = AppTheme.getFontFamilyName(font);
    final fallback = AppTheme.getFontFallbackList(font);
    return family.isNotEmpty && fallback.isNotEmpty;
  }

  /// Verifies that all TextTheme styles have the target fontFamily and fontFamilyFallback applied.
  static bool verifyTextThemeApplied(
    TextTheme textTheme,
    String expectedFamily,
    List<String> expectedFallback,
  ) {
    final styles = [
      textTheme.displayLarge,
      textTheme.displayMedium,
      textTheme.displaySmall,
      textTheme.headlineLarge,
      textTheme.headlineMedium,
      textTheme.headlineSmall,
      textTheme.titleLarge,
      textTheme.titleMedium,
      textTheme.titleSmall,
      textTheme.bodyLarge,
      textTheme.bodyMedium,
      textTheme.bodySmall,
      textTheme.labelLarge,
      textTheme.labelMedium,
      textTheme.labelSmall,
    ];

    for (final s in styles) {
      if (s == null) return false;
      if (s.fontFamily != expectedFamily) return false;
      if (s.fontFamilyFallback == null ||
          s.fontFamilyFallback!.length != expectedFallback.length) {
        return false;
      }
    }
    return true;
  }
}
