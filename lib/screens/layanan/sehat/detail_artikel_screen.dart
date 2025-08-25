import 'package:flutter/material.dart';

class DetailArtikelScreen extends StatelessWidget {
  // Data artikel yang akan diterima dari halaman sebelumnya
  final Map<String, dynamic> articleData;

  const DetailArtikelScreen({super.key, required this.articleData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mengambil data dengan aman, memberikan nilai default jika tidak ada
    final String imagePath = articleData['imagePath'] ?? '';
    final String title = articleData['judul'] ?? 'Judul Tidak Tersedia';
    final String author = articleData['penulis'] ?? 'Penulis Tidak Diketahui';
    final String content = articleData['content'] ?? 'Konten tidak tersedia.';
    final String waktu = articleData['waktu'] ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // AppBar fleksibel dengan gambar
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.3),
                foregroundColor: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderImage(theme, imagePath),
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
            ),
          ),

          // Konten artikel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Penulis & Waktu Posting
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(author, style: theme.textTheme.labelLarge),
                      const SizedBox(width: 8),
                      const Text('•'),
                      const SizedBox(width: 8),
                      Text(
                        waktu,
                        style: TextStyle(color: theme.hintColor, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Judul Berita
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Isi Artikel
                  Text(
                    content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(ThemeData theme, String imagePath) {
    if (imagePath.isEmpty) {
      return Container(
        color: theme.colorScheme.surfaceVariant,
        child: Center(
          child: Icon(
            Icons.newspaper,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: theme.colorScheme.surfaceVariant,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }
}
