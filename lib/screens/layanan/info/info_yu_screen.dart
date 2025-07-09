import 'package:flutter/material.dart';

class InfoYuScreen extends StatelessWidget {
  const InfoYuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Info-yu'),
            Text(
              'Update terbaru hari ini',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Semua'),
                avatar: Icon(Icons.newspaper, size: 24, color: Colors.white),
                selected: true,
                onSelected: (_) {},
                showCheckmark: false,
                backgroundColor: primary.withOpacity(0.1),
                selectedColor: const Color(0xFF1C3A6A),
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                InfoCard(
                  category: 'Infrastruktur',
                  time: '2 jam lalu',
                  title:
                      'Pembangunan Jalan Tol Baru Menghubungkan Jakarta-Bandung Segera',
                  description:
                      'Proyek pembangunan jalan tol baru yang akan menghubungkan Jakarta dan Bandung direncanakan akan dimulai pada bulan depan...',
                  author: 'Admin Desa',
                ),
                SizedBox(height: 16),
                InfoCard(
                  category: 'Kesehatan',
                  time: '4 jam lalu',
                  title:
                      'Program Vaksinasi COVID-19 Tahap Ketiga Dimulai Minggu Depan',
                  description:
                      'Pemerintah mengumumkan dimulainya program vaksinasi COVID-19 tahap ketiga yang akan menyasar kelompok usia...',
                  author: 'Admin Desa',
                ),
                SizedBox(height: 16),
                InfoCard(
                  category: 'Pendidikan',
                  time: '1 hari lalu',
                  title:
                      'Pembukaan Pendaftaran Siswa Baru Tahun Ajaran 2025/2026',
                  description:
                      'Dinas Pendidikan mengumumkan jadwal dan prosedur pendaftaran siswa baru untuk jenjang SD, SMP, dan SMA...',
                  author: 'Dinas Pendidikan',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String category;
  final String time;
  final String title;
  final String description;
  final String author;

  const InfoCard({
    super.key,
    required this.category,
    required this.time,
    required this.title,
    required this.description,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                color: theme.colorScheme.surfaceVariant,
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ),
              // Ikon bookmark telah dihapus
            ],
          ),

          // Tag waktu
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                time,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // Judul
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 48),
              child: Text(
                description,
                style: TextStyle(color: theme.hintColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.person, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  author,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text(
                    'Baca selengkapnya >',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
