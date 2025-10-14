import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

class DetailProdukScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailProdukScreen({required this.product, super.key});

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  // State untuk mengelola jumlah dan ukuran
  int _quantity = 1;
  String _selectedSize = 'M'; // Ukuran default yang terpilih

  // Data dummy untuk produk serupa
  final List<Map<String, dynamic>> similarProducts = const [
    {
      'title': 'Batik Modern',
      'subtitle': 'Kemeja Batik Modern',
      'price': 'Rp 89.000',
    },
    {
      'title': 'Batik Casual',
      'subtitle': 'Kemeja Batik Casual',
      'price': 'Rp 65.000',
    },
    {
      'title': 'Batik Formal',
      'subtitle': 'Kemeja Batik Formal',
      'price': 'Rp 125.000',
    },
    {
      'title': 'Batik Premium',
      'subtitle': 'Kemeja Batik Premium',
      'price': 'Rp 150.000',
    },
  ];

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _selectSize(String size) {
    setState(() {
      _selectedSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.product;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: _buildActionButtons(context, theme),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- 1. Gambar Produk (Placeholder) ---
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Hero(
                tag:
                    widget.product['title'] ??
                    widget.product['image'] ??
                    'produk-${widget.product.hashCode}',
                child: Image.asset(
                  widget.product['image'] ?? 'assets/placeholder.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image,
                        size: 72,
                        color: theme.hintColor.withOpacity(0.5),
                      ),
                    );
                  },
                ),
              ),
            ),

            // --- 2. Detail Harga & Nama Produk ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['subtitle'] ?? 'Nama Produk',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${data['rating'] ?? '0.0'} (${data['sold'] ?? '0'}+ terjual)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        data['price_final'] ?? 'Rp 0',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data['price_original'] ?? 'Rp 0',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.hintColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (data['discount_percent'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${data['discount_percent']}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerColor, thickness: 1),

            // --- 3. Ukuran, Jumlah, dan Stok ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ukuran', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 35,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSizeChip('S', isSelected: _selectedSize == 'S'),
                        _buildSizeChip('M', isSelected: _selectedSize == 'M'),
                        _buildSizeChip('L', isSelected: _selectedSize == 'L'),
                        _buildSizeChip('XL', isSelected: _selectedSize == 'XL'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuantityControl(),
                      Text(
                        'Stok: ${data['stock'] ?? '0'} pcs',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: theme.dividerColor, thickness: 1),

            // --- 4. Deskripsi dan Spesifikasi ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDescriptionSection(
                    theme,
                    data['description'] ?? 'Deskripsi produk tidak tersedia.',
                  ),
                  const SizedBox(height: 24),
                  _buildSpecificationsSection(
                    theme,
                    data['specifications'] as List<String>? ?? [],
                  ),
                ],
              ),
            ),

            Divider(color: theme.dividerColor, thickness: 8),

            // --- 5. Produk Serupa ---
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                bottom: 8.0,
              ),
              child: Text(
                'Produk Serupa',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: similarProducts.length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _buildSimilarProductCard(
                      theme,
                      similarProducts[index],
                    ),
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

  // --- Widget Pembantu Lainnya ---

  Widget _buildSizeChip(String label, {bool isSelected = false}) {
    final theme = Theme.of(context);
    // --- PERBAIKAN: Menentukan warna teks dan ceklis secara eksplisit berdasarkan tema ---
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color selectedContentColor = isDarkMode ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _selectSize(label);
          }
        },
        selectedColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        checkmarkColor:
            selectedContentColor, // Gunakan warna yang sudah ditentukan
        labelStyle: TextStyle(
          color: isSelected
              ? selectedContentColor // Gunakan warna yang sudah ditentukan
              : theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.transparent : theme.dividerColor,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControl() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: _decrementQuantity,
            color: theme.hintColor,
          ),
          Text(_quantity.toString(), style: theme.textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: _incrementQuantity,
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi Produk',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection(
    ThemeData theme,
    List<String> specifications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spesifikasi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...specifications.map(
          (spec) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '• $spec',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.hintColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProductCard(ThemeData theme, Map<String, dynamic> item) {
    return SizedBox(
      width: 140,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Navigasi ke detail produk serupa
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: Icon(Icons.image, size: 40, color: Colors.grey.shade400),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['subtitle']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['price']!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              showToast(
                "Produk ditambahkan ke keranjang!",
                context: context,

                // 'gravity' diubah menjadi 'position'
                position: StyledToastPosition.bottom,

                // 'toastLength' diubah menjadi 'duration'
                duration: const Duration(seconds: 2), // Durasi untuk SHORT
                // backgroundColor tetap sama
                backgroundColor: Colors.black.withOpacity(0.7),

                // 'textColor' dan 'fontSize' digabung ke dalam 'textStyle'
                textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),

                // Opsional: Tambahan untuk tampilan yang lebih bagus
                borderRadius: BorderRadius.circular(8.0),
                textPadding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 10.0,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Tambah ke Keranjang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Beli Sekarang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
