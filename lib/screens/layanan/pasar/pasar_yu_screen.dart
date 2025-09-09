import 'package:flutter/material.dart';
import 'package:reang_app/models/pasar_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:reang_app/screens/layanan/pasar/update_harga_pangan_screen.dart';
import 'package:reang_app/screens/peta/peta_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PasarYuScreen extends StatefulWidget {
  const PasarYuScreen({Key? key}) : super(key: key);

  @override
  State<PasarYuScreen> createState() => _PasarYuScreenState();
}

class _PasarYuScreenState extends State<PasarYuScreen> {
  // --- PERBAIKAN: Menggunakan Future yang nullable untuk menghindari LateError ---
  Future<List<PasarModel>>? _pasarFuture;
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // --- TAMBAHAN: FocusNode untuk search field dan helper unfocus ---
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _pasarFuture = ApiService().fetchTempatPasar();
  }

  void _reloadData() {
    setState(() {
      _pasarFuture = ApiService().fetchTempatPasar();
    });
  }

  void _openMapForPasar(BuildContext context) {
    // pastikan keyboard/search nonaktif sebelum navigasi (sesuai logika KerjaYu)
    FocusManager.instance.primaryFocus?.unfocus();

    const String apiUrl = 'tempat-pasar?kategori=pasar';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PetaScreen(
          apiUrl: apiUrl,
          judulHalaman: 'Peta Pasar Terdekat',
          defaultIcon: Icons.storefront,
          defaultColor: Color(0xFF1ABC9C),
        ),
      ),
    );
  }

  Future<void> _launchMapsUrl(String lat, String lng) async {
    // pastikan keyboard/search nonaktif sebelum membuka external app
    FocusManager.instance.primaryFocus?.unfocus();

    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Tidak dapat membuka aplikasi peta';
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose(); // dispose focus node
    super.dispose();
  }

  // Pastikan searchbar ditutup saat halaman dinavigasi/pergi
  @override
  void deactivate() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.deactivate();
  }

  // Helper: unfocus hanya jika ketukan ada di luar widget yang sedang fokus.
  void _handleTapDown(TapDownDetails details) {
    final focused = FocusManager.instance.primaryFocus;
    if (focused != null && focused.context != null) {
      try {
        final renderObject = focused.context!.findRenderObject();
        if (renderObject is RenderBox && renderObject.hasSize) {
          final box = renderObject;
          final topLeft = box.localToGlobal(Offset.zero);
          final rect = topLeft & box.size;
          if (!rect.contains(details.globalPosition)) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        } else {
          // fallback
          FocusManager.instance.primaryFocus?.unfocus();
        }
      } catch (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    } else {
      // tidak ada yang fokus, tetap panggil unfocus untuk safety
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

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
              style: TextStyle(fontWeight: FontWeight.bold),
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
        // Bungkus seluruh area dengan GestureDetector untuk deteksi ketuk kosong
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: _handleTapDown,
          child: FutureBuilder<List<PasarModel>>(
            future: _pasarFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _buildErrorView(context);
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Tidak ada data pasar tersedia.'),
                );
              }

              final allPasar = snapshot.data!;
              final uniqueCategories = allPasar
                  .map((p) => p.kategori)
                  .toSet()
                  .toList();
              final List<String> dynamicCategories = [
                'Semua',
                ...uniqueCategories,
              ];

              List<PasarModel> filteredList = allPasar;
              if (_selectedCategoryIndex != 0) {
                if (_selectedCategoryIndex < dynamicCategories.length) {
                  final selectedCategory =
                      dynamicCategories[_selectedCategoryIndex];
                  filteredList = allPasar
                      .where((p) => p.kategori == selectedCategory)
                      .toList();
                }
              }
              if (_searchQuery.isNotEmpty) {
                filteredList = filteredList
                    .where(
                      (p) => p.nama.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();
              }

              final String rekomendasiTitle = _selectedCategoryIndex == 0
                  ? 'Rekomendasi untuk Anda'
                  : 'Rekomendasi ${dynamicCategories[_selectedCategoryIndex]}';

              return ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Akses Cepat',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Temukan pasar terdekat atau lihat harga pangan terbaru.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildCategoryChips(dynamicCategories),
                  const SizedBox(height: 16),
                  _buildSearchField(dynamicCategories),
                  const SizedBox(height: 24),
                  Text(
                    rekomendasiTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredList.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Tidak ada data yang cocok.'),
                      ),
                    )
                  else
                    ...filteredList
                        .map(
                          (pasar) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _PasarCard(
                              data: pasar,
                              onTap: () => _launchMapsUrl(
                                pasar.latitude,
                                pasar.longitude,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == _selectedCategoryIndex;
          return ChoiceChip(
            label: Text(categories[i]),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                // pastikan keyboard/search tidak aktif saat ganti kategori
                FocusManager.instance.primaryFocus?.unfocus();

                _searchController.clear();
                setState(() {
                  _selectedCategoryIndex = i;
                  _searchQuery = '';
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

  Widget _buildSearchField(List<String> categories) {
    final String searchHint =
        (_selectedCategoryIndex == 0 ||
            _selectedCategoryIndex >= categories.length)
        ? 'Cari di Semua...'
        : 'Cari di ${categories[_selectedCategoryIndex]}...';

    return TextField(
      controller: _searchController,
      focusNode: _searchFocus, // pasang focus node agar bisa dikontrol
      autofocus: false,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: searchHint,
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
            onPressed: () => _openMapForPasar(context),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.price_change_outlined),
            label: const Text('Update Harga Pangan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2979FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // pastikan keyboard/search nonaktif sebelum navigasi
              FocusManager.instance.primaryFocus?.unfocus();

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

class _PasarCard extends StatelessWidget {
  final PasarModel data;
  final VoidCallback onTap;

  const _PasarCard({Key? key, required this.data, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // pastikan keyboard/search nonaktif sebelum action (sesuai KerjaYu)
          FocusManager.instance.primaryFocus?.unfocus();
          onTap();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              data.foto,
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
                    data.formattedKategori.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.nama,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.alamat,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
