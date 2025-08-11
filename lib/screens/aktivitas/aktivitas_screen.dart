import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/dumas/dumas_yu_screen.dart';

class AktivitasScreen extends StatelessWidget {
  const AktivitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Aktivitas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PERBAIKAN: Ukuran gambar diperbesar
              Image.asset(
                'assets/aktivitas_laporan.webp', // Pastikan path gambar ini benar
                width: 230, // Ukuran diperbesar
                errorBuilder: (c, e, s) => Icon(
                  Icons.folder_copy_outlined,
                  size: 120,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 32),

              // Judul Utama
              Text(
                'Lihat riwayat laporan Anda',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Deskripsi
              Text(
                'Akses semua riwayat pengaduan Anda melalui fitur Dumas-Yu. Anda bisa melihat status laporan Anda langsung dari halaman utama.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Tombol Aksi
              ElevatedButton(
                onPressed: () {
                  // Navigasi ke DumasYuHomeScreen dan langsung buka tab "Laporan Saya"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const DumasYuHomeScreen(bukaLaporanSaya: true),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  // PERBAIKAN: Warna tombol dibuat konsisten
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
                  ),
                  textStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Buka Laporan Saya'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
