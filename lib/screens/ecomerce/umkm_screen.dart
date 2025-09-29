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

  // Data Dummy untuk Produk
  final List<Map<String, dynamic>> products = const [
    {
      'image': 'assets/placeholder.png',
      'title': 'iPhone 15 Pro Max',
      'subtitle': 'Garansi Resmi 256GB - Warna Natural Titanium',
      'rating': 4.9,
      'sold': 1234,
      'price_final': 'Rp 18.999.000',
      'location': 'Jakarta Pusat',
    },
    {
      'image': 'assets/placeholder.png',
      'title': 'Galaxy S24 Ultra',
      'subtitle':
          'Samsung Galaxy S24 Ultra 5G AI Smartphone Garansi Resmi SEIN',
      'rating': 4.8,
      'sold': 856,
      'price_final': 'Rp 16.999.000',
      'location': 'Surabaya',
    },
    {
      'image': 'assets/placeholder.png',
      'title': 'MacBook Air M3',
      'subtitle': 'Chip Apple M3 13 inch 8/256GB',
      'rating': 4.9,
      'sold': 432,
      'price_final': 'Rp 15.999.000',
      'location': 'Bandung',
    },
    {
      'image': 'assets/placeholder.png',
      'title': 'Kemeja Pria Lengan Panjang',
      'subtitle': 'Kemeja Kantor Polos Bahan Katun Premium',
      'rating': 4.6,
      'sold': 2341,
      'price_final': 'Rp 149.000',
      'location': 'Yogyakarta',
    },
  ];

  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      body: SingleChildScrollView(
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
                      // --- PERBAIKAN: Menghilangkan ikon centang ---
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  // --- PERBAIKAN: Aspect ratio diubah agar kartu lebih panjang ---
                  childAspectRatio: 0.62,
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// WIDGET KARTU PRODUK (SUDAH DIPERBARUI)
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
                aspectRatio: 1, // Membuat gambar menjadi persegi
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme
                        .colorScheme
                        .surfaceContainer, // Warna latar belakang yang lebih jelas
                    boxShadow: [
                      // Menambahkan shadow halus di dalam kartu
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
                  // Jika sudah ada URL gambar, ganti dengan Image.network
                  // child: Image.network(
                  //   product['image']!,
                  //   fit: BoxFit.cover,
                  // ),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Distribusi ruang
                children: [
                  // Judul Produk
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
