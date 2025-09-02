import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/sehat/konsultasi_dokter_screen.dart';

class KonsultasiDokterCard extends StatelessWidget {
  const KonsultasiDokterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // PERBAIKAN: Card sekarang memiliki shadow dan lebih ramping
    return Card(
      // PERBAIKAN: Shadow dibuat lebih tebal dan lebih jelas
      elevation: 8, // Naikkan nilai ini untuk shadow yang lebih tebal
      shadowColor: theme.shadowColor.withOpacity(
        0.2,
      ), // Naikkan opacity untuk warna yang lebih pekat
      // PERBAIKAN: Menambahkan garis tepi tipis untuk mempertegas batas kartu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // PERBAIKAN: Garis tepi dibuat lebih terlihat
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KonsultasiDokterScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          // PERBAIKAN: Padding vertikal diperkecil agar lebih ramping
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              // Lingkaran ikon di sebelah kiri
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Bagian teks di tengah
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konsultasi Dokter',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanya langsung seputar kesehatanmu',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Ikon panah di sebelah kanan
              Icon(
                Icons.chevron_right_rounded,
                color: theme.hintColor,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
