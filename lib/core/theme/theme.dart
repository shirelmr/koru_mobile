import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData koruTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: KoruColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KoruColors.mid,
      brightness: Brightness.light,
    ).copyWith(
      primary: KoruColors.mid,
      secondary: KoruColors.sage,
      surface: KoruColors.card,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: KoruColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: KoruColors.dark,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: KoruColors.dark,
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFF7AAA62),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KoruColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KoruColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KoruColors.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KoruColors.mid, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
