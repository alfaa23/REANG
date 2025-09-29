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
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Latar belakang disesuaikan dengan tema untuk kontras yang lebih baik
    final Color backgroundColor = isDarkMode
        ? Colors.black
        : const Color(0xFF1A202C);
    final Color textColor = Colors.white.withOpacity(0.9);
    final Color hintColor = Colors.white.withOpacity(0.6);

    final String content =
        bannerData.deskripsi ??
        "<p>Konten detail untuk banner ini belum tersedia. Silakan cek kembali nanti untuk informasi lebih lanjut mengenai <b>${bannerData.judul}</b>.</p>";

    return Scaffold(
      // --- PERBAIKAN: Latar belakang diubah agar sesuai contoh ---
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- PERBAIKAN: AppBar disederhanakan ---
          SliverAppBar(
            pinned: true,
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat(
                      'd MMMM y',
                      'id_ID',
                    ).format(bannerData.createdAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bannerData.judul,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Teks judul dibuat putih
                    ),
                  ),
                  const SizedBox(height: 24),
                  // --- PERBAIKAN: Gambar sekarang menjadi bagian dari konten ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      bannerData.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 200,
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
                  const SizedBox(height: 24),
                  HtmlWidget(
                    content,
                    textStyle: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      color: textColor, // Teks konten disesuaikan
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
}
