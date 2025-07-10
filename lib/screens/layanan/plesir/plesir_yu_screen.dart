import 'package:flutter/material.dart';

class PlesirYuScreen extends StatefulWidget {
  const PlesirYuScreen({super.key});

  @override
  State<PlesirYuScreen> createState() => _PlesirYuScreenState();
}

class _PlesirYuScreenState extends State<PlesirYuScreen> {
  final List<_Category> _categories = [
    _Category('Semua', Icons.beach_access_outlined),
    _Category('Wisata', Icons.landscape_outlined),
    _Category('Kuliner', Icons.restaurant_outlined),
    _Category('Hotel', Icons.hotel_outlined),
    _Category('Festival', Icons.celebration_outlined),
    _Category('Religi', Icons.mosque_outlined),
  ];
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            const SizedBox(
              height: 24,
            ), // diperbesar agar chips lebih jauh dari header
            _buildCategoryChips(theme),
            const SizedBox(height: 12),
            Expanded(child: _buildDestinationList(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plesir-Yu',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Jelajahi destinasi impianmu',
                style: TextStyle(fontSize: 13, color: theme.hintColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final cat = _categories[idx];
          final selected = idx == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = idx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    cat.icon,
                    size: 20,
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDestinationList(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: const [
        SizedBox(height: 12),
        DestinationCard(
          color: Color(0xFF4A90E2),
          title: "Borobudur",
          name: "Candi Borobudur",
          category: "Wisata Religi",
          description:
              "Candi Buddha terbesar di dunia dengan arsitektur yang menakjubkan",
          admin: "Admin Desa",
          price: "Rp 50.000",
          location: "Magelang, Jawa Tengah",
          rating: 4.8,
        ),
        SizedBox(height: 20),
        DestinationCard(
          color: Color(0xFFF5A623),
          title: "Gudeg",
          name: "Gudeg Yu Djum",
          category: "Kuliner Tradisional",
          description:
              "Nikmati kelezatan gudeg khas Yogyakarta yang legendaris",
          admin: "Admin Desa",
          price: "Rp 30.000",
          location: "Yogyakarta",
          rating: 4.7,
        ),
        SizedBox(height: 20),
        DestinationCard(
          color: Color(0xFF7ED321),
          title: "Sekaten",
          name: "Festival Sekaten",
          category: "Festival Budaya",
          description: "Festival tradisional Walisongo di Yogyakarta",
          admin: "Panitia Sekaten",
          price: "Gratis",
          location: "Alun-alun Utara, Yogyakarta",
          rating: 4.6,
        ),
        SizedBox(height: 20),
        DestinationCard(
          color: Color(0xFFD0011B),
          title: "Masjid Agung Demak",
          name: "Masjid Agung Demak",
          category: "Religi",
          description:
              "Salah satu masjid tertua di Indonesia dengan arsitektur kuno",
          admin: "Pengelola Masjid",
          price: "Gratis",
          location: "Demak, Jawa Tengah",
          rating: 4.9,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Color color;
  final String title, name, category, description, admin, price, location;
  final double rating;

  const DestinationCard({
    super.key,
    required this.color,
    required this.title,
    required this.name,
    required this.category,
    required this.description,
    required this.admin,
    required this.price,
    required this.location,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: theme.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: color,
            height: 200,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(color: theme.hintColor, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 50),
                  child: Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(admin, style: theme.textTheme.bodyMedium),
                    ),
                    if (price.isNotEmpty)
                      Text(
                        price,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(location, style: theme.textTheme.bodyMedium),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Lihat lokasi ›",
                        style: TextStyle(fontSize: 14),
                      ),
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

class _Category {
  final String name;
  final IconData icon;
  const _Category(this.name, this.icon);
}
