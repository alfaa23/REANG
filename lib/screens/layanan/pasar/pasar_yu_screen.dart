import 'package:flutter/material.dart';
// PERUBAHAN: Import halaman UpdateHargaPanganScreen
import 'package:reang_app/screens/layanan/pasar/update_harga_pangan_screen.dart';

class PasarYuScreen extends StatefulWidget {
  const PasarYuScreen({Key? key}) : super(key: key);

  @override
  State<PasarYuScreen> createState() => _PasarYuScreenState();
}

class _PasarYuScreenState extends State<PasarYuScreen> {
  int _selectedCategoryIndex = 0;
  bool _isUpdatingHarga = false; // State untuk loading update harga

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
              'Pasar-yu',
              style: TextStyle(
                fontWeight: FontWeight
                    .bold, // <-- Bagian ini yang membuat teks menjadi tebal
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Jelajahi pasar dan produk lokal Indramayu',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildCategoryChips(),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 24),
            Text(
              'Rekomendasi Pasar & Toko Oleh-oleh',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // List pasar dengan desain kartu baru
            _PasarCard(
              imagePath:
                  'assets/images/pasar_indramayu.png', // Ganti dengan path gambar Anda
              jenis: 'Pasar Daerah',
              name: 'Pasar Indramayu',
              vendorCount: 156,
              distanceKm: 2.1,
            ),
            const SizedBox(height: 16),
            _PasarCard(
              imagePath:
                  'assets/images/pasar_sukra.png', // Ganti dengan path gambar Anda
              jenis: 'Pasar Desa',
              name: 'Pasar Desa Sukra',
              vendorCount: 89,
              distanceKm: 8.5,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final items = const [
      'Semua',
      'Pasar',
      'Warung',
      'UKM',
      'Petani',
      'Peternak',
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == _selectedCategoryIndex;
          return ChoiceChip(
            label: Text(items[i]),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedCategoryIndex = i;
                });
              }
            },
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari produk atau vendor...',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text('Cari Pasar Terdekat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1ABC9C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: _isUpdatingHarga
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.price_change_outlined),
            label: const Text('Update Harga Pangan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2979FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // PERUBAHAN: Menambahkan navigasi ke halaman Update Harga Pangan
            onPressed: _isUpdatingHarga
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpdateHargaPanganScreen(),
                      ),
                    );
                  },
          ),
        ),
      ],
    );
  }
}

class _PasarCard extends StatelessWidget {
  final String imagePath;
  final String jenis;
  final String name;
  final int vendorCount;
  final double distanceKm;

  const _PasarCard({
    Key? key,
    required this.imagePath,
    required this.jenis,
    required this.name,
    required this.vendorCount,
    required this.distanceKm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 140,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.storefront_outlined,
                    size: 48,
                    color: theme.hintColor,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jenis.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$vendorCount vendor • ${distanceKm} km dari lokasi Anda',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
