import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF4CAF50),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
      secondary: const Color(0xFFFFC107),
    ),
    scaffoldBackgroundColor: const Color(0xFFF1F8E9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4CAF50),
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
    bottomAppBarTheme: BottomAppBarTheme(color: Colors.white),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2E7D32),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      secondary: const Color(0xFFFFC107),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1B1B1B),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E7D32),
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
    bottomAppBarTheme: BottomAppBarTheme(color: const Color(0xFF121212)),
  );
}
