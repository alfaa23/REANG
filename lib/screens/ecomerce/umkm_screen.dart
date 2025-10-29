import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'detail_produk_screen.dart';
import 'package:reang_app/screens/ecomerce/proses_order_screen.dart';
// import 'proses_order_screen.dart'; // Aktifkan jika sudah ada

class UmkmScreen extends StatefulWidget {
  const UmkmScreen({super.key});

  @override
  State<UmkmScreen> createState() => _UmkmScreenState();
}

class _UmkmScreenState extends State<UmkmScreen> {
  final List<Map<String, dynamic>> categories = const [
    {'name': 'Semua', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Fashion', 'icon': Icons.checkroom_outlined},
    {'name': 'Makanan', 'icon': Icons.lunch_dining_outlined},
    {'name': 'Elektronik', 'icon': Icons.devices_other_outlined},
  ];

  // Data produk dummy (Anda bisa ganti ini dengan data dari API nanti)
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
      'image': 'assets/baju.webp',
      'title': 'Hoodie Oversize Fleece Tebal',
      'subtitle': 'Hoodie nyaman dengan fleece tebal, cocok cuaca dingin',
      'rating': 4.8,
      'sold': 856,
      'price_final': 'Rp 249.000',
      'location': 'Surabaya',
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
    {
      'image': 'assets/elektronik.webp',
      'title': 'Power Bank 10000mAh Mini',
      'subtitle': 'Power bank ukuran saku, pengisian cepat',
      'rating': 4.5,
      'sold': 150,
      'price_final': 'Rp 99.000',
      'location': 'Jakarta Barat',
      'category': 'Elektronik',
    },
  ];

  int _selectedCategoryIndex = 0;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _filteredProducts;

  // --- Variabel untuk FAB yang bisa digeser DIHAPUS ---
  // Offset _fabPosition = const Offset(0, 0);
  // double _fabSize = 56.0;

  @override
  void initState() {
    super.initState();
    _filterProducts();
    _searchController.addListener(() {
      _onSearchTextChanged(_searchController.text);
    });
    // --- Logika untuk inisialisasi posisi FAB DIHAPUS ---
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
    // Arahkan ke halaman keranjang atau proses pesanan
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProsesOrderScreen()),
    );
  }

  // --- Fungsi _onPanUpdate untuk menggeser FAB DIHAPUS ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // --- TAMBAHAN: Deteksi mode tema ---
    final isDarkMode = theme.brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 16.0 * 2;
    const crossAxisSpacing = 12.0;
    final itemWidth = (screenWidth - horizontalPadding - crossAxisSpacing) / 2;
    const heightMultiplier = 1.8; // Sesuaikan ini untuk tinggi kartu
    final childAspectRatio = itemWidth / (itemWidth * heightMultiplier);

    // Variabel untuk padding bawah (menghindari navigasi sistem/keyboard)
    final bottomInset =
        MediaQuery.of(context).padding.bottom +
        MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
      // --- PERUBAHAN: Body diubah menjadi Stack ---
      body: Stack(
        children: [
          // Konten Utama (Daftar Kategori dan Produk)
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

          // --- PERUBAHAN UTAMA: Tombol Melayang Statis ---
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: 16.0,
                // Pastikan tombol ada di atas navigasi sistem/keyboard
                bottom: (bottomInset == 0 ? 16.0 : bottomInset) + 16.0,
              ),
              child: FloatingActionButton(
                onPressed: _navigateToOrderProcess,
                // Logika warna kontras
                backgroundColor: isDarkMode ? Colors.white : Colors.grey[850],
                foregroundColor: isDarkMode ? Colors.black87 : Colors.white,
                tooltip: 'Cek Pesanan Saya',
                child: const Icon(Icons.receipt_long_outlined), // Ikon pesanan
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
