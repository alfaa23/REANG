import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'detail_produk_screen.dart';

// Import untuk halaman dummy
// import 'proses_order_screen.dart';

// =============================================================================
// WIDGET BARU: DRAGGABLE FLOATING ACTION BUTTON
// =============================================================================
class DraggableFab extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  // Nilai awal posisi (akan disesuaikan di build agar default di kanan bawah)
  final double initialX;
  final double initialY;

  const DraggableFab({
    super.key,
    required this.child,
    required this.onPressed,
    this.initialX = 0.0,
    this.initialY = 0.0,
  });

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  // Posisi saat ini
  late double top;
  late double left;

  @override
  void initState() {
    super.initState();
    // Inisialisasi awal. Posisi sesungguhnya dihitung di build.
    top = widget.initialY;
    left = widget.initialX;
  }

  @override
  Widget build(BuildContext context) {
    // Ambil ukuran layar dan padding
    final screenSize = MediaQuery.of(context).size;
    final appBarHeight = 60.0; // Sesuai dengan PreferredSize di UmkmScreen
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Hitung posisi default (kanan bawah, di atas bottom padding)
    if (top == widget.initialY && left == widget.initialX) {
      // Mengasumsikan lebar FAB minimal 56x56
      final fabSize = 56.0;
      final padding = 16.0;

      // Posisi default: Kanan bawah (16px dari kanan & bawah aman)
      left = screenSize.width - fabSize - padding;
      top =
          screenSize.height -
          fabSize -
          padding * 4; // Beri ruang lebih dari bawah (misalnya 4x padding)
    }

    return Positioned(
      top: top,
      left: left,
      child: Draggable(
        // Opacity saat FAB sedang digeser
        feedback: Opacity(opacity: 0.7, child: widget.child),
        // Widget pengganti di posisi awal saat sedang digeser
        childWhenDragging: const SizedBox(width: 56, height: 56),

        onDragEnd: (details) {
          double newTop = details.offset.dy;
          double newLeft = details.offset.dx;

          // Batas aman
          final minLeft = 10.0;
          final maxLeft =
              screenSize.width - 66.0; // Lebar FAB + sedikit padding
          final minTop =
              statusBarHeight + appBarHeight + 10.0; // Di bawah App Bar
          final maxTop =
              screenSize.height -
              76.0; // 76.0 = Tinggi FAB + Bottom Inset + Margin

          setState(() {
            // Batasi posisi agar tidak keluar dari layar
            left = newLeft.clamp(minLeft, maxLeft);
            top = newTop.clamp(minTop, maxTop);
          });
        },
        // Widget yang benar-benar ditampilkan dan dapat berinteraksi (tapped/dragged)
        child: GestureDetector(onTap: widget.onPressed, child: widget.child),
      ),
    );
  }
}

// =============================================================================
// WIDGET UTAMA: UMKMSCREEN (Modifikasi FAB)
// =============================================================================
class UmkmScreen extends StatefulWidget {
  const UmkmScreen({super.key});

  @override
  State<UmkmScreen> createState() => _UmkmScreenState();
}

class _UmkmScreenState extends State<UmkmScreen> {
  // ... (Data Dummy dan Logika Filter tetap sama) ...
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
      'image': 'assets/baju.webp',
      'title': 'Kemeja Batik Slimfit Modern',
      'subtitle': 'Kemeja batik slimfit, bahan adem, cocok acara formal',
      'rating': 4.9,
      'sold': 432,
      'price_final': 'Rp 199.000',
      'location': 'Bandung',
      'category': 'Fashion',
    },
    {
      'image': 'assets/baju.webp',
      'title': 'Kemeja Pria Lengan Panjang',
      'subtitle': 'Kemeja kantor polos, bahan katun premium',
      'rating': 4.6,
      'sold': 2341,
      'price_final': 'Rp 179.000',
      'location': 'Yogyakarta',
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
    // Navigasi ke halaman proses order atau keranjang
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CartScreen(), // Ganti dengan ProsesOrderScreen() jika sudah ada
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Hitung childAspectRatio dinamis (tetap sama)
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

      // AppBar tetap sama
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

      // HAPUS floatingActionButton DARI SCAFOLD
      // floatingActionButton: null,

      // GANTI BODY menjadi STACK untuk menempatkan DraggableFab
      body: Stack(
        children: [
          // 1. Konten Utama (Kategori & Grid Produk)
          SafeArea(
            bottom: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // --- Bagian Kategori (Horizontal Chips) ---
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

                // --- Bagian Header Produk ---
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

                // --- Grid Produk (Product Card) ---
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
                            // Tambahkan bottom padding yang lebih besar agar tidak tertutup FAB
                            padding: EdgeInsets.only(
                              top: 0,
                              bottom: bottomInset + 80,
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
              ],
            ),
          ),

          // 2. Draggable Floating Action Button
          DraggableFab(
            onPressed: _navigateToOrderProcess,
            // Tombol FAB Minimalis
            child: FloatingActionButton(
              onPressed: _navigateToOrderProcess,
              heroTag: 'minimalOrderFab', // Penting untuk DraggableFab
              backgroundColor:
                  theme.colorScheme.primary, // Ganti warna agar lebih menonjol
              foregroundColor: theme.colorScheme.onPrimary,
              shape: const CircleBorder(),
              elevation: 8, // Sedikit lebih menonjol
              child: const Icon(Icons.receipt_long), // Ikon minimalis
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGET KARTU PRODUK (TETAP SAMA)
// =============================================================================
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
          // --- GAMBAR PRODUK DAN TOMBOL TAMBAH ---
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

              // tombol tambah tetap pakai Positioned seperti sebelumnya
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

          // --- DETAIL PRODUK ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Judul Produk (subtitle dipakai sebagai deskripsi singkat)
                  Text(
                    product['subtitle']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Harga
                  Text(
                    product['price_final']!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: priceColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  // Rating dan Terjual
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

                  // Lokasi
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
