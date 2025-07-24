import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/app/theme/app_theme.dart';
import 'package:reang_app/providers/theme_provider.dart';
import 'package:reang_app/screens/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Reang App',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // Halaman home sekarang memanggil SplashScreen dari file yang di-import
          home: const SplashScreen(),
        );
      },
    );
  }
}
