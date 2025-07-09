import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F6F8),
    // PERBAIKAN: Biarkan Flutter menentukan warna teks dan ikon AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF4F6F8),
      elevation: 0,
      // Properti iconTheme dan titleTextStyle dihapus agar otomatis
    ),
    cardColor: Colors.white,
    dividerColor: Colors.grey.shade200,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    useMaterial3: true, // Disarankan untuk mengaktifkan Material 3
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    // PERBAIKAN: Biarkan Flutter menentukan warna teks dan ikon AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      // Properti iconTheme dan titleTextStyle dihapus agar otomatis
    ),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: const Color(0xFF2E2E2E),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    useMaterial3: true, // Disarankan untuk mengaktifkan Material 3
  );
}
