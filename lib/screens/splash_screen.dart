import 'package:flutter/material.dart';
import 'dart:async'; // Diimpor kembali untuk menggunakan Future.delayed
// PERUBAHAN: Import MainScreen sebagai tujuan navigasi
import 'package:reang_app/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            // PERUBAHAN: Tujuan diubah dari LoginScreen() menjadi MainScreen()
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Anda bisa mengganti warna background atau gambar sesuai keinginan
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/splash.jpg', // Pastikan path ini benar
          width: 300,
        ),
      ),
    );
  }
}
