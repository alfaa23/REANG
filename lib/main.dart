import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Asumsikan path ini sudah benar sesuai struktur proyek Anda
import 'package:reang_app/app/theme/app_theme.dart';
import 'package:reang_app/providers/theme_provider.dart';
import 'package:reang_app/screens/main_screen.dart';

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
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MainScreen(), // Hapus 'const' karena tidak konstan
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Bungkus body dengan SafeArea
    return const Scaffold(
      body: SafeArea(
        child: Center(child: Image(image: AssetImage('assets/logo.png'))),
      ),
    );
  }
}
