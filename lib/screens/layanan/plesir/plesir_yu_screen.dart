import 'package:flutter/material.dart';
import 'package:reang_app/models/plesir_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:reang_app/screens/layanan/plesir/detail_plesir_screen.dart';

class PlesirYuScreen extends StatefulWidget {
  const PlesirYuScreen({super.key});

  @override
  State<PlesirYuScreen> createState() => _PlesirYuScreenState();
}

class _PlesirYuScreenState extends State<PlesirYuScreen> {
  late Future<List<PlesirModel>> _plesirFuture;

  final List<_Category> _categories = [
    _Category('Semua', Icons.beach_access_outlined),
    _Category('Wisata', Icons.landscape_outlined),
    _Category('Kuliner', Icons.restaurant_outlined),
    _Category('Hotel', Icons.hotel_outlined),
    _Category('Festival', Icons.celebration_outlined),
    _Category('Religi', Icons.self_improvement_outlined),
  ];
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _plesirFuture = ApiService().fetchInfoPlesir();
  }

  void _reloadData() {
    setState(() {
      _plesirFuture = ApiService().fetchInfoPlesir();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
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
    return FutureBuilder<List<PlesirModel>>(
      future: _plesirFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorView(context);
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada destinasi tersedia.'));
        }

        final allDestinations = snapshot.data!;
        List<PlesirModel> filteredList = allDestinations;

        if (_selectedCategory != 0) {
          final categoryName = _categories[_selectedCategory].name
              .toLowerCase();
          filteredList = allDestinations
              .where((d) => d.kategori.toLowerCase() == categoryName)
              .toList();
        }

        if (filteredList.isEmpty) {
          return const Center(
            child: Text('Maaf, data untuk kategori ini belum tersedia.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            return DestinationCard(data: filteredList[index]);
          },
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: theme.hintColor, size: 64),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Maaf, terjadi kesalahan. Periksa koneksi internet Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reloadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final PlesirModel data;

  const DestinationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: theme.cardColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPlesirScreen(destinationData: data),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              data.foto,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) {
                return Container(
                  height: 200,
                  color: data.headerColor,
                  child: Center(
                    child: Text(
                      data.judul,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
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
                          data.judul,
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
                            data.rating.toStringAsFixed(1),
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
                    data.formattedKategori,
                    style: TextStyle(color: theme.hintColor, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 50),
                    child: Text(
                      data.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      // --- PERUBAHAN: Ikon diubah ---
                      Icon(
                        Icons.account_circle_outlined,
                        size: 18, // Ukuran disesuaikan
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        // --- PERUBAHAN: Teks diubah ---
                        child: Text(
                          "Dispara Indramayu",
                          style: theme.textTheme.bodyMedium,
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
                        child: Text(
                          data.alamat,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "Lihat Detail ›",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
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

class _Category {
  final String name;
  final IconData icon;
  const _Category(this.name, this.icon);
}
