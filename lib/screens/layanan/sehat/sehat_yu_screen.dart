import 'package:flutter/material.dart';
// Asumsi path ini benar, sesuaikan jika perlu
import 'package:reang_app/screens/layanan/sehat/konsultasi_dokter_screen.dart';

class SehatYuScreen extends StatelessWidget {
  const SehatYuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sehat-Yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Layanan Kesehatan Digital',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildInfoLokasi(theme),
          _buildSectionTitle(theme, 'Layanan Utama'),
          _buildLayananUtama(context, theme),
          _buildSectionTitle(theme, 'Artikel Kesehatan'),
          _buildArtikelKesehatan(theme),
          _buildSectionTitle(theme, 'Aplikasi Rekomendasi'),
          _buildAplikasiRekomendasi(),
          _buildSectionTitle(theme, 'Informasi Layanan'),
          _buildInformasiLayanan(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoLokasi(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temukan informasi dan lokasi fasilitas kesehatan seperti rumah sakit, puskesmas, dan apotek di sekitar Anda. Dapatkan juga edukasi seputar gaya hidup sehat dengan mudah di sini.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? Colors.white
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          // PERUBAHAN: Bagian "Lokasi Anda" dihapus dari sini
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLayananUtama(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _LayananCard(
                    icon: Icons.local_hospital_outlined,
                    title: 'Rumah Sakit Terdekat',
                    subtitle: '24 tersedia',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LayananCard(
                    icon: Icons.sports_soccer_outlined,
                    title: 'Tempat Olahraga',
                    subtitle: '12 tersedia',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _LayananCard(
            icon: Icons.chat_bubble_outline,
            title: 'Konsultasi Dokter Berdasarkan Puskesmas',
            subtitle: '8 tersedia',
            isFullWidth: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KonsultasiDokterScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArtikelKesehatan(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _ArtikelCard(
            imagePath: 'assets/images/artikel_stroke.png',
            kategori: 'Kesehatan',
            judul: 'Keseringan Begadang Bisa Picu Stroke, Kok Bisa?',
            penulis: 'Dr. Sarah Wijaya',
            waktu: '1 jam lalu',
          ),
          _ArtikelCard(
            imagePath: 'assets/images/artikel_olahraga.png',
            kategori: 'Olahraga',
            judul: 'Tips Olahraga Ringan untuk Pemula yang Efektif',
            penulis: 'Fitness Coach Ahmad',
            waktu: '1 hari lalu',
          ),
          _ArtikelCard(
            imagePath: 'assets/images/artikel_vaksin.png',
            kategori: 'Pencegahan',
            judul: 'Pentingnya Vaksinasi untuk Kesehatan Keluarga',
            penulis: 'Admin Dinkes',
            waktu: '3 hari lalu',
          ),
        ],
      ),
    );
  }

  Widget _buildAplikasiRekomendasi() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _RekomendasiCard(
            logoPath: 'assets/logos/halodoc.png',
            title: 'Halodoc',
            subtitle: 'Konsultasi dokter online 24/7',
          ),
          _RekomendasiCard(
            logoPath: 'assets/logos/bpjs.png',
            title: 'BPJS Kesehatan',
            subtitle: 'Layanan kesehatan terjangkau',
          ),
          _RekomendasiCard(
            logoPath: 'assets/logos/alodokter.png',
            title: 'Alodokter',
            subtitle: 'Informasi kesehatan terpercaya',
            rating: '4.7',
          ),
        ],
      ),
    );
  }

  Widget _buildInformasiLayanan(BuildContext context) {
    const infoItems = [
      {
        'icon': Icons.access_time_outlined,
        'title': 'Jam Operasional',
        'lines': [
          'Senin - Jumat: 08:00 - 16:00',
          'Sabtu: 08:00 - 12:00',
          'Minggu: Tutup',
        ],
      },
      {
        'icon': Icons.phone_outlined,
        'title': 'Kontak Bantuan',
        'lines': [
          'Telepon: (0234) 1234567',
          'WhatsApp: 0812-3456-7890',
          'Email: adminduk@desa.go.id',
        ],
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Lokasi Kantor',
        'lines': [
          'Jl. Ir. H. Juanda No.1, Singajaya, Kec. Indramayu, Jawa Barat 45218',
        ],
      },
      {
        'icon': Icons.lightbulb_outline,
        'title': 'Tips',
        'lines': [
          'Tulis keluhan dengan jelas',
          'Sebutkan sudah berapa lama sakit',
          'Lampirkan foto jika perlu',
        ],
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _InfoCard(data: infoItems[0])),
                const SizedBox(width: 12),
                Expanded(child: _InfoCard(data: infoItems[1])),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _InfoCard(data: infoItems[2])),
                const SizedBox(width: 12),
                Expanded(child: _InfoCard(data: infoItems[3])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET-WIDGET KECIL ---

class _LayananCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFullWidth;
  final VoidCallback? onTap;

  const _LayananCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isFullWidth = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isFullWidth
              ? Row(
                  children: [
                    _buildIcon(theme),
                    const SizedBox(width: 12),
                    Expanded(child: _buildText(theme)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIcon(theme),
                    const SizedBox(height: 12),
                    _buildText(theme),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 24, color: theme.colorScheme.onPrimaryContainer),
    );
  }

  Widget _buildText(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }
}

class _ArtikelCard extends StatelessWidget {
  final String imagePath, kategori, judul, penulis, waktu;
  const _ArtikelCard({
    required this.imagePath,
    required this.kategori,
    required this.judul,
    required this.penulis,
    required this.waktu,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 160,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: theme.hintColor,
                    size: 40,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kategori,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    judul,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '$penulis • $waktu',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Baca ›',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RekomendasiCard extends StatelessWidget {
  final String logoPath, title, subtitle;
  final String? rating;

  const _RekomendasiCard({
    required this.logoPath,
    required this.title,
    required this.subtitle,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Image.asset(
              logoPath,
              width: 48,
              height: 48,
              errorBuilder: (c, e, s) => const SizedBox(width: 48, height: 48),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            if (rating != null)
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data['icon'] as IconData,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
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
