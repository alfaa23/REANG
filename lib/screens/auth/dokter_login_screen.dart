import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

// --- TAMBAHAN: Import halaman tujuan dokter ---
import 'package:reang_app/screens/dokter/konsultasi_pasien_screen.dart';

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
      showToast(
        "Nama dan password tidak boleh kosong.",
        context: context,
        backgroundColor: Colors.red,
        position: StyledToastPosition.bottom,
        animation: StyledToastAnimation.scale, // efek "pop"
        reverseAnimation: StyledToastAnimation.fade, // pas hilang fade out
        animDuration: const Duration(milliseconds: 150), // animasi cepat
        duration: const Duration(seconds: 2), // tampil 2 detik
        borderRadius: BorderRadius.circular(25),
        textStyle: const TextStyle(color: Colors.white),
        curve: Curves.fastOutSlowIn,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.loginAdmin(
        name: _nameController.text,
        password: _passwordController.text,
      );

      // Pastikan widget masih ada sebelum melanjutkan
      if (!mounted) return;

      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(response['user'], response['token']);

      // Pastikan widget masih ada sebelum navigasi
      if (!mounted) return;

      // --- PERBAIKAN: Navigasi eksplisit setelah login sukses ---
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const KonsultasiPasienScreen()),
        (route) => false, // Hapus semua halaman di belakangnya
      );
    } catch (e) {
      showToast(
        e.toString(),
        context: context,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        position: StyledToastPosition.bottom,
        animation: StyledToastAnimation.scale, // efek "pop"
        reverseAnimation: StyledToastAnimation.fade, // pas hilang fade out
        animDuration: const Duration(milliseconds: 150), // animasi cepat
        borderRadius: BorderRadius.circular(25),
        textStyle: const TextStyle(color: Colors.white),
        curve: Curves.fastOutSlowIn,
      );
    } finally {
      // Pastikan loading indicator selalu mati jika terjadi error
      // atau jika navigasi gagal karena suatu alasan.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
