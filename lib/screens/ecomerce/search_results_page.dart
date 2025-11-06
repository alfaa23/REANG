import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reang_app/models/produk_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'cart_screen.dart';
import 'detail_produk_screen.dart';

// Import yang tidak perlu (FAB) sudah dihapus
// import 'package:provider/provider.dart';
// import 'package:reang_app/providers/auth_provider.dart';
// ... dll ...

class SearchResultsPage extends StatefulWidget {
  // Wajib menerima query
  final String query;
  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // --- STATE ---
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // State untuk hasil pencarian utama
  List<ProdukModel> _masterProductList = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  // State Paginasi & Error
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  String? _apiError;

  // State untuk rekomendasi jika hasil pencarian kosong
  List<ProdukModel> _recommendations = [];
  List<Map<String, dynamic>> _mappedRecommendations = [];
  bool _isLoadingRecs = false;

  // State Kategori (dihapus)
  // final List<Map<String, dynamic>> categories = ... (DIHAPUS)
  // int _selectedCategoryIndex = 0; (DIHAPUS)

  @override
  void initState() {
    super.initState();
    _fetchInitialProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // =========================================================================
  // --- FUNGSI DATA & API ---
  // =========================================================================

  /// [PERBAIKAN 1] Fungsi ini sekarang adalah target untuk RefreshIndicator
  Future<void> _fetchInitialProducts() async {
    if (!_isLoadingInitial) {
      setState(() {
        _isLoadingInitial = true;
      });
    }
    _currentPage = 1;
    _hasMorePages = true;
    _apiError = null;
    _recommendations = [];
    _mappedRecommendations = [];

    try {
      final response = await _apiService.fetchProdukPaginated(
        page: _currentPage,
        // [PERUBAHAN] Menggunakan query, bukan fitur
        query: widget.query,
      );

      _masterProductList = response.data;
      _currentPage = response.currentPage;
      _hasMorePages = response.hasMorePages;

      // Jika hasil pencarian utama kosong, panggil rekomendasi
      if (_masterProductList.isEmpty && _apiError == null) {
        _fetchRecommendations(); // (Tidak perlu 'await')
      }
    } catch (e) {
      _apiError = e.toString();
      _masterProductList = [];
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _isLoadingInitial = false;
        _filterProducts();
      });
    }
  }

  /// Fungsi baru untuk mengambil rekomendasi (produk terbaru)
  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoadingRecs = true;
    });
    try {
      // Panggil API tanpa query (atau fitur 'Semua')
      final recResponse = await _apiService.fetchProdukPaginated(
        page: 1,
        fitur: 'Semua',
      );
      _recommendations = recResponse.data;
      _mappedRecommendations = _recommendations
          .map((p) => _mapProdukModelToCardData(p))
          .toList();
    } catch (e) {
      _recommendations = [];
      _mappedRecommendations = [];
    }
    setState(() {
      _isLoadingRecs = false;
    });
  }

  Future<void> _fetchMoreProducts() async {
    if (_isLoadingMore || !_hasMorePages) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _apiService.fetchProdukPaginated(
        page: _currentPage + 1,
        // [PERUBAHAN] Menggunakan query, bukan fitur
        query: widget.query,
      );
      _masterProductList.addAll(response.data);
      _currentPage = response.currentPage;
      _hasMorePages = response.hasMorePages;
    } catch (e) {
      _apiError = e.toString();
      _hasMorePages = false;
    }

    setState(() {
      _isLoadingMore = false;
      _filterProducts();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _fetchMoreProducts();
    }
  }

  /// [PERBAIKAN] Fungsi ini disalin utuh dari umkm_screen.dart
  Map<String, dynamic> _mapProdukModelToCardData(ProdukModel produk) {
    return {
      'id': produk.id,
      'id_toko': produk.idToko,
      'image': (produk.foto != null && !produk.foto!.startsWith('http'))
          ? 'https://92021ca9d48a.ngrok-free.app/storage/${produk.foto}'
          : produk.foto,
      'title': produk.nama,
      'subtitle': produk.deskripsi ?? produk.nama,
      'rating': 4.5,
      'sold': produk.stok,
      'price_final': NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(produk.harga),
      'location': produk.lokasi ?? 'Indramayu',
      'category': produk.fitur ?? 'Lainnya',
      'stock': produk.stok,
      'description': produk.deskripsi,
      'specifications': produk.spesifikasi,
      'variasi': produk.variasi,
    };
  }

  void _filterProducts() {
    _filteredProducts = _masterProductList
        .map((p) => _mapProdukModelToCardData(p))
        .toList();
    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================================
  // --- FUNGSI BUILD ---
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // --- [PERBAIKAN 4] Kalkulasi Grid "Rapat" (disalin) ---
    const double horizontalPadding = 12.0 * 2;
    const double crossAxisSpacing = 8.0;
    final double itemWidth =
        (screenWidth - horizontalPadding - crossAxisSpacing) / 2;
    const double heightMultiplier = 1.8;
    final double childAspectRatio = itemWidth / (itemWidth * heightMultiplier);
    // --- [PERBAIKAN 4 SELESAI] ---

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // --- [PERBAIKAN 3] AppBar Dibesarkan & Disesuaikan ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65.0), // <-- Dibesarkan
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // titleSpacing 0 agar search bar rapat ke tombol back
          titleSpacing: 0.0,
          title: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                // Tap search bar untuk kembali ke halaman sugesti
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12, // <-- Dibesarkan
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.5),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.08),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: theme.hintColor, size: 20),
                      const SizedBox(width: 10),
                      // Tampilkan query yang sedang dicari
                      Expanded(
                        child: Text(
                          widget.query,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            SafeArea(
              child: Container(
                padding: const EdgeInsets.only(top: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  iconSize: 28.0, // <-- Dibesarkan
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8), // Padding kanan
          ],
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: theme.colorScheme.onSurface,
        ),
      ),
      // --- [PERBAIKAN 5 & 7] Body di-refactor ---
      body: RefreshIndicator(
        onRefresh: _fetchInitialProducts, // <-- [PERBAIKAN 1]
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // --- SLIVER 1: Header "Hasil untuk..." (Scrollable) ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                child: Text(
                  'Hasil untuk "${widget.query}"',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // --- SLIVER 2: Grid Produk (Loading/Error/Grid/Not Found) ---
            _buildProductGrid(childAspectRatio),
          ],
        ),
      ),
      // FAB Dihapus dari halaman hasil pencarian
    );
  }

  /// [PERBAIKAN 1, 2, 5]
  /// Widget helper ini di-refactor untuk mengembalikan Sliver
  Widget _buildProductGrid(double childAspectRatio) {
    final theme = Theme.of(context);

    if (_isLoadingInitial) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_apiError != null) {
      // [PERBAIKAN 2] Tampilkan error
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, color: theme.hintColor, size: 50),
              const SizedBox(height: 16),
              Text(
                'Gagal terhubung',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                'Tarik untuk mencoba lagi.',
                style: TextStyle(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_masterProductList.isEmpty) {
      // [PERBAIKAN] Tampilkan "Not Found" + Rekomendasi
      return SliverList(
        delegate: SliverChildListDelegate([
          // "Maaf..." message
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_outlined,
                  color: theme.hintColor.withOpacity(0.7),
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  'Maaf, pencarian tidak ditemukan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kata kunci "${widget.query}" tidak cocok dengan produk manapun.\nCoba periksa ejaan atau gunakan kata kunci lain.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Divider(color: theme.dividerColor.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Rekomendasi untuk Anda',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Grid Rekomendasi
          _isLoadingRecs
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mappedRecommendations.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final product = _mappedRecommendations[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailProdukScreen(product: product),
                          ),
                        );
                      },
                      child: ProductCard(product: product),
                    );
                  },
                ),
          const SizedBox(height: 24), // Padding bawah
        ]),
      );
    }

    // [PERBAIKAN 5] Kembalikan SliverPadding + SliverGrid (State Sukses)
    return SliverPadding(
      // [PERBAIKAN 4] Padding grid "rapat"
      padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 80),
      sliver: SliverGrid.builder(
        itemCount: _filteredProducts.length + (_hasMorePages ? 1 : 0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // [PERBAIKAN 4] Spasi grid "rapat"
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) {
          if (index == _filteredProducts.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final product = _filteredProducts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailProdukScreen(product: product),
                ),
              );
            },
            child: ProductCard(product: product),
          );
        },
      ),
    );
  }
}

// =========================================================================
// --- ProductCard (DISALIN PERSIS DARI umkm_screen.dart) ---
// =========================================================================
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductCard({required this.product, super.key});

  /// (Helper _buildProductImage tidak berubah)
  Widget _buildProductImage(String? imageUrl, BuildContext context) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Theme.of(context).hintColor.withOpacity(0.7),
            size: 36,
          ),
        ),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).hintColor.withOpacity(0.7),
              size: 36,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color priceColor = theme.colorScheme.primary;

    return Card(
      // [PERBAIKAN 4] Desain "Rapat" (ala Shopee)
      elevation: 1.0,
      shadowColor: theme.shadowColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0), // <-- Ujung tidak melengkung
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- FOTO PRODUK (TETAP) ---
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Hero(
                  tag: 'produk-${product['id']}',
                  child: _buildProductImage(product['image'], context),
                ),
              ),
            ],
          ),

          // --- [PERBAIKAN 1 & 4] ---
          // Bagian teks "rapat", tidak "renggang", dan tidak "panjang"
          Padding(
            padding: const EdgeInsets.all(6.0), // <-- Padding dikurangi
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween (DIHAPUS)
              children: [
                // [PERBAIKAN 1] Judul lebih besar, max 2 baris
                Text(
                  product['title'] ?? '', // <-- DULU 'subtitle'
                  style: theme.textTheme.bodyLarge?.copyWith(
                    // <-- LEBIH BESAR
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4), // <-- Spasi rapat
                Text(
                  product['price_final']!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: priceColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6), // <-- Spasi rapat
                // Baris Rating & Stok
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber.shade700,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product['rating'].toString(),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Text(
                      'Stok: ${product['sold']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4), // <-- Spasi rapat
                // Baris Lokasi
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: theme.hintColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),

                    // [PERBAIKAN] Bungkus Text dengan Expanded
                    Expanded(
                      child: Text(
                        product['location'] ??
                            'Lokasi tidak diketahui', // <-- Tambah ??
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),

                        // [PERBAIKAN] Tambahkan properti ini
                        maxLines: 1, // <-- Hanya 1 baris
                        overflow: TextOverflow.ellipsis, // <-- Tampilkan '...'
                        softWrap: false, // <-- Jangan coba-coba wrap
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // --- [PERBAIKAN SELESAI] ---
        ],
      ),
    );
  }
}
