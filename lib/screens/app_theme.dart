import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF534AB7);
  static const primaryLight = Color(0xFFEEEDFE);
  static const income = Color(0xFF1D9E75);
  static const incomeLight = Color(0xFFE1F5EE);
  static const expense = Color(0xFFD85A30);
  static const expenseLight = Color(0xFFFAECE7);

  static const catColors = [
    Color(0xFFF0997B), // Food
    Color(0xFF9FE1CB), // Travel
    Color(0xFF85B7EB), // Bills
    Color(0xFFAFA9EC), // Shopping
    Color(0xFFFAC775), // Fun
    Color(0xFFF5C4D1), // Health
    Color(0xFFC0DD97), // Education
    Color(0xFFD3D1C7), // Other
  ];

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness b) {
    final isDark = b == Brightness.dark;
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: b,
    ).copyWith(primary: primary, secondary: primary);
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: isDark ? const Color(0xFF111111) : const Color(0xFFF4F4F8),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),


      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF4F4F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}