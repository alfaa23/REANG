import 'package:flutter/material.dart';
import 'package:reang_app/models/plesir_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:reang_app/screens/layanan/plesir/detail_plesir_screen.dart';

// Kelas helper untuk cache data per kategori
class _CachedPlesirData {
  List<PlesirModel> items = [];
  int currentPage = 1;
  bool hasMore = true;
  bool isInitiated = false; // Menandai apakah data awal sudah pernah dimuat
}

class PlesirYuScreen extends StatefulWidget {
  const PlesirYuScreen({super.key});

  @override
  State<PlesirYuScreen> createState() => _PlesirYuScreenState();
}

class _PlesirYuScreenState extends State<PlesirYuScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // State untuk caching data
  final Map<String, _CachedPlesirData> _cache = {};
  bool _isLoadingMore = false;

  // State untuk filter dinamis
  List<String> _dynamicFitur = ['Semua'];
  int _selectedFiturIndex = 0;

  // Map untuk mencocokkan nama fitur dari API dengan ikon
  final Map<String, IconData> _categoryIcons = {
    'wisata': Icons.landscape_outlined,
    'kuliner': Icons.restaurant_outlined,
    'hotel': Icons.hotel_outlined,
    'festival': Icons.celebration_outlined,
    'religi': Icons.self_improvement_outlined,
    'default': Icons.beach_access_outlined, // Ikon default jika tidak cocok
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    _loadFitur();
    _loadInitialDataForFitur('Semua');
  }

  Future<void> _loadFitur() async {
    try {
      final fitur = await _apiService.fetchInfoPlesirFitur();
      if (mounted) {
        setState(() {
          _dynamicFitur = ['Semua', ...fitur];
        });
      }
    } catch (e) {
      // Biarkan gagal secara diam-diam, setidaknya filter "Semua" tetap ada
    }
  }

  Future<void> _loadInitialDataForFitur(String fitur) async {
    // Jika data sudah ada di cache, jangan load ulang
    if (_cache[fitur]?.isInitiated == true) {
      return;
    }

    setState(() {
      _cache[fitur] = _CachedPlesirData();
    });

    try {
      final response = await _apiService.fetchInfoPlesirPaginated(
        page: 1,
        fitur: fitur,
      );
      if (mounted) {
        setState(() {
          final cacheData = _cache[fitur]!;
          cacheData.items = response.data;
          cacheData.hasMore = response.hasMorePages;
          cacheData.currentPage = 1;
          cacheData.isInitiated = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cache[fitur]!.isInitiated = true; // Tandai selesai walau error
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    final fitur = _dynamicFitur[_selectedFiturIndex];
    final cacheData = _cache[fitur];

    if (cacheData == null || !cacheData.hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    final nextPage = cacheData.currentPage + 1;
    try {
      final response = await _apiService.fetchInfoPlesirPaginated(
        page: nextPage,
        fitur: fitur,
      );
      if (mounted) {
        setState(() {
          cacheData.items.addAll(response.data);
          cacheData.hasMore = response.hasMorePages;
          cacheData.currentPage = nextPage;
        });
      }
    } catch (e) {
      // Handle error jika perlu
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _reloadData() {
    setState(() {
      _cache.clear();
      _dynamicFitur = ['Semua'];
      _selectedFiturIndex = 0;
      _initializeData();
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
        itemCount: _dynamicFitur.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final fiturName = _dynamicFitur[idx];
          final iconData =
              _categoryIcons[fiturName.toLowerCase()] ??
              _categoryIcons['default']!;
          final selected = idx == _selectedFiturIndex;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedFiturIndex = idx);
              _loadInitialDataForFitur(fiturName);
            },
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
                    iconData,
                    size: 20,
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fiturName,
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
    final selectedFiturName = _dynamicFitur[_selectedFiturIndex];
    final currentCache = _cache[selectedFiturName] ?? _CachedPlesirData();
    final currentList = currentCache.items;
    final bool isContentLoading = !currentCache.isInitiated;

    if (isContentLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentList.isEmpty) {
      return Center(
        child: Text(
          _selectedFiturIndex == 0
              ? 'Tidak ada destinasi tersedia.'
              : 'Maaf, data untuk kategori ini belum tersedia.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _reloadData(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: currentList.length + (currentCache.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          if (index == currentList.length) {
            return _isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }
          return DestinationCard(data: currentList[index]);
        },
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
