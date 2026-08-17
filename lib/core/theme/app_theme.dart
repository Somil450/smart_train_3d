import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0F172A),
        brightness: Brightness.light,
        primary: const Color(0xFF0284C7),
        surface: const Color(0xFFF8FAFC),
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0284C7),
        brightness: Brightness.dark,
        primary: const Color(0xFF38BDF8),
        surface: const Color(0xFF0F172A),
      ),
      scaffoldBackgroundColor: const Color(0xFF0B0F19),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: const Color(0xFF1E293B), width: 1),
        ),
        color: const Color(0xFF1E293B),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1,
      ),
    );
  }
}
