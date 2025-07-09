import 'package:flutter/material.dart';
import 'dart:async'; // Diimpor kembali untuk menggunakan Future.delayed

// Pastikan path ini sesuai dengan struktur folder Anda
import 'package:reang_app/screens/auth/login_screen.dart';

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
    // Menambahkan kembali jeda waktu singkat (1.5 detik)
    // untuk tujuan branding dan pengalaman pengguna yang lebih baik.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          // Menggunakan transisi fade yang lebih mulus
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/splash.jpg', // Pastikan path ini benar
          width: 250, // Sesuaikan ukuran logo
        ),
      ),
    );
  }
}
