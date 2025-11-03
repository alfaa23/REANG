import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:reang_app/services/api_service.dart';
// import 'package:reang_app/providers/user_provider.dart'; // <-- 1. DIHAPUS
import 'package:reang_app/providers/auth_provider.dart';

class FormTokoScreen extends StatefulWidget {
  const FormTokoScreen({super.key});

  @override
  State<FormTokoScreen> createState() => _FormTokoScreenState();
}

class _FormTokoScreenState extends State<FormTokoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Ambil provider dan navigator sebelum async gap
    final authProvider = context
        .read<AuthProvider>(); // <-- 2. HANYA AuthProvider
    // final userProvider = context.read<UserProvider>(); // <-- 3. DIHAPUS
    final navigator = Navigator.of(context); // Ambil navigator

    try {
      final token = authProvider.token;
      if (token == null) {
        throw Exception("Sesi Anda telah berakhir. Silakan login kembali.");
      }

      // 1. Panggil API untuk BUAT TOKO
      await _apiService.buatToko(
        token: token,
        nama: _namaController.text,
        deskripsi: _deskripsiController.text,
        alamat: _alamatController.text,
        noHp: _noHpController.text,
      );

      // --- 2. PERBAIKAN UTAMA ---
      // Panggil 'upgradeToUmkm' dari AuthProvider
      await authProvider.upgradeToUmkm();
      // --- AKHIR PERBAIKAN ---

      // 3. Tampilkan pesan sukses dan kembali
      // (Gunakan context.mounted untuk keamanan)
      if (!mounted) return;
      showToast(
        "Toko Anda berhasil didaftarkan!",
        context: context,
        backgroundColor: Colors.green,
        position: StyledToastPosition.bottom,
      );

      navigator.pop(); // Kembali ke halaman UmkmScreen
    } catch (e) {
      // 4. JIKA GAGAL: Tampilkan error
      if (!mounted) return;
      showToast(
        e.toString(), // Akan menampilkan pesan error dari ApiService
        context: context,
        backgroundColor: Colors.red,
        position: StyledToastPosition.bottom,
      );
    } finally {
      // 5. Selalu hentikan loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buka Toko UMKM Baru')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Lengkapi Data Toko Anda",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Toko',
                  hintText: 'Contoh: Rame Store',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama toko tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Singkat',
                  hintText: 'Toko baju paling laris se-Indramayu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap Toko',
                  hintText: 'Jalan MT Haryono blok gor...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noHpController,
                decoration: const InputDecoration(
                  labelText: 'No. HP Toko (WhatsApp)',
                  hintText: '08123456xxxx',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No. HP tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Daftarkan Toko Saya'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _submitForm,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
