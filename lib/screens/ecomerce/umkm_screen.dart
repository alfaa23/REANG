import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'detail_produk_screen.dart';

class UmkmScreen extends StatefulWidget {
  const UmkmScreen({super.key});

  @override
  State<UmkmScreen> createState() => _UmkmScreenState();
}

class _UmkmScreenState extends State<UmkmScreen> {
  // Data Dummy untuk Kategori
  final List<Map<String, dynamic>> categories = const [
    {'name': 'Semua', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Fashion', 'icon': Icons.checkroom_outlined},
    {'name': 'Makanan', 'icon': Icons.lunch_dining_outlined},
    {'name': 'Elektronik', 'icon': Icons.devices_other_outlined},
  ];

  // Data Dummy untuk Produk (contoh nama baju sudah dimasukkan)
  final List<Map<String, dynamic>> products = const [
    {
      'image': 'assets/placeholder.png',
      'title': 'Kaos Polos Unisex Katun Combed 30s',
      'subtitle': 'Kaos polos nyaman, bahan combed, cocok sehari-hari',
      'rating': 4.9,
      'sold': 1234,
      'price_final': 'Rp 149.000',
      'location': 'Jakarta Pusat',
    },
    {
      'image': 'assets/placeholder.png',
      'title': 'Hoodie Oversize Fleece Tebal',
      'subtitle': 'Hoodie nyaman dengan fleece tebal, cocok cuaca dingin',
      'rating': 4.8,
      'sold': 856,
      'price_final': 'Rp 249.000',
      'location': 'Surabaya',
    },
    {
      'image': 'assets/placeholder.png',
      'title': 'Kemeja Batik Slimfit Modern',
      'subtitle': 'Kemeja batik slimfit, bahan adem, cocok acara formal',
      'rating': 4.9,
      'sold': 432,
      'price_final': 'Rp 199.000',
      'location': 'Bandung',
    },
    {
      'image': 'assets/placeholder.png',
      'title': 'Kemeja Pria Lengan Panjang',
      'subtitle': 'Kemeja kantor polos, bahan katun premium',
      'rating': 4.6,
      'sold': 2341,
      'price_final': 'Rp 179.000',
      'location': 'Yogyakarta',
    },
  ];

  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Hitung childAspectRatio dinamis supaya tinggi kartu lebih besar/tetap stabil di semua layar
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 16.0 * 2; // padding kiri + kanan dari parent
    const crossAxisSpacing = 12.0; // jarak antar kolom
    final itemWidth = (screenWidth - horizontalPadding - crossAxisSpacing) / 2;
    // multiplier >1 => kartu lebih tinggi. 1.8 artinya tinggi = width * 1.8
    const heightMultiplier = 1.8;
    final childAspectRatio =
        itemWidth / (itemWidth * heightMultiplier); // ~0.555

    // bottom padding includes safe area + keyboard insets
    final bottomInset =
        MediaQuery.of(context).padding.bottom +
        MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'UMKM-IMYU',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      // SafeArea untuk menghindari area notch/gesture bar
      body: SafeArea(
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
                      // Menghilangkan ikon centang
                      showCheckmark: false,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategoryIndex = index;
                          }
                        });
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
                    'Produk Pilihan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${products.length} produk',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),

            // --- Grid Produk (Product Card) ---
            // Gunakan Expanded agar GridView dapat menggulir dan tidak memicu overflow
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  // beri padding bottom untuk menghindari gesture bar / tombol layar + keyboard
                  padding: EdgeInsets.only(top: 0, bottom: bottomInset + 16),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailProdukScreen(product: products[index]),
                          ),
                        );
                      },
                      child: ProductCard(product: products[index]),
                    );
                  },
                ),
              ),
            ),

            // Jeda bawah supaya tidak terlalu mepet
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// WIDGET KARTU PRODUK (DIPANJANGKAN TINGGI NYA)
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
                aspectRatio: 1, // gambar persegi
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      color: theme.hintColor.withOpacity(0.7),
                      size: 40,
                    ),
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

          // --- DETAIL PRODUK ---
          // Gunakan Expanded agar layout lebih stabil dan tidak overflow
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Distribusi ruang
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
