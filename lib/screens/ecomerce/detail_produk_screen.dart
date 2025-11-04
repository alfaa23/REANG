import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:reang_app/models/produk_model.dart';
import 'package:reang_app/services/api_service.dart';

// Package carousel & dots SUDAH DIHAPUS
import 'cart_screen.dart';
import 'checkout_screen.dart';

class DetailProdukScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailProdukScreen({required this.product, super.key});

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  final ApiService _apiService = ApiService();
  final PageController _pageController = PageController();

  List<String> _productImages = [];
  int _imageCarouselIndex = 0;

  List<ProdukModel> _similarProducts = [];
  bool _isLoadingSimilar = true;

  @override
  void initState() {
    super.initState();
    _setupProductImages();
    _fetchSimilarProducts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// [PERBAIKAN 2] Mengatur galeri foto dari DATA ASLI
  void _setupProductImages() {
    final String? mainImage = widget.product['image'];

    // --- LOGIKA BARU ---
    // API Anda (ProdukModel) saat ini hanya memiliki SATU string 'foto'.
    // Jadi, kita hanya akan menambahkannya.
    if (mainImage != null && mainImage.isNotEmpty) {
      _productImages = [mainImage];
    } else {
      // Jika tidak ada foto, gunakan placeholder
      _productImages = ['assets/placeholder.png'];
    }

    // CATATAN:
    // Jika nanti API Anda di 'ProdukModel' memiliki field baru
    // bernama 'List<String> gallery', Anda akan mengisi _productImages
    // dari field tersebut.
  }

  /// Mengambil "Produk Serupa" (Tidak Berubah)
  void _fetchSimilarProducts() async {
    setState(() {
      _isLoadingSimilar = true;
    });
    try {
      final String category = widget.product['category'] ?? 'baju';
      final int currentId = widget.product['id'] ?? 0;
      final response = await _apiService.fetchProdukPaginated(
        page: 1,
        fitur: category,
      );
      final filtered = response.data.where((p) => p.id != currentId).toList();
      setState(() {
        _similarProducts = filtered;
        _isLoadingSimilar = false;
      });
    } catch (e) {
      debugPrint("Gagal fetch produk serupa: $e");
      setState(() {
        _isLoadingSimilar = false;
        _similarProducts = [];
      });
    }
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
            // --- 1. Gambar Produk (PageView) ---
            // Logika ini sekarang akan otomatis tidak bisa digeser
            // jika _productImages.length == 1
            _buildImageCarousel(theme),

            // --- 2. Indikator 'Titik-Titik' (Manual) ---
            // Logika ini sekarang akan otomatis Sembunyi
            // jika _productImages.length == 1
            if (_productImages.length > 1)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: _buildDotIndicator(theme),
                ),
              ),

            // --- 3. Detail Harga & Nama Produk ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- [PERBAIKAN BUG] ---
                  // Menggunakan 'title' (Nama) BUKAN 'subtitle' (Deskripsi)
                  Text(
                    data['title'] ?? 'Nama Produk', // <-- SUDAH DIPERBAIKI
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
                  Text(
                    data['price_final'] ?? 'Rp 0',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: theme.dividerColor, thickness: 1),

            // --- 4. Deskripsi (Akan Muncul Sekarang) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDescriptionSection(
                theme,
                // [PERBAIKAN 1] data['description'] sekarang ada
                data['description'] ?? 'Deskripsi produk tidak tersedia.',
              ),
            ),

            Divider(color: theme.dividerColor, thickness: 8),

            // --- 5. Produk Serupa (Dinamis) ---
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

            _isLoadingSimilar
                ? const Center(child: CircularProgressIndicator())
                : _buildSimilarProductList(theme),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // --- WIDGET HELPER ---
  // =========================================================================

  /// Widget untuk Galeri Foto (PageView)
  Widget _buildImageCarousel(ThemeData theme) {
    return Hero(
      tag: widget.product['title'] ?? 'produk-${widget.product.hashCode}',
      child: SizedBox(
        height: 300,
        child: PageView.builder(
          controller: _pageController,
          // [PERBAIKAN 2] itemCount sekarang akan jadi 1
          itemCount: _productImages.length,
          itemBuilder: (context, index) {
            return _buildProductImage(
              _productImages[index],
              context,
              height: 300,
            );
          },
          onPageChanged: (index) {
            setState(() {
              _imageCarouselIndex = index;
            });
          },
        ),
      ),
    );
  }

  /// Widget untuk Indikator 'Titik-Titik' (Manual)
  Widget _buildDotIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_productImages.length, (index) {
        bool isActive = _imageCarouselIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8,
          width: isActive ? 16 : 8,
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primary : theme.dividerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  /// Helper untuk menampilkan foto (network-aware)
  Widget _buildProductImage(
    String? imageUrl,
    BuildContext context, {
    double? height,
  }) {
    final theme = Theme.of(context);
    // [PERBAIKAN 2]
    // Kita cek apakah imageUrl adalah asset (placeholder) atau URL network
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.startsWith('assets/')) {
      return Image.asset(
        'assets/placeholder.png', // Fallback
        fit: BoxFit.cover,
        width: double.infinity,
        height: height ?? double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorImage(theme, height),
      );
    }

    // Jika bukan, berarti itu URL network
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height ?? double.infinity,
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
      errorBuilder: (context, error, stackTrace) =>
          _buildErrorImage(theme, height),
    );
  }

  /// Helper untuk placeholder error gambar
  Widget _buildErrorImage(ThemeData theme, double? height) {
    return Container(
      width: double.infinity,
      height: height ?? double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image,
        size: 72,
        color: theme.hintColor.withOpacity(0.5),
      ),
    );
  }

  /// Widget untuk tombol di Bottom Bar
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showOptionsModal(context, isBuyNow: false),
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
            onPressed: () => _showOptionsModal(context, isBuyNow: true),
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

  /// Fungsi utama untuk menampilkan Modal Bottom Sheet
  void _showOptionsModal(BuildContext context, {required bool isBuyNow}) {
    final theme = Theme.of(context);
    final data = widget.product;
    int modalQuantity = 1;
    String? modalSelectedSize;

    // [PERBAIKAN 1] data['variasi'] sekarang ada
    // Kita pecah string 'variasi' (misal: "S,M,L") menjadi List
    final List<String> availableSizes =
        (data['variasi'] as String?)
            ?.split(',')
            .where((s) => s.trim().isNotEmpty) // Hapus spasi kosong
            .toList() ??
        []; // Default ke list kosong jika null

    // Jika hanya ada 1 variasi, langsung pilih itu
    if (availableSizes.length == 1) {
      modalSelectedSize = availableSizes.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            void _incrementModalQuantity() {
              final int stok = data['stock'] ?? 0;
              if (modalQuantity < stok) {
                setModalState(() {
                  modalQuantity++;
                });
              }
            }

            void _decrementModalQuantity() {
              if (modalQuantity > 1) {
                setModalState(() {
                  modalQuantity--;
                });
              }
            }

            void _selectModalSize(String size) {
              setModalState(() {
                modalSelectedSize = size;
              });
            }

            void _confirmAction() {
              // Validasi: Cek apakah ukuran sudah dipilih
              // (Hanya jika ada > 0 pilihan ukuran)
              if (availableSizes.isNotEmpty && modalSelectedSize == null) {
                showToast(
                  "Silakan pilih variasi/ukuran terlebih dahulu",
                  context: context,
                  backgroundColor: theme.colorScheme.error,
                  textStyle: TextStyle(color: theme.colorScheme.onError),
                  position: StyledToastPosition.top,
                );
                return;
              }
              Navigator.pop(context);
              if (isBuyNow) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(),
                  ),
                );
              } else {
                showToast(
                  "Produk ditambahkan ke keranjang!",
                  context: context,
                  backgroundColor: Colors.black.withOpacity(0.7),
                  position: StyledToastPosition.bottom,
                  animation: StyledToastAnimation.scale,
                  duration: const Duration(seconds: 2),
                  borderRadius: BorderRadius.circular(25),
                  textStyle: const TextStyle(color: Colors.white),
                );
              }
            }

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildProductImage(
                            widget.product['image'],
                            context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['price_final'] ?? 'Rp 0',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stok: ${data['stock'] ?? '0'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // [PERBAIKAN 1] Tampilkan Ukuran/Variasi HANYA jika ada
                            if (availableSizes.isNotEmpty) ...[
                              Text(
                                'Ukuran / Variasi',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8.0,
                                children: availableSizes.map((size) {
                                  return _buildSizeChip(
                                    size,
                                    isSelected: modalSelectedSize == size,
                                    onSelect: _selectModalSize,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Bagian Jumlah
                            Text('Jumlah', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            _buildQuantityControl(
                              theme: theme,
                              quantity: modalQuantity,
                              onDecrement: _decrementModalQuantity,
                              onIncrement: _incrementModalQuantity,
                            ),
                            const SizedBox(height: 20),

                            // [PERBAIKAN 1] Bagian Spesifikasi
                            _buildSpecificationsSection(
                              theme,
                              // data['specifications'] sekarang ada
                              (data['specifications'] as String?)
                                      ?.split(',')
                                      .where((s) => s.trim().isNotEmpty)
                                      .toList() ??
                                  [],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    ElevatedButton(
                      onPressed: _confirmAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isBuyNow ? 'Beli Sekarang' : 'Tambah ke Keranjang',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Widget helper lainnya ---

  Widget _buildSizeChip(
    String label, {
    required bool isSelected,
    required Function(String) onSelect,
  }) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color selectedContentColor = isDarkMode ? Colors.black : Colors.white;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSelect(label);
        }
      },
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      checkmarkColor: selectedContentColor,
      labelStyle: TextStyle(
        color: isSelected ? selectedContentColor : theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.transparent : theme.dividerColor,
        ),
      ),
    );
  }

  Widget _buildQuantityControl({
    required ThemeData theme,
    required int quantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
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
            onPressed: onDecrement,
            color: theme.hintColor,
          ),
          Text(quantity.toString(), style: theme.textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: onIncrement,
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsSection(
    ThemeData theme,
    List<String> specifications,
  ) {
    if (specifications.isEmpty) return Container();
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

  Widget _buildSimilarProductList(ThemeData theme) {
    if (_similarProducts.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Text(
          'Tidak ada produk serupa.',
          style: TextStyle(color: theme.hintColor),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _similarProducts.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final produk = _similarProducts[index];
          // [PERBAIKAN BUG]
          // Kita harus MENGIRIM SEMUA DATA PENTING
          // ke 'item' agar navigasi rekursif berfungsi
          final item = {
            'id': produk.id,
            'title': produk.nama,
            'subtitle': produk.deskripsi ?? produk.nama,
            'price_final': 'Rp ${produk.harga}',
            'image': (produk.foto != null && !produk.foto!.startsWith('http'))
                ? 'https://92021ca9d48a.ngrok-free.app/storage/${produk.foto}'
                : produk.foto,
            'category': produk.fitur ?? 'Lainnya',
            'stock': produk.stok,
            'rating': 4.5,
            'sold': produk.stok,
            'description': produk.deskripsi,
            'specifications': produk.spesifikasi,
            'variasi': produk.variasi,
          };

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _buildSimilarProductCard(theme, item),
          );
        },
      ),
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
            // Ganti halaman (pushReplacement) agar tidak menumpuk
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DetailProdukScreen(product: item),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: _buildProductImage(item['image'], context),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // [PERBAIKAN BUG]
                    // Card produk serupa harusnya menampilkan NAMA ('title')
                    Text(
                      item['title'] ?? 'Nama Produk',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // --- [PERBAIKAN 2: BUG UTAMA] ---
                    // Mengganti 'price' menjadi 'price_final'
                    Text(
                      item['price_final'] ?? 'Rp 0', // <-- DULU 'price'
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
}
