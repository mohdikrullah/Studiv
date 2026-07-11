import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Brand Colors (always constant) ---
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8E88FF);
  static const Color primaryDark  = Color(0xFF4B44CC);

  // --- Static/Fixed Neutral ---
  static const double borderRadius = 12.0;

  // ─────────────────────────────────────────
  // Dark Mode global flag — set once by main.dart
  // after ThemeProvider is ready.
  // ─────────────────────────────────────────
  static bool _isDark = false;
  static void setDarkMode(bool val) => _isDark = val;
  static bool get isDark => _isDark;

  // --- Adaptive Colors ---
  static Color get backgroundColor => _isDark ? const Color(0xFF0F172A) : Colors.white;
  static Color get surfaceColor    => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF9F9FF);
  static Color get cardColor       => _isDark ? const Color(0xFF1E293B) : Colors.white;
  static Color get slateDark       => _isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
  static Color get slateGray       => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get slateLight      => _isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

  // --- Shadow ---
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: _isDark
          ? Colors.black.withValues(alpha: 0.30)
          : Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // ─────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLight,
        surface: Color(0xFFF9F9FF),
        onSurface: Color(0xFF1E293B),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 24),
        bodyLarge: GoogleFonts.inter(color: const Color(0xFF1E293B), fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFF1F5F9),
    );
  }

  // ─────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────
  static ThemeData get darkTheme {
    const Color darkBg      = Color(0xFF0F172A);
    const Color darkSurface = Color(0xFF1E293B);
    const Color darkCard    = Color(0xFF1E293B);
    const Color darkText    = Color(0xFFE2E8F0);
    const Color darkSubText = Color(0xFF94A3B8);
    const Color darkSlateLight = Color(0xFF334155);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryLight,
        surface: darkSurface,
        onSurface: darkText,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: darkText, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.inter(color: darkText, fontWeight: FontWeight.bold, fontSize: 24),
        bodyLarge: GoogleFonts.inter(color: darkText, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: darkSubText, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSlateLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
        hintStyle: const TextStyle(color: darkSubText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      cardColor: darkCard,
      dividerColor: darkSlateLight,
      popupMenuTheme: const PopupMenuThemeData(color: darkCard),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: darkCard),
      dialogBackgroundColor: darkCard,
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(darkCard)),
      ),
    );
  }
}
