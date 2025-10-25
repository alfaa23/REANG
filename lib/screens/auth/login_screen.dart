import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/models/user_model.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/screens/main_screen.dart';
import 'package:reang_app/screens/auth/register_screen.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

// --- TAMBAHAN: Import halaman login dokter ---
import 'package:reang_app/screens/auth/dokter_login_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool popOnSuccess;

  const LoginScreen({super.key, this.popOnSuccess = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (_isLoading) return;

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showToast(
        "Email dan password tidak boleh kosong.",
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
      final response = await apiService.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final token = response['access_token'];
      final userData = response['user'];

      if (token != null && userData != null) {
        final user = UserModel.fromMap(userData);
        if (mounted) {
          // Ganti 'user_token' agar konsisten
          await Provider.of<AuthProvider>(
            context,
            listen: false,
          ).login(user, token);
        }

        showToast(
          'Login Berhasil!',
          context: context,
          backgroundColor: Colors.green,
          position: StyledToastPosition.bottom,
          animation: StyledToastAnimation.scale, // efek "pop"
          reverseAnimation: StyledToastAnimation.fade, // pas hilang fade out
          animDuration: const Duration(milliseconds: 150), // animasi cepat
          duration: const Duration(seconds: 2), // tampil 2 detik
          borderRadius: BorderRadius.circular(25),
          textStyle: const TextStyle(color: Colors.white),
          curve: Curves.fastOutSlowIn,
        );

        if (mounted) {
          if (widget.popOnSuccess) {
            Navigator.pop(context, true);
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (Route<dynamic> route) => false,
            );
          }
        }
      } else {
        throw Exception("Token atau data pengguna tidak ditemukan.");
      }
    } catch (e) {
      showToast(
        e.toString(),
        context: context,
        backgroundColor: Colors.red,
        position: StyledToastPosition.bottom,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        animDuration: const Duration(milliseconds: 150),
        duration: const Duration(seconds: 2),
        borderRadius: BorderRadius.circular(25),
        textStyle: const TextStyle(color: Colors.white),
        curve: Curves.fastOutSlowIn,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
                  'selamat datang di Reang',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Google Sign-In
                  },
                  icon: Image.asset('assets/google_icon.webp', height: 24),
                  label: const Text('Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F2F3),
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Atau'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: lupa password
                    },
                    child: Text(
                      'lupa password?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _performLogin,
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? '),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(
                              popOnSuccess: widget.popOnSuccess,
                            ),
                          ),
                        );

                        if (result == true && mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: const Text(
                        'Daftar di sini',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),

                // --- TAMBAHAN: Tombol untuk navigasi ke Login Dokter ---
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DokterLoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Masuk sebagai Admin'),
                ),
                // ---------------------------------------------------
              ],
            ),
          ),
        ),
      ),
    );
  }
}
