import 'package:flutter/material.dart';

class SehatYuScreen extends StatelessWidget {
  const SehatYuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Sehat-yu'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/indramayu.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              // PERBAIKAN: Menambahkan errorBuilder
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: theme.colorScheme.surfaceVariant,
                  child: Icon(Icons.broken_image, color: theme.hintColor),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Search bar (tidak ada perubahan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 48,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: theme.hintColor),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'cari tempat olahraga, rumah sakit ...',
                      hintStyle: TextStyle(color: theme.hintColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Grid of features
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

          // Recommendations header
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
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _RecommendationCard(
            title: 'Layanan BPJS Kesehatan',
            logoPath: 'assets/logos/bpjs.png',
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

  const _FeatureItem({Key? key, required this.iconPath, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
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
            // PERBAIKAN: Menambahkan errorBuilder
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
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
  final VoidCallback onTap;

  const _RecommendationCard({
    Key? key,
    required this.title,
    required this.logoPath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
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
            Image.asset(
              logoPath,
              width: 32,
              height: 32,
              // PERBAIKAN: Menambahkan errorBuilder
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(width: 32, height: 32);
              },
            ),
          ],
        ),
      ),
    );
  }
}
