// lib/screens/ecomerce/umkm_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/models/produk_model.dart';
// [BARU] Impor model riwayat
import 'package:reang_app/models/riwayat_transaksi_model.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'cart_screen.dart';
import 'detail_produk_screen.dart';
import 'proses_order_screen.dart';
import 'form_toko_screen.dart';
import 'package:reang_app/screens/auth/login_screen.dart';
import 'package:reang_app/screens/ecomerce/admin/home_admin_umkm_screen.dart';
import 'package:reang_app/screens/ecomerce/search_page.dart';

class UmkmScreen extends StatefulWidget {
  const UmkmScreen({super.key});

  @override
  State<UmkmScreen> createState() => _UmkmScreenState();
}

class _UmkmScreenState extends State<UmkmScreen> {
  // --- STATE ---
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<ProdukModel> _masterProductList = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  // [BARU] State untuk notifikasi "Belum Dibayar"
  int _unpaidOrderCount = 0;

  // State Paginasi & Error
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  String? _apiError;

  // State Kategori
  final List<Map<String, dynamic>> categories = const [
    {'name': 'Semua', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Fashion', 'icon': Icons.checkroom_outlined},
    {'name': 'Kuliner', 'icon': Icons.lunch_dining_outlined},
    {'name': 'Elektronik', 'icon': Icons.devices_other_outlined},
  ];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialProducts();
    _scrollController.addListener(_onScroll);

    // [BARU] Panggil hitung notifikasi saat layar dimuat
    _fetchUnpaidCount();
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

  // [BARU] Fungsi untuk mengambil & menghitung pesanan "Belum Dibayar"
  Future<void> _fetchUnpaidCount() async {
    // Cek auth provider
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn || auth.user == null || auth.token == null) {
      if (mounted) setState(() => _unpaidOrderCount = 0);
      return;
    }

    try {
      // Panggil API riwayat yang sudah ada
      final List<RiwayatTransaksiModel> allOrders = await _apiService
          .fetchRiwayatTransaksi(token: auth.token!, userId: auth.user!.id);

      // Filter HANYA untuk "Belum Dibayar"
      final count = allOrders
          .where((order) => order.getTabKategori == 'Belum Dibayar')
          .length;

      // Update state
      if (mounted) {
        setState(() {
          _unpaidOrderCount = count;
        });
      }
    } catch (e) {
      // Jika gagal, anggap 0, jangan tampilkan error
      if (mounted) setState(() => _unpaidOrderCount = 0);
    }
  }

  Future<void> _fetchInitialProducts() async {
    // ... (Fungsi ini tidak berubah) ...
    if (!_isLoadingInitial) {
      setState(() {
        _isLoadingInitial = true;
      });
    }

    _currentPage = 1;
    _hasMorePages = true;
    _apiError = null;

    try {
      final response = await _apiService.fetchProdukPaginated(
        page: _currentPage,
        fitur: categories[_selectedCategoryIndex]['name'],
      );
      _masterProductList = response.data;
      _currentPage = response.currentPage;
      _hasMorePages = response.hasMorePages;
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

  Future<void> _fetchMoreProducts() async {
    // ... (Fungsi ini tidak berubah) ...
    if (_isLoadingMore || !_hasMorePages) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _apiService.fetchProdukPaginated(
        page: _currentPage + 1,
        fitur: categories[_selectedCategoryIndex]['name'],
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
    // ... (Fungsi ini tidak berubah) ...
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _fetchMoreProducts();
    }
  }

  Map<String, dynamic> _mapProdukModelToCardData(ProdukModel produk) {
    // ... (Fungsi ini tidak berubah, pastikan URL ngrok benar) ...
    String baseUrl = "https://zara-gruffiest-silas.ngrok-free.dev";

    String? fotoUrl = produk.foto;
    if (fotoUrl != null && !fotoUrl.startsWith('http')) {
      if (fotoUrl.startsWith('storage/')) {
        fotoUrl = '$baseUrl/$fotoUrl';
      } else {
        fotoUrl = '$baseUrl/storage/$fotoUrl';
      }
    }

    return {
      'id': produk.id,
      'id_toko': produk.idToko,
      'image': fotoUrl,
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
    // ... (Fungsi ini tidak berubah) ...
    _filteredProducts = _masterProductList
        .map((p) => _mapProdukModelToCardData(p))
        .toList();
    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================================
  // --- FUNGSI EVENT HANDLER ---
  // =========================================================================

  void _onCategorySelected(int index) {
    // ... (Fungsi ini tidak berubah) ...
    setState(() {
      _selectedCategoryIndex = index;
    });
    _fetchInitialProducts();
  }

  void _navigateToOrderProcess() {
    // [DIPERBARUI] Tambahkan .then() untuk me-refresh notif saat kembali
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProsesOrderScreen()),
    ).then((_) {
      // Saat pengguna kembali dari ProsesOrderScreen,
      // panggil lagi _fetchUnpaidCount() untuk refresh notif
      _fetchUnpaidCount();
    });
  }

  // [DIPERBARUI] Ubah menjadi async untuk me-refresh notif
  void _showFabMenu() {
    // 1. Tampilkan modal SECEPAT MUNGKIN.
    //    Modal ini akan menggunakan angka '_unpaidOrderCount'
    //    yang sudah ada di state (dari 'initState').
    final authProvider = context.read<AuthProvider>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.store_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text(
                  'Toko Saya',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  authProvider.isLoggedIn
                      ? (authProvider.isUmkm
                            ? 'Kelola produk dan pesanan toko Anda'
                            : 'Daftar atau buka toko UMKM Anda')
                      : 'Login untuk mengelola toko Anda',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  if (!authProvider.isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ).then((_) {
                      // [BARU] Refresh notif setelah login
                      _fetchUnpaidCount();
                    });
                  } else {
                    if (authProvider.isUmkm) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeAdminUmkmScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FormTokoScreen(),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.receipt_long_outlined,
                  color: theme.hintColor,
                ),
                // [DIPERBARUI] Bungkus title dengan _buildNotificationBadge
                title: _buildNotificationBadge(
                  _unpaidOrderCount,
                  const Text('Pesanan Saya'),
                  // Set 'showBadge' ke false agar hanya 'Titik' merah
                  // atau atur styling badge kustom di sini.
                  // Mari kita buat badge kustom sederhana untuk ListTile
                  isDense: true, // true berarti badge lebih kecil untuk list
                ),
                subtitle: const Text('Lacak semua pesanan produk UMKM Anda'),
                onTap: () {
                  Navigator.pop(ctx);
                  _navigateToOrderProcess();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // [BARU] Widget helper untuk membuat badge notifikasi
  Widget _buildNotificationBadge(
    int count,
    Widget child, {
    bool isDense = false,
  }) {
    if (count == 0) {
      return child; // Jika tidak ada notif, kembalikan widget aslinya
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child, // Widget utama (Tombol FAB atau Teks ListTile)
        Positioned(
          // Sesuaikan posisi badge
          top: isDense ? -4 : 0,
          right: isDense ? -4 : 0,
          child: Container(
            padding: EdgeInsets.all(isDense ? 4 : 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error, // Warna merah
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
            ),
            constraints: BoxConstraints(
              minWidth: isDense ? 18 : 22,
              minHeight: isDense ? 18 : 22,
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDense ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // --- FUNGSI BUILD ---
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    // ... (Logika kalkulasi grid tidak berubah) ...
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    const double horizontalPadding = 12.0 * 2;
    const double crossAxisSpacing = 8.0;
    final double itemWidth =
        (screenWidth - horizontalPadding - crossAxisSpacing) / 2;
    const double heightMultiplier = 1.8;
    final double childAspectRatio = itemWidth / (itemWidth * heightMultiplier);

    final bottomInset =
        MediaQuery.of(context).padding.bottom +
        MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // ... (AppBar tidak berubah) ...
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SearchPage(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;
                                  final tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
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
                            Icon(
                              Icons.search,
                              color: theme.hintColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Cari produk UMKM...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    iconSize: 28.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: theme.colorScheme.onSurface,
        ),
      ),
      body: Stack(
        children: [
          // ... (Column dan Kategori tidak berubah) ...
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category['name']),
                        avatar: Icon(
                          category['icon'],
                          size: 18,
                          color: _selectedCategoryIndex == index
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
                        ),
                        selected: _selectedCategoryIndex == index,
                        showCheckmark: false,
                        onSelected: (bool selected) {
                          if (selected) {
                            _onCategorySelected(index);
                          }
                        },
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: theme.cardColor,
                        labelStyle: TextStyle(
                          color: _selectedCategoryIndex == index
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: _selectedCategoryIndex == index
                                ? Colors.transparent
                                : theme.dividerColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ... (Expanded, RefreshIndicator, CustomScrollView tidak berubah) ...
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchInitialProducts,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            10.0,
                            16.0,
                            16.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hasil Produk (${categories[_selectedCategoryIndex]['name']})',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!_isLoadingInitial && _apiError == null)
                                Text(
                                  '${_masterProductList.length} produk',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      _buildProductGrid(childAspectRatio, bottomInset),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- [DIPERBARUI] FAB (Floating Action Button) ---
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: 16.0,
                bottom: (bottomInset == 0 ? 16.0 : bottomInset) + 16.0,
              ),
              child: SizedBox(
                width: 55.0,
                height: 55.0,
                // [DIPERBARUI] Bungkus FAB dengan Badge
                child: _buildNotificationBadge(
                  _unpaidOrderCount, // Gunakan state count
                  FloatingActionButton(
                    onPressed: _showFabMenu,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 6.0,
                    tooltip: 'Menu Saya',
                    child: const Icon(Icons.apps_outlined, size: 28),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Fungsi _buildProductGrid tidak berubah) ...
  Widget _buildProductGrid(double childAspectRatio, double bottomInset) {
    if (_isLoadingInitial) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_apiError != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: Theme.of(context).hintColor,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal terhubung',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                'Tarik untuk mencoba lagi.',
                style: TextStyle(color: Theme.of(context).hintColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_masterProductList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Belum ada produk yang tersedia.',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(12.0, 0, 12.0, bottomInset + 80),
      sliver: SliverGrid.builder(
        itemCount: _filteredProducts.length + (_hasMorePages ? 1 : 0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
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
// --- ProductCard (Tidak Berubah) ---
// =========================================================================
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductCard({required this.product, super.key});

  Widget _buildProductImage(String? imageUrl, BuildContext context) {
    // ... (Fungsi ini tidak berubah) ...
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
    // ... (Fungsi ini tidak berubah) ...
    final theme = Theme.of(context);
    final Color priceColor = theme.colorScheme.primary;

    return Card(
      elevation: 1.0,
      shadowColor: theme.shadowColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Hero(
              tag: 'produk-${product['id']}',
              child: _buildProductImage(product['image'], context),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? 'Nama Produk',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['price_final']!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: priceColor,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: theme.hintColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product['location'] ?? 'Lokasi tidak diketahui',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
