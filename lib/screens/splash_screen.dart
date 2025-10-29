import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/screens/main_screen.dart';
import 'package:reang_app/screens/dokter/konsultasi_pasien_screen.dart';
import 'package:reang_app/screens/ecomerce/admin/home_admin_umkm_screen.dart';
// Import LoginScreen tidak lagi dibutuhkan di sini
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
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await Future.wait([
      authProvider.tryAutoLogin(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (mounted) {
      // --- PERUBAHAN UTAMA DI SINI ---
      if (authProvider.isLoggedIn) {
        // Pengguna sudah login, sekarang cek rolenya
        switch (authProvider.role) {
          case 'puskesmas':
            // Arahkan ke Halaman Admin Puskesmas
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const KonsultasiPasienScreen(),
              ),
              (route) => false,
            );
            break;
          case 'umkm':
            // Arahkan ke Halaman Admin UMKM
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeAdminUmkmScreen(),
              ),
              (route) => false,
            );
            break;
          case 'user':
          default:
            // Arahkan ke Halaman Utama untuk 'user' atau role lain
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
        }
      } else {
        // Pengguna adalah tamu (belum login)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
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
