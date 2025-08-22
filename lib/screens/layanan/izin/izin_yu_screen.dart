import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/izin/izin_yu_web_screen.dart'; // Import halaman WebView

class IzinYuScreen extends StatelessWidget {
  const IzinYuScreen({super.key});

  // Data dummy untuk Info Perizinan
  final List<Map<String, dynamic>> _articles = const [
    {
      'category': 'Izin Mendirikan Bangunan',
      'timeAgo': '1 hari lalu',
      'title': 'Panduan Lengkap Mengurus IMB di Indramayu',
      'description':
          'Pahami alur, syarat, dan dokumen yang diperlukan untuk mengajukan Izin Mendirikan Bangunan (IMB) secara resmi.',
      'author': 'DPMPTSP Indramayu',
    },
    {
      'category': 'Izin Usaha',
      'timeAgo': '3 hari lalu',
      'title': 'Langkah-langkah Membuat Surat Izin Usaha Perdagangan (SIUP)',
      'description':
          'Bagi para wirausahawan, SIUP adalah dokumen wajib. Berikut adalah cara mudah untuk mengurusnya.',
      'author': 'DPMPTSP Indramayu',
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
            const Text(
              'Izin-Yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Informasi seputar perizinan di Indramayu',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Tombol untuk pindah ke halaman WebView
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text(
                'Ajukan Perizinan Online',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IzinYuWebScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // PERUBAHAN: Teks judul dan subjudul diperbarui
          Text(
            'Informasi Seputar Perizinan',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pahami alur, syarat, dan jenis perizinan yang tersedia di Indramayu.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 16),
          ..._articles.map((a) => _ArticleCard(data: a)).toList(),
        ],
      ),
    );
  }
}

// Kartu artikel (sama seperti di PajakYuScreen)
class _ArticleCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ArticleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data['category'],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['timeAgo'],
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data['description'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.hintColor),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: theme.hintColor),
                    const SizedBox(width: 6),
                    Text(
                      data['author'],
                      style: TextStyle(fontSize: 13, color: theme.hintColor),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Baca selengkapnya ›'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
