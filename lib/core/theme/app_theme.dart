import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // We use the same dark, sleek theme for both to enforce the aesthetic.
  static ThemeData get lightTheme => darkTheme;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00D28A), // Teal/Mint Green
        brightness: Brightness.dark,
        primary: const Color(0xFF00D28A), // Teal accent
        surface: const Color(0xFF1E2738), // Card background (dark slate)
        background: const Color(0xFF151B2B), // Scaffold background
      ),
      scaffoldBackgroundColor: const Color(0xFF151B2B), // Dark navy/slate
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A3441), width: 1), // Subtle border
        ),
        color: const Color(0xFF1E2738),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF151B2B),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A3441),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF00D28A),
      ),
    );
  }
}
