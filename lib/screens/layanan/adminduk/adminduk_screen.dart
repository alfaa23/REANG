import 'package:flutter/material.dart';

class AdmindukScreen extends StatelessWidget {
  const AdmindukScreen({super.key});

  // Data layanan dokumen
  static const _services = [
    {
      'iconWidget': 'ID',
      'iconBg': Color(0xFFEEE6FF),
      'iconColor': Color(0xFF9B59B6),
      'title': 'KTP Elektronik',
      'subtitle': 'Gratis',
      'description':
          'Kartu Tanda Penduduk elektronik untuk warga negara Indonesia',
      'requirements': ['Fotokopi KK', 'Pas foto 3×4', 'Surat pengantar RT/RW'],
    },
    {
      'iconWidget': '👶',
      'iconBg': Color(0xFFFFF3E0),
      'iconColor': Colors.orange,
      'title': 'Kartu Identitas Anak',
      'subtitle': 'Gratis',
      'description': 'Kartu identitas untuk anak usia 0‑17 tahun',
      'requirements': ['Fotokopi KK', 'Akta kelahiran', 'Pas foto 2×3'],
    },
    {
      'iconWidget': '👪',
      'iconBg': Color(0xFFE8F5E9),
      'iconColor': Colors.green,
      'title': 'Kartu Keluarga',
      'subtitle': 'Gratis',
      'description': 'Dokumen yang memuat data tentang susunan keluarga',
      'requirements': ['KTP suami istri', 'Akta nikah', 'Akta kelahiran anak'],
    },
    {
      'iconWidget': '📄',
      'iconBg': Color(0xFFFFFDE7),
      'iconColor': Colors.amber,
      'title': 'Akta Kelahiran',
      'subtitle': 'Gratis',
      'description': 'Dokumen resmi yang mencatat kelahiran seseorang',
      'requirements': [
        'Surat kelahiran dari RS/bidan',
        'KTP orang tua',
        'KK orang tua',
      ],
    },
    {
      'iconWidget': '⚰️',
      'iconBg': Color(0xFFFFEBEE),
      'iconColor': Colors.redAccent,
      'title': 'Akta Kematian',
      'subtitle': 'Gratis',
      'description': 'Dokumen resmi yang mencatat kematian seseorang',
      'requirements': [
        'Surat kematian dari RS/kelurahan',
        'KTP almarhum',
        'KTP pelapor',
      ],
    },
    {
      'iconWidget': '📦',
      'iconBg': Color(0xFFE0F7FA),
      'iconColor': Colors.teal,
      'title': 'Surat Pindah',
      'subtitle': 'Gratis',
      'description': 'Surat keterangan pindah domisili antar daerah',
      'requirements': ['KTP asli', 'KK asli', 'Surat pengantar RT/RW'],
    },
  ];

  // Data informasi layanan
  static const _infoItems = [
    {
      'title': 'Jam Operasional',
      'icon': Icons.access_time_outlined,
      'lines': [
        'Senin – Jumat: 08:00 – 16:00',
        'Sabtu: 08:00 – 12:00',
        'Minggu: Tutup',
      ],
    },
    {
      'title': 'Kontak Bantuan',
      'icon': Icons.phone_outlined,
      'lines': [
        'Telepon: (021) 123‑4567',
        'WhatsApp: 0812‑3456‑7890',
        'Email: adminduk@desa.go.id',
      ],
    },
    {
      'title': 'Lokasi Kantor',
      'icon': Icons.location_on_outlined,
      'lines': [
        'Jl. Ir. H. Juanda No.1, Singajaya, Kec. Indramayu,',
        'Kabupaten Indramayu, Jawa Barat 45218',
      ],
    },
    {
      'title': 'Tips Pengajuan',
      'icon': Icons.lightbulb_outline,
      'lines': [
        'Siapkan dokumen dalam format digital',
        'Pastikan foto/scan jelas dan tidak blur',
        'Isi data sesuai dokumen resmi',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PERUBAHAN: Teks judul dibuat tebal
            const Text(
              'Adminduk-Yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Layanan administrasi kependudukan digital',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Layanan Dokumen Kependudukan',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buat dan urus dokumen kependudukan Anda dengan mudah dan cepat',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final svc = _services[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _ServiceCard(data: svc),
              );
            }, childCount: _services.length),
          ),
          // PERUBAHAN: Menambahkan seksi Rekomendasi Aplikasi
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Rekomendasi Aplikasi',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _RecommendationCard(
                    title: 'Identitas Kependudukan Digital',
                    logoPath:
                        'assets/logos/ikd.png', // Pastikan path logo benar
                    logoBackgroundColor: Colors.blue.shade800,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _RecommendationCard(
                    title: 'Layanan BPJS Kesehatan',
                    logoPath:
                        'assets/logos/bpjs.png', // Pastikan path logo benar
                    logoBackgroundColor: theme.colorScheme.primary,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Informasi Layanan',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                // PERUBAHAN: Aspect ratio diubah agar kartu lebih tinggi
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _InfoCard(data: _infoItems[i]),
                childCount: _infoItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu satu layanan dokumen
class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ServiceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconWidget = data['iconWidget'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: data['iconBg'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      iconWidget,
                      style: TextStyle(
                        fontSize: 20,
                        color: data['iconColor'] as Color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['subtitle'],
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data['description'],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Persyaratan:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...List<Widget>.from(
              (data['requirements'] as List<String>).map(
                (req) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(req, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Admin Desa',
                      style: TextStyle(fontSize: 13, color: theme.hintColor),
                    ),
                  ],
                ),
                // PERUBAHAN: Teks tombol diubah
                TextButton(
                  onPressed: () {
                    // TODO: aksi Lihat Informasi
                  },
                  child: const Text('Lihat Informasi ›'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu info (Jam, Kontak, Lokasi, Tips)
class _InfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _InfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              data['icon'] as IconData,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 6),
            Text(
              data['title'] as String,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ...List<Widget>.from(
              (data['lines'] as List<String>).map(
                (line) => Text(
                  line,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PERUBAHAN: Widget baru untuk kartu rekomendasi
class _RecommendationCard extends StatelessWidget {
  final String title;
  final String logoPath;
  final Color logoBackgroundColor;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.title,
    required this.logoPath,
    required this.logoBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: logoBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  logoPath,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(width: 40, height: 40);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
