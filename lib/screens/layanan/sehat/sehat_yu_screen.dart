import 'package:flutter/material.dart';

class SehatYuScreen extends StatelessWidget {
  const SehatYuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Sehat-yu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero image (tidak ada perubahan)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/indramayu.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image,
                    color: theme.hintColor,
                    size: 48,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // PERUBAHAN: Diubah menjadi Tombol, bukan search bar
          InkWell(
            onTap: () {
              // TODO: Tambahkan navigasi ke halaman pencarian fasilitas kesehatan
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: 52,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withAlpha((0.05 * 255).toInt()),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Ikon di dalam container berwarna
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE6C3), // Warna latar ikon
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.favorite, // Ikon hati seperti di gambar
                      color: Color(0xFFF35C5D), // Warna ikon
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // PERUBAHAN: TextField diubah menjadi Text yang solid dan "pekat"
                  Expanded(
                    child: Text(
                      'Cari tempat olahraga, rumah sakit ',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // PERUBAHAN: Tambahkan judul "Edukasi" sebelum fitur
          Text(
            'Edukasi',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Grid of features (tidak ada perubahan selain jarak)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
            children: [
              _FeatureItem(
                iconPath: 'assets/icons/no_drugs.png',
                label: 'NO DRUGS',
              ),
              _FeatureItem(
                iconPath: 'assets/icons/healthy_food.png',
                label: 'Healthy Food',
              ),
              _FeatureItem(
                iconPath: 'assets/icons/running.png',
                label: 'Olahraga',
              ),
              _FeatureItem(
                iconPath: 'assets/icons/no_smoking.png',
                label: 'NO SMOKING',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recommendations header (tidak ada perubahan)
          Text(
            'Rekomendasi',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Recommendation cards
          _RecommendationCard(
            title: 'Halodoc',
            logoPath: 'assets/logos/halodoc.png',
            logoBackgroundColor: const Color(0xFFE0004D),
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _RecommendationCard(
            title: 'Layanan BPJS Kesehatan',
            logoPath: 'assets/logos/bpjs.png',
            logoBackgroundColor: theme.colorScheme.primary,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String iconPath;
  final String label;

  const _FeatureItem({required this.iconPath, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha((0.05 * 255).toInt()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 48,
            height: 48,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: theme.hintColor,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
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
    );
  }
}
