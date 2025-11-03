import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT DIPERBARUI ---
import 'package:reang_app/providers/auth_provider.dart';
// import 'package:reang_app/providers/user_provider.dart'; // <-- SUDAH DIHAPUS

// Import halaman-halaman yang dituju
import 'cart_screen.dart';
import 'detail_produk_screen.dart';
import 'proses_order_screen.dart';
import 'form_toko_screen.dart';
import 'package:reang_app/screens/auth/login_screen.dart'; // Sesuaikan path jika perlu
import 'package:reang_app/screens/ecomerce/admin/home_admin_umkm_screen.dart'; // Sesuaikan path jika perlu

class UmkmScreen extends StatefulWidget {
  const UmkmScreen({super.key});

  @override
  State<UmkmScreen> createState() => _UmkmScreenState();
}

class _UmkmScreenState extends State<UmkmScreen> {
  // (Data categories, products, controllers, dll. tidak berubah)
  final List<Map<String, dynamic>> categories = const [
    {'name': 'Semua', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Fashion', 'icon': Icons.checkroom_outlined},
    {'name': 'Makanan', 'icon': Icons.lunch_dining_outlined},
    {'name': 'Elektronik', 'icon': Icons.devices_other_outlined},
  ];

  final List<Map<String, dynamic>> products = const [
    {
      'image': 'assets/baju.webp',
      'title': 'Kaos Polos Unisex Katun Combed 30s',
      'subtitle': 'Kaos polos nyaman, bahan combed, cocok sehari-hari',
      'rating': 4.9,
      'sold': 1234,
      'price_final': 'Rp 149.000',
      'location': 'Jakarta Pusat',
      'category': 'Fashion',
    },
    {
      'image': 'assets/makanan.webp',
      'title': 'Kerupuk Kulit Sapi Premium',
      'subtitle': 'Kerupuk kulit renyah, rasa original',
      'rating': 4.7,
      'sold': 500,
      'price_final': 'Rp 35.000',
      'location': 'Indramayu',
      'category': 'Makanan',
    },
    // ... (data produk Anda yang lain) ...
  ];

  int _selectedCategoryIndex = 0;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _filteredProducts;

  // (initState, dispose, _filterProducts, _onCategorySelected,
  //  _onSearchTextChanged, _clearSearch, _navigateToOrderProcess tidak berubah)

  @override
  void initState() {
    super.initState();
    _filterProducts();
    _searchController.addListener(() {
      _onSearchTextChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final selectedCategoryName = categories[_selectedCategoryIndex]['name'];
    final lowerCaseSearchText = _searchText.toLowerCase();

    List<Map<String, dynamic>> categoryFiltered;
    if (selectedCategoryName == 'Semua') {
      categoryFiltered = products;
    } else {
      categoryFiltered = products
          .where((product) => product['category'] == selectedCategoryName)
          .toList();
    }

    _filteredProducts = categoryFiltered
        .where(
          (product) =>
              product['title'].toLowerCase().contains(lowerCaseSearchText) ||
              product['subtitle'].toLowerCase().contains(lowerCaseSearchText),
        )
        .toList();

    if (mounted) {
      setState(() {});
    }
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _filterProducts();
    });
  }

  void _onSearchTextChanged(String value) {
    if (_searchText != value) {
      _searchText = value;
      _filterProducts();
    }
  }

  void _clearSearch() {
    setState(() {
      _searchText = '';
      _searchController.clear();
      _filterProducts();
      FocusScope.of(context).unfocus();
    });
  }

  void _navigateToOrderProcess() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProsesOrderScreen()),
    );
  }

  // --- FUNGSI FAB MENU (SUDAH DIPERBARUI KE AUTHPROVIDER) ---
  void _showFabMenu() {
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
              // Opsi 1: Toko Saya (Logika sudah pakai AuthProvider.isUmkm)
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
                    );
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
              // Opsi 2: Pesanan Saya (Tidak berubah)
              ListTile(
                leading: Icon(
                  Icons.receipt_long_outlined,
                  color: theme.hintColor,
                ),
                title: const Text('Pesanan Saya'),
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

  // --- FUNGSI BUILD (DENGAN PERBAIKAN) ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- 1. PERBAIKAN: HAPUS VARIABEL 'isDarkMode' ---
    // final isDarkMode = theme.brightness == Brightness.dark; // <-- DIHAPUS

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 16.0 * 2;
    const crossAxisSpacing = 12.0;
    final itemWidth = (screenWidth - horizontalPadding - crossAxisSpacing) / 2;
    const heightMultiplier = 1.8;
    final childAspectRatio = itemWidth / (itemWidth * heightMultiplier);

    final bottomInset =
        MediaQuery.of(context).padding.bottom +
        MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // (AppBar tidak berubah)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Container(
            padding: const EdgeInsets.only(left: 0.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari produk UMKM...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
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
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: theme.colorScheme.onSurface,
        ),
      ),
      body: Stack(
        children: [
          // (Konten Utama tidak berubah)
          SafeArea(
            bottom: true,
            child: Column(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hasil Produk (${categories[_selectedCategoryIndex]['name']})',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_filteredProducts.length} produk',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _filteredProducts.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada produk ditemukan untuk kriteria ini.',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.only(
                              top: 0,
                              bottom: bottomInset + 80, // Beri ruang di bawah
                            ),
                            itemCount: _filteredProducts.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12.0,
                                  mainAxisSpacing: 12.0,
                                  childAspectRatio: childAspectRatio,
                                ),
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
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
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // --- 2. PERBAIKAN: FAB DIBUNGKUS SIZEDBOX ---
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: 16.0,
                bottom: (bottomInset == 0 ? 16.0 : bottomInset) + 16.0,
              ),
              // BUNGKUS DENGAN SizedBox untuk ukuran 55x55
              child: SizedBox(
                width: 55.0,
                height: 55.0,
                child: FloatingActionButton(
                  onPressed: _showFabMenu,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 6.0,
                  splashColor: theme.colorScheme.secondary.withOpacity(0.4),

                  // 'constraints' yang error sudah dihapus
                  tooltip: 'Menu Saya',
                  child: const Icon(Icons.apps_outlined, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Class ProductCard (Tidak ada perubahan) ---
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductCard({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color priceColor = theme.colorScheme.primary;

    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Hero(
                  tag:
                      product['title'] ??
                      product['image'] ??
                      'produk-${product.hashCode}',
                  child: Image.asset(
                    product['image'] ?? 'assets/placeholder.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Theme.of(context).hintColor.withOpacity(0.7),
                            size: 36,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: priceColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: priceColor.withOpacity(0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product['subtitle']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product['price_final']!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: priceColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        product['rating'].toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '|',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product['sold']} terjual',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: theme.hintColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product['location']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
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
