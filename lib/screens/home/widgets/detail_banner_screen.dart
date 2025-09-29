import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:reang_app/models/banner_model.dart';

class DetailBannerScreen extends StatelessWidget {
  final BannerModel bannerData;
  const DetailBannerScreen({super.key, required this.bannerData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mengambil konten HTML dari deskripsi banner
    final String content =
        bannerData.deskripsi ??
        "<p>Konten detail untuk banner ini belum tersedia. Silakan cek kembali nanti untuk informasi lebih lanjut mengenai <b>${bannerData.judul}</b>.</p>";

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, theme, bannerData),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Format tanggal agar lebih mudah dibaca, contoh: "29 September 2025"
                    DateFormat(
                      'd MMMM y',
                      'id_ID',
                    ).format(bannerData.createdAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bannerData.judul,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Menampilkan deskripsi dari HTML
                  HtmlWidget(
                    content,
                    textStyle: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    ThemeData theme,
    BannerModel data,
  ) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      // Tombol kembali yang adaptif terhadap tema
      leading: _buildBackButton(context, theme),
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          data.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            color: theme.colorScheme.surface,
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: theme.hintColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk tombol kembali yang warnanya menyesuaikan dengan tema
  Widget _buildBackButton(BuildContext context, ThemeData theme) {
    final bool isDarkMode = theme.brightness == Brightness.dark;
    // Jika tema gelap, ikonnya hitam pekat. Jika tema terang, ikonnya putih.
    final Color iconColor = isDarkMode ? Colors.black : Colors.white;
    // Latar belakang tombol dibuat semi-transparan
    final Color bgColor = isDarkMode
        ? Colors.white.withOpacity(0.8)
        : Colors.black.withOpacity(0.5);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: bgColor,
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Kembali',
        ),
      ),
    );
  }
}
