import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/screens/main_screen.dart';
// PERUBAHAN: Import LoginScreen tidak lagi diperlukan di sini
// import 'package:reang_app/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Jalankan pengecekan token dari provider
    final authCheckFuture = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).tryAutoLogin();

    // Buat delay minimal agar logo sempat terlihat
    final delayFuture = Future.delayed(const Duration(seconds: 2));

    // Tunggu keduanya selesai
    await Future.wait([authCheckFuture, delayFuture]);

    // Pastikan widget masih ada sebelum navigasi
    if (mounted) {
      // --- PERUBAHAN UTAMA: Hapus pengecekan status login ---
      // Aplikasi akan selalu diarahkan ke MainScreen setelah pengecekan selesai,
      // tidak peduli hasilnya login atau tidak.
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/wongreang.webp', // Pastikan path ini benar
          width: 300,
        ),
      ),
    );
  }
}
