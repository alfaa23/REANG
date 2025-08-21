import 'package:flutter/material.dart';

class RekomendasiFiturWidget extends StatelessWidget {
  const RekomendasiFiturWidget({super.key});

  // Data dummy untuk item rekomendasi
  final List<Map<String, dynamic>> _rekomendasiItems = const [
    {'label': 'Pelajar/\nMahasiswa', 'icon': Icons.school_outlined},
    {'label': 'Pekerja\nKantoran', 'icon': Icons.work_outline_rounded},
    {'label': 'Pencari\nKerja', 'icon': Icons.person_search_outlined},
    {'label': 'Wirausaha', 'icon': Icons.storefront_outlined},
    {'label': 'Ibu Rumah\nTangga', 'icon': Icons.woman_2_outlined},
    {'label': 'Wisatawan', 'icon': Icons.luggage_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Garis atas tanpa shadow
        Container(height: 1.0, color: theme.dividerColor),
        // Konten utama dengan latar belakang gradasi
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // PERBAIKAN: Gradasi biru dibuat lebih terlihat
                Colors.blue.shade200.withOpacity(0.3),
                Colors.blue.shade200.withOpacity(0.09),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Cari Fitur yang Paling Pas Buat Kamu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0, // Ukuran font disesuaikan
                    ),
                  ),
                ),
                // PERBAIKAN: Jarak antara judul dan ikon ditambah
                const SizedBox(height: 32),
                SizedBox(
                  height: 135,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    // Padding di sini diatur agar item pertama tidak mepet ke tepi
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _rekomendasiItems.length,
                    itemBuilder: (context, index) {
                      final item = _rekomendasiItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 24.0),
                        child: Column(
                          children: [
                            // Lingkaran untuk ikon/gambar
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                              child: Icon(
                                item['icon'],
                                size: 32,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Teks label
                            Text(
                              item['label'],
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Garis bawah tanpa shadow
        Container(height: 1.0, color: theme.dividerColor),
      ],
    );
  }
}
