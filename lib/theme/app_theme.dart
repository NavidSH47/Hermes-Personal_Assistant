import 'package:flutter/material.dart';

enum ThemeVibe {
  deepAmethyst,
  electricLavender,
  imperialGold,
  purpleOrange,
  cyberViolet,
  solarTangerine,
  sunsetAmber,
  arcticFrost,
  persianTurquoise,
  emeraldCyan,
  minimalNordic,
}

enum AppFontStyle {
  defaultSans,
  comicSans,
  roundedBold,
  techMono,
  editorialSerif,
  vazirmatn,
}

class VibePalette {
  final String label;
  final Color bgCanvas;
  final Color bgSurface;
  final Color bgElevated;
  final Color borderSubtle;
  final Color borderFocus;
  final Color textMain;
  final Color textMuted;
  final Color textDim;
  final Color accentPrimary;
  final LinearGradient accentGradient;
  final Color accentGlow;
  final LinearGradient sampleGradient;

  const VibePalette({
    required this.label,
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgElevated,
    required this.borderSubtle,
    required this.borderFocus,
    required this.textMain,
    required this.textMuted,
    required this.textDim,
    required this.accentPrimary,
    required this.accentGradient,
    required this.accentGlow,
    required this.sampleGradient,
  });
}

class AppTheme {
  static const Map<ThemeVibe, VibePalette> vibes = {
    ThemeVibe.deepAmethyst: VibePalette(
      label: 'Deep Amethyst',
      bgCanvas: Color(0xFF0C0714),
      bgSurface: Color(0xFF150D22),
      bgElevated: Color(0xFF221537),
      borderSubtle: Color(0x26A855F7),
      borderFocus: Color(0x59C084FC),
      textMain: Color(0xFFF0F6FC),
      textMuted: Color(0xFFC084FC),
      textDim: Color(0xFF9333EA),
      accentPrimary: Color(0xFFA855F7),
      accentGradient: LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x59A855F7),
      sampleGradient: LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
      ),
    ),
    ThemeVibe.electricLavender: VibePalette(
      label: 'Deep Lavender',
      bgCanvas: Color(0xFF07030E),
      bgSurface: Color(0xFF10061E),
      bgElevated: Color(0xFF1C0C33),
      borderSubtle: Color(0x30E9D5FF),
      borderFocus: Color(0x73E9D5FF),
      textMain: Color(0xFFFAF5FF),
      textMuted: Color(0xFFD8B4FE),
      textDim: Color(0xFFA855F7),
      accentPrimary: Color(0xFFE9D5FF),
      accentGradient: LinearGradient(
        colors: [Color(0xFFA855F7), Color(0xFFC084FC), Color(0xFFFFFFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x66E9D5FF),
      sampleGradient: LinearGradient(
        colors: [Color(0xFFA855F7), Color(0xFFFFFFFF)],
      ),
    ),
    ThemeVibe.imperialGold: VibePalette(
      label: 'Purple & Gold',
      bgCanvas: Color(0xFF080311),
      bgSurface: Color(0xFF130822),
      bgElevated: Color(0xFF1F0F35),
      borderSubtle: Color(0x33FBBF24),
      borderFocus: Color(0x73FBBF24),
      textMain: Color(0xFFFEFCE8),
      textMuted: Color(0xFFE9D5FF),
      textDim: Color(0xFFA855F7),
      accentPrimary: Color(0xFFFBBF24),
      accentGradient: LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFF59E0B), Color(0xFFFDE047)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x66FBBF24),
      sampleGradient: LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFFBBF24)],
      ),
    ),
    ThemeVibe.purpleOrange: VibePalette(
      label: 'Purple & Orange',
      bgCanvas: Color(0xFF090412),
      bgSurface: Color(0xFF140A22),
      bgElevated: Color(0xFF201135),
      borderSubtle: Color(0x33F97316),
      borderFocus: Color(0x73A855F7),
      textMain: Color(0xFFFFF7ED),
      textMuted: Color(0xFFC084FC),
      textDim: Color(0xFF7C3AED),
      accentPrimary: Color(0xFFF97316),
      accentGradient: LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFF97316)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x60F97316),
      sampleGradient: LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFF97316)],
      ),
    ),
    ThemeVibe.cyberViolet: VibePalette(
      label: 'Cyber Violet',
      bgCanvas: Color(0xFF100D1A),
      bgSurface: Color(0xFF191428),
      bgElevated: Color(0xFF241D39),
      borderSubtle: Color(0x1FFFFFFF),
      borderFocus: Color(0x408B5CF6),
      textMain: Color(0xFFF0F6FC),
      textMuted: Color(0xFF8B949E),
      textDim: Color(0xFF6E7681),
      accentPrimary: Color(0xFF8B5CF6),
      accentGradient: LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x408B5CF6),
      sampleGradient: LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      ),
    ),
    ThemeVibe.solarTangerine: VibePalette(
      label: 'Solar Tangerine',
      bgCanvas: Color(0xFF170B03),
      bgSurface: Color(0xFF261307),
      bgElevated: Color(0xFF381C0C),
      borderSubtle: Color(0x26FB923C),
      borderFocus: Color(0x59FB923C),
      textMain: Color(0xFFF0F6FC),
      textMuted: Color(0xFFFDBA74),
      textDim: Color(0xFFEA580C),
      accentPrimary: Color(0xFFFB923C),
      accentGradient: LinearGradient(
        colors: [Color(0xFFEA580C), Color(0xFFFBBF24)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x59FB923C),
      sampleGradient: LinearGradient(
        colors: [Color(0xFFEA580C), Color(0xFFFBBF24)],
      ),
    ),
    ThemeVibe.sunsetAmber: VibePalette(
      label: 'Sunset Amber',
      bgCanvas: Color(0xFF15110D),
      bgSurface: Color(0xFF221A14),
      bgElevated: Color(0xFF31261D),
      borderSubtle: Color(0x1FFFFFFF),
      borderFocus: Color(0x40F97316),
      textMain: Color(0xFFF0F6FC),
      textMuted: Color(0xFF8B949E),
      textDim: Color(0xFF6E7681),
      accentPrimary: Color(0xFFF97316),
      accentGradient: LinearGradient(
        colors: [Color(0xFFF97316), Color(0xFFF43F5E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x40F97316),
      sampleGradient: LinearGradient(
        colors: [Color(0xFFF97316), Color(0xFFF43F5E)],
      ),
    ),
    ThemeVibe.arcticFrost: VibePalette(
      label: 'Arctic Frost',
      bgCanvas: Color(0xFF090E17),
      bgSurface: Color(0xFF101926),
      bgElevated: Color(0xFF182538),
      borderSubtle: Color(0x24E0F2FE),
      borderFocus: Color(0x59E0F2FE),
      textMain: Color(0xFFF8FAFC),
      textMuted: Color(0xFF94A3B8),
      textDim: Color(0xFF64748B),
      accentPrimary: Color(0xFF38BDF8),
      accentGradient: LinearGradient(
        colors: [Color(0xFFF0F9FF), Color(0xFF38BDF8), Color(0xFF818CF8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x5938BDF8),
      sampleGradient: LinearGradient(
        colors: [Color(0xFFF0F9FF), Color(0xFF38BDF8)],
      ),
    ),
    ThemeVibe.persianTurquoise: VibePalette(
      label: 'Isfahan Cyan',
      bgCanvas: Color(0xFF091319),
      bgSurface: Color(0xFF0F1F28),
      bgElevated: Color(0xFF162D3A),
      borderSubtle: Color(0x1FFFFFFF),
      borderFocus: Color(0x4000E5FF),
      textMain: Color(0xFFF0F6FC),
      textMuted: Color(0xFF8B949E),
      textDim: Color(0xFF6E7681),
      accentPrimary: Color(0xFF00BCD4),
      accentGradient: LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFFFF6B8B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x4000E5FF),
      sampleGradient: LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFFFF6B8B)],
      ),
    ),
    ThemeVibe.emeraldCyan: VibePalette(
      label: 'Emerald Cyan',
      bgCanvas: Color(0xFF0D1314),
      bgSurface: Color(0xFF141F21),
      bgElevated: Color(0xFF1E2E31),
      borderSubtle: Color(0x1FFFFFFF),
      borderFocus: Color(0x4010B981),
      textMain: Color(0xFFF0F6FC),
      textMuted: Color(0xFF8B949E),
      textDim: Color(0xFF6E7681),
      accentPrimary: Color(0xFF10B981),
      accentGradient: LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x4010B981),
      sampleGradient: LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
      ),
    ),
    ThemeVibe.minimalNordic: VibePalette(
      label: 'Nordic Slate',
      bgCanvas: Color(0xFF121417),
      bgSurface: Color(0xFF1B1E23),
      bgElevated: Color(0xFF262A32),
      borderSubtle: Color(0x1FFFFFFF),
      borderFocus: Color(0x4060A5FA),
      textMain: Color(0xFFF0F6FC),
      textMuted: Color(0xFF8B949E),
      textDim: Color(0xFF6E7681),
      accentPrimary: Color(0xFF60A5FA),
      accentGradient: LinearGradient(
        colors: [Color(0xFF60A5FA), Color(0xFFA78BFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentGlow: Color(0x4060A5FA),
      sampleGradient: LinearGradient(
        colors: [Color(0xFF60A5FA), Color(0xFFA78BFA)],
      ),
    ),
  };

  static String getFontFamilyName(AppFontStyle font) {
    switch (font) {
      case AppFontStyle.defaultSans:
        return 'sans-serif';
      case AppFontStyle.comicSans:
        // Use Comic Sans MS for Latin with clean fallback for Persian
        return 'Comic Sans MS';
      case AppFontStyle.roundedBold:
        return 'Arial Rounded MT Bold';
      case AppFontStyle.techMono:
        return 'Cascadia Code';
      case AppFontStyle.editorialSerif:
        return 'Georgia';
      case AppFontStyle.vazirmatn:
        return 'Vazirmatn';
    }
  }

  static String getFontLabel(AppFontStyle font) {
    switch (font) {
      case AppFontStyle.defaultSans:
        return 'Default Sans';
      case AppFontStyle.comicSans:
        return 'Comic Sans';
      case AppFontStyle.roundedBold:
        return 'Rounded Bold';
      case AppFontStyle.techMono:
        return 'Tech Mono';
      case AppFontStyle.editorialSerif:
        return 'Editorial Serif';
      case AppFontStyle.vazirmatn:
        return 'Vazirmatn (وزیر)';
    }
  }

  static List<String> getFontFallbackList(AppFontStyle font) {
    switch (font) {
      case AppFontStyle.comicSans:
        // Key feature: Persian characters fall back to clean Vazirmatn/system sans
        return ['Comic Neue', 'Vazirmatn', 'Segoe UI', 'sans-serif'];
      case AppFontStyle.roundedBold:
        return ['Quicksand', 'Nunito', 'Vazirmatn', 'sans-serif'];
      case AppFontStyle.techMono:
        return ['Fira Code', 'Consolas', 'Vazirmatn', 'monospace'];
      case AppFontStyle.editorialSerif:
        return ['Cambria', 'Times New Roman', 'Vazirmatn', 'serif'];
      case AppFontStyle.vazirmatn:
        return ['Tahoma', 'Segoe UI', 'sans-serif'];
      case AppFontStyle.defaultSans:
        return ['Vazirmatn', 'Segoe UI', 'Roboto', 'sans-serif'];
    }
  }

  static ThemeData createTheme(ThemeVibe vibe, AppFontStyle font) {
    final palette = vibes[vibe] ?? vibes[ThemeVibe.deepAmethyst]!;
    final fontFamily = getFontFamilyName(font);
    final fallback = getFontFallbackList(font);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.bgCanvas,
      fontFamily: fontFamily,
      fontFamilyFallback: fallback,
      colorScheme: ColorScheme.dark(
        surface: palette.bgSurface,
        primary: palette.accentPrimary,
        secondary: palette.accentPrimary,
        onSurface: palette.textMain,
      ),
      cardTheme: CardThemeData(
        color: palette.bgElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: palette.borderSubtle),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.borderFocus),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.bgSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.textMain),
        titleTextStyle: TextStyle(
          color: palette.textMain,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
          fontFamilyFallback: fallback,
        ),
      ),
      useMaterial3: true,
    );
  }
}
