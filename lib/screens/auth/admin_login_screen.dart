import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

// --- Import Halaman Tujuan ---
import 'package:reang_app/screens/main_screen.dart';
import 'package:reang_app/screens/ecomerce/admin/home_admin_umkm_screen.dart';
import 'package:reang_app/screens/dokter/konsultasi_pasien_screen.dart';

// --- Import Model ---
import 'package:reang_app/models/admin_model.dart';

// Nama class disesuaikan dengan file Anda (bisa DokterLoginScreen atau AdminLoginScreen)
class DokterLoginScreen extends StatefulWidget {
  const DokterLoginScreen({super.key});

  @override
  State<DokterLoginScreen> createState() => _DokterLoginScreenState();
}

class _DokterLoginScreenState extends State<DokterLoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (_isLoading) return;

    if (_nameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorToast("Nama dan password tidak boleh kosong.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.loginAdmin(
        name: _nameController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // --- PERBAIKAN 1: Membaca 'user' BUKAN 'admin' ---
      // Ini memperbaiki error 'type null is not subtype'
      final admin = response['user'] as AdminModel;
      final token = response['token'] as String;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // --- PERBAIKAN 2: Logika Pengecekan Role ---
      if (admin.role == 'puskesmas') {
        // Panggil API KEDUA untuk mengambil data puskesmas
        // Menggunakan .toString() seperti yang Anda minta
        final puskesmasData = await apiService.getPuskesmasByAdminId(
          admin.id.toString(),
        );

        if (puskesmasData == null) {
          // Jika tidak ada data puskesmas, tampilkan error
          throw Exception(
            'Login gagal: Akun admin ini tidak terhubung ke data puskesmas.',
          );
        }

        // Panggil provider dengan data puskesmas lengkap
        await authProvider.login(admin, token, puskesmas: puskesmasData);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const KonsultasiPasienScreen(),
            ),
            (route) => false,
          );
        }
      } else if (admin.role == 'umkm') {
        // Role 'umkm', panggil login TANPA data puskesmas
        await authProvider.login(admin, token);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeAdminUmkmScreen(),
            ),
            (route) => false,
          );
        }
      } else {
        // Role admin lain (misal: superadmin)
        await authProvider.login(admin, token);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      _showErrorToast(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper untuk toast error
  void _showErrorToast(String message) {
    showToast(
      message,
      context: context,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
      position: StyledToastPosition.bottom,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      animDuration: const Duration(milliseconds: 150),
      borderRadius: BorderRadius.circular(25),
      textStyle: const TextStyle(color: Colors.white),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/wongreang.webp', height: 75),
                const SizedBox(height: 2),
                const Text(
                  'Portal Khusus Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Nama Pengguna',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _performLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('Masuk', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
