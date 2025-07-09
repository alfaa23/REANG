import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _usernameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _currentPage = 0;
  bool _isTermsAgreed = false;
  bool _isPasswordVisible = false;

  // State untuk validasi setiap input, agar bisa mengubah warna tombol
  bool _isNameValid = false;
  bool _isUsernameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk setiap controller
    _nameController.addListener(() {
      final isValid = _nameController.text.trim().isNotEmpty;
      if (_isNameValid != isValid) {
        setState(() => _isNameValid = isValid);
      }
    });
    _usernameController.addListener(() {
      final isValid = _usernameController.text.length >= 6;
      if (_isUsernameValid != isValid) {
        setState(() => _isUsernameValid = isValid);
      }
    });
    _emailController.addListener(() {
      final isValid =
          _emailController.text.contains('@') &&
          _emailController.text.contains('.');
      if (_isEmailValid != isValid) {
        setState(() => _isEmailValid = isValid);
      }
    });
    _passwordController.addListener(() {
      final isValid = _passwordController.text.length >= 6;
      if (_isPasswordValid != isValid) {
        setState(() => _isPasswordValid = isValid);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    bool isValid = false;
    if (_currentPage == 0) isValid = _nameFormKey.currentState!.validate();
    if (_currentPage == 1) isValid = _usernameFormKey.currentState!.validate();
    if (_currentPage == 2) isValid = _emailFormKey.currentState!.validate();
    if (_currentPage == 3) isValid = _passwordFormKey.currentState!.validate();

    if (isValid) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _submitRegistration() {
    if (!_isTermsAgreed) return;

    print("======================================");
    print("PROSES REGISTRASI FINAL");
    print("Nama Lengkap: ${_nameController.text}");
    print("Username:     ${_usernameController.text}");
    print("Email:        ${_emailController.text}");
    print("Password:     ${_passwordController.text}");
    print("======================================");

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pendaftaran Berhasil!')));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentPage == 0) {
              Navigator.of(context).pop();
            } else {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ProgressIndicator(currentStep: _currentPage + 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildStep(
                    formKey: _nameFormKey,
                    title: 'siapa nama kamu?',
                    child: TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration(
                        hintText: 'Nama lengkap',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    isStepValid: _isNameValid,
                  ),
                  _buildStep(
                    formKey: _usernameFormKey,
                    title: 'username apa yang ingin kamu gunakan?',
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: _buildInputDecoration(hintText: 'Username'),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Username minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    infoText:
                        'huruf (a-z), angka (0-9), titik (.) atau garis bawah (_)',
                    isStepValid: _isUsernameValid,
                  ),
                  _buildStep(
                    formKey: _emailFormKey,
                    title: 'Alamat email kamu?',
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration(hintText: 'Email'),
                      validator: (value) {
                        if (value == null ||
                            !value.contains('@') ||
                            !value.contains('.')) {
                          return 'Masukkan alamat email yang valid';
                        }
                        return null;
                      },
                    ),
                    isStepValid: _isEmailValid,
                  ),
                  _buildStep(
                    formKey: _passwordFormKey,
                    title: 'Buat password kamu',
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: _buildInputDecoration(
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    infoText: 'password dapat berupa huruf, angka atau simbol',
                    isStepValid: _isPasswordValid,
                  ),
                  _buildTermsStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required GlobalKey<FormState> formKey,
    required String title,
    required Widget child,
    required bool isStepValid,
    String? infoText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Text(title, style: _titleTextStyle()),
            const SizedBox(height: 24),
            child,
            if (infoText != null) ...[
              const SizedBox(height: 16),
              Text(infoText, style: _infoTextStyle()),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: _buttonStyle(
                  isActive: isStepValid,
                  activeColor: Colors.blue,
                ),
                child: Text('lanjutkan', style: _buttonTextStyle()),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Syarat & ketentuan', style: _titleTextStyle()),
          const SizedBox(height: 16),
          const Text(
            'selamat datang di REANG',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Dengan mendaftar dan menggunakan aplikasi Reang, Anda setuju untuk mematuhi semua syarat dan ketentuan yang berlaku.\n\n'
                  '1. Penggunaan Akun:\n'
                  '   - Anda bertanggung jawab penuh atas keamanan dan kerahasiaan akun dan password Anda.\n'
                  '   - Setiap aktivitas yang terjadi melalui akun Anda adalah tanggung jawab Anda.\n\n'
                  '2. Konten Pengguna:\n'
                  '   - Anda tidak diperkenankan untuk mengunggah konten yang melanggar hukum, bersifat SARA, pornografi, atau ujaran kebencian.\n'
                  '   - Reang berhak untuk menghapus konten atau menonaktifkan akun yang melanggar ketentuan ini tanpa pemberitahuan sebelumnya.\n\n'
                  '3. Privasi:\n'
                  '   - Kami menghargai privasi Anda. Data pribadi Anda akan dikelola sesuai dengan Kebijakan Privasi kami.\n\n'
                  'Dengan melanjutkan, Anda mengonfirmasi bahwa Anda telah membaca, memahami, dan menyetujui seluruh Syarat & Ketentuan aplikasi Reang.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Checkbox(
                  value: _isTermsAgreed,
                  onChanged: (bool? value) {
                    setState(() {
                      _isTermsAgreed = value ?? false;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                const Expanded(
                  child: Text(
                    'Saya setuju dengan Syarat & Ketentuan',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isTermsAgreed ? _submitRegistration : null,
              style: _buttonStyle(
                isActive: _isTermsAgreed,
                activeColor: Colors.blue,
              ),
              child: Text('Daftar', style: _buttonTextStyle()),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      suffixIcon: suffixIcon,
    );
  }

  TextStyle _titleTextStyle() {
    return const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
    );
  }

  TextStyle _infoTextStyle() {
    return TextStyle(color: Colors.grey[600], fontSize: 14);
  }

  ButtonStyle _buttonStyle({
    bool isActive = true,
    Color activeColor = const Color(0xFFC4C4C4),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: isActive ? activeColor : Colors.grey[300],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    );
  }

  TextStyle _buttonTextStyle() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int currentStep;
  // PERBAIKAN: Menghapus parameter `totalSteps` yang tidak digunakan
  const _ProgressIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // PERBAIKAN: Menggunakan nilai 5 secara langsung
      children: List.generate(5, (index) {
        return Container(
          width: 50,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index < currentStep ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
