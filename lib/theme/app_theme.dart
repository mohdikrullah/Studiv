import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Color Palette ---
  // Primary: Studiv Purple
  static const Color primaryColor = Color(0xFF6C63FF); 
  static const Color primaryLight = Color(0xFF8E88FF); 
  static const Color primaryDark = Color(0xFF4B44CC);  

  // Neutral Colors
  static const Color slateGray = Color(0xFF64748B);    
  static const Color slateDark = Color(0xFF1E293B);    
  static const Color slateLight = Color(0xFFF1F5F9);   

  // Backgrounds
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF9F9FF); 

  // --- UI Helpers ---
  static const double borderRadius = 12.0;
  
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    )
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLight,
        surface: surfaceColor,
        onSurface: slateDark,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: slateDark, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.inter(color: slateDark, fontWeight: FontWeight.bold, fontSize: 24),
        bodyLarge: GoogleFonts.inter(color: slateDark, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: slateGray, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: slateDark),
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: slateLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
