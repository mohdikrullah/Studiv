import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Color Palette ---
  // Primary: Indigo
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF3730A3);  // Indigo 800

  // Secondary / Text: Slate Gray
  static const Color slateGray = Color(0xFF64748B);    // Slate 500
  static const Color slateDark = Color(0xFF334155);    // Slate 700
  static const Color slateLight = Color(0xFF94A3B8);   // Slate 400

  // Background
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceColor = Colors.white;

  // --- Neumorphic / UI Helpers ---
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: slateGray.withValues(alpha: 0.15),
      blurRadius: 15,
      offset: const Offset(0, 8),
    )
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: slateGray,
        surface: surfaceColor,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: slateDark, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: slateDark, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(color: slateDark),
        bodyMedium: GoogleFonts.inter(color: slateGray),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: slateDark),
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
