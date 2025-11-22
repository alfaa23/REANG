import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:reang_app/models/produk_model.dart';
import 'package:reang_app/models/produk_varian_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/cart_provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'package:intl/intl.dart';

class DetailProdukScreen extends StatefulWidget {
  // [PERBAIKAN] Terima ProdukModel, bukan Map
  final ProdukModel product;

  const DetailProdukScreen({required this.product, super.key});

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  final ApiService _apiService = ApiService();
  final PageController _pageController = PageController();

  // [PERBAIKAN] List ini akan menampung GABUNGAN foto utama + galeri
  List<String> _productImages = [];
  int _imageCarouselIndex = 0;

  List<ProdukModel> _similarProducts = [];
  bool _isLoadingSimilar = true;

  // Helper format mata uang
  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // Helper untuk mendapatkan rentang harga
  String _getPriceRange(List<ProdukVarianModel> varians) {
    if (varians.isEmpty) return "Rp 0";
    final prices = varians.map((v) => v.harga).toList();
    prices.sort();
    final minPrice = _formatCurrency(prices.first);
    final maxPrice = _formatCurrency(prices.last);
    if (minPrice == maxPrice) return minPrice;
    return "$minPrice - $maxPrice";
  }

  @override
  void initState() {
    super.initState();
    _setupProductImages(); // <-- [PERBAIKAN DI SINI]
    _fetchSimilarProducts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// [PERBAIKAN UTAMA]
  /// Mengatur galeri foto dari Foto Utama + Foto Galeri
  void _setupProductImages() {
    final List<String> images = [];

    // 1. Tambahkan Foto Utama (Cover)
    final String? mainImage = widget.product.foto;
    if (mainImage != null && mainImage.isNotEmpty) {
      images.add(mainImage);
    }

    // 2. Tambahkan semua Foto Galeri (dari model baru)
    if (widget.product.galeriFoto.isNotEmpty) {
      for (var galeriItem in widget.product.galeriFoto) {
        images.add(galeriItem.pathFoto);
      }
    }

    // 3. Jika tidak ada foto sama sekali, gunakan placeholder
    if (images.isEmpty) {
      images.add('assets/placeholder.png'); // Fallback
    }

    // 4. Set state
    _productImages = images;
  }

  /// Mengambil "Produk Serupa"
  void _fetchSimilarProducts() async {
    setState(() => _isLoadingSimilar = true);
    try {
      final String category = widget.product.fitur ?? 'Lainnya';
      final int currentId = widget.product.id;

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

  /// Helper untuk toast error (Sesuai preferensi Anda)
  void _showToast(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    showToast(
      message,
      context: context,
      position: StyledToastPosition.bottom,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      animDuration: const Duration(milliseconds: 150),
      duration: const Duration(seconds: 2),
      borderRadius: BorderRadius.circular(25),
      textStyle: const TextStyle(color: Colors.white),
      curve: Curves.fastOutSlowIn,
      backgroundColor: isError
          ? theme.colorScheme.error
          : Colors.black.withOpacity(0.8),
    );
  }

  // Helper yang dibutuhkan oleh _buildSimilarProductList
  Map<String, dynamic> _mapProdukModelToCardData(ProdukModel produk) {
    String baseUrl = "https://zara-gruffiest-silas.ngrok-free.dev"; // Sesuaikan
    String? fotoUrl = produk.foto;

    if (fotoUrl != null && !fotoUrl.startsWith('http')) {
      if (fotoUrl.startsWith('storage/')) {
        fotoUrl = '$baseUrl/$fotoUrl';
      } else {
        fotoUrl = '$baseUrl/storage/$fotoUrl';
      }
    }

    String priceDisplay;
    int totalStok = 0;

    if (produk.varians.isEmpty) {
      priceDisplay = "Rp 0";
      totalStok = 0;
    } else {
      final prices = produk.varians.map((v) => v.harga).toList();
      prices.sort();
      totalStok = produk.varians.fold(0, (sum, v) => sum + v.stok);

      if (prices.first == prices.last) {
        priceDisplay = _formatCurrency(prices.first);
      } else {
        priceDisplay =
            "${_formatCurrency(prices.first)} - ${_formatCurrency(prices.last)}";
      }
    }

    return {
      'id': produk.id,
      'id_toko': produk.idToko,
      'image': fotoUrl,
      'title': produk.nama,
      'subtitle': produk.deskripsi ?? produk.nama,
      'rating': 4.5,
      'sold_text': '$totalStok Stok',
      'price_final': priceDisplay,
      'location': produk.lokasi ?? 'Indramayu',
      'category': produk.fitur ?? 'Lainnya',
      'stock': totalStok,
      'description': produk.deskripsi,
      'specifications': produk.spesifikasi,
      'varians': produk.varians.map((v) => v.toJson()).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.product; // data sekarang adalah ProdukModel

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
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
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
            // [LOGIKA DI SINI OTOMATIS BERFUNGSI]
            _buildImageCarousel(theme),
            // [LOGIKA DI SINI OTOMATIS BERFUNGSI]
            if (_productImages.length > 1)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: _buildDotIndicator(theme),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.nama,
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
                        '4.5 (Stok: ${data.stok})', // Menggunakan getter stok total
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getPriceRange(data.varians),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerColor, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDescriptionSection(
                theme,
                data.deskripsi ?? 'Deskripsi produk tidak tersedia.',
              ),
            ),
            Divider(color: theme.dividerColor, thickness: 8),
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

  Widget _buildImageCarousel(ThemeData theme) {
    return Hero(
      tag: 'produk-${widget.product.id}',
      child: SizedBox(
        height: 300,
        child: PageView.builder(
          // [PERBAIKAN] Logika geser/tidak berdasarkan list yang sudah digabung
          physics: _productImages.length > 1
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          controller: _pageController,
          itemCount: _productImages.length, // <-- Otomatis menghitung 1 + 3 = 4
          itemBuilder: (context, index) {
            return _buildProductImage(
              _productImages[index], // <-- Ambil dari list gabungan
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

  Widget _buildDotIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // [PERBAIKAN] Otomatis membuat 4 titik jika total foto 4
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

  Widget _buildProductImage(
    String? imageUrl,
    BuildContext context, {
    double? height,
  }) {
    final theme = Theme.of(context);
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.startsWith('assets/')) {
      return Image.asset(
        'assets/placeholder.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: height ?? double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorImage(theme, height),
      );
    }
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

  /// [PERBAIKAN TOTAL] Modal ini sudah menggunakan Varian
  void _showOptionsModal(BuildContext context, {required bool isBuyNow}) {
    final theme = Theme.of(context);
    final ProdukModel data = widget.product;
    int modalQuantity = 1;

    ProdukVarianModel? modalSelectedVarian;
    final List<ProdukVarianModel> availableVarians = data.varians;

    // Jika hanya ada 1 varian, otomatis pilih varian itu
    if (availableVarians.length == 1) {
      modalSelectedVarian = availableVarians.first;
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
            // --- Helper Internal Modal ---
            void _incrementModalQuantity() {
              final int stok =
                  modalSelectedVarian?.stok ??
                  data.stok; // Fallback ke stok utama (getter)
              if (stok == 0) {
                _showToast("Pilih varian yang masih tersedia", isError: true);
                return;
              }
              if (modalQuantity < stok) {
                setModalState(() => modalQuantity++);
              } else {
                _showToast("Jumlah melebihi stok (Stok: $stok)", isError: true);
              }
            }

            void _decrementModalQuantity() {
              if (modalQuantity > 1) {
                setModalState(() => modalQuantity--);
              }
            }

            void _selectModalVarian(ProdukVarianModel varian) {
              setModalState(() {
                modalSelectedVarian = varian;
                // Reset kuantitas jika stok varian baru < kuantitas saat ini
                if (modalQuantity > varian.stok) {
                  modalQuantity = (varian.stok > 0) ? 1 : 0;
                }
                if (modalQuantity == 0 && varian.stok > 0) {
                  modalQuantity = 1;
                }
              });
            }

            // --- Aksi Konfirmasi ---
            void _confirmAction() async {
              // 1. Validasi Varian
              if (availableVarians.isNotEmpty && modalSelectedVarian == null) {
                _showToast(
                  "Silakan pilih varian terlebih dahulu",
                  isError: true,
                );
                return;
              }

              // 2. Validasi Stok
              // Jika tidak ada varian (produk tunggal), gunakan stok getter
              final selectedStok = modalSelectedVarian?.stok ?? data.stok;
              if (selectedStok < modalQuantity || modalQuantity == 0) {
                _showToast("Stok tidak mencukupi", isError: true);
                return;
              }

              final cartProvider = Provider.of<CartProvider>(
                this.context,
                listen: false,
              );
              final authProvider = Provider.of<AuthProvider>(
                this.context,
                listen: false,
              );

              if (authProvider.token == null || authProvider.user == null) {
                _showToast(
                  "Anda harus login untuk melanjutkan.",
                  isError: true,
                );
                return;
              }

              // [PERBAIKAN] Siapkan data Map untuk Beli Langsung & Keranjang
              final Map<String, dynamic> itemToSend = {
                'id': data.id,
                'id_toko': data.idToko,
                'nama_toko': data.namaToko,
                'title': data.nama,
                'image': data.foto,
                'location': data.lokasi,

                // Untuk tampilan UI (misalnya harga dengan format "Rp 50.000")
                'price_final': _formatCurrency(
                  modalSelectedVarian?.harga ?? data.harga,
                ),

                // [PERBAIKAN 1] Harga dalam bentuk integer asli (untuk API Beli Langsung)
                'harga': modalSelectedVarian?.harga ?? data.harga,

                // Stok real–wajib mengikuti varian jika ada
                'stock': modalSelectedVarian?.stok ?? data.stok,

                // Nama variasi (String)
                'variasi': modalSelectedVarian?.namaVarian ?? data.variasi,

                // [PERBAIKAN 2] ID varian untuk backend (wajib saat beli langsung)
                'id_varian': modalSelectedVarian?.id,

                // Deskripsi & spesifikasi untuk detail produk
                'description': data.deskripsi,
                'specifications': data.spesifikasi,
              };

              if (isBuyNow) {
                // --- SKENARIO B: BELI LANGSUNG ---
                if (mounted) Navigator.pop(ctx);
                Navigator.push(
                  this.context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      directBuyItem: itemToSend,
                      directBuyQty: modalQuantity,
                      directBuyNamaToko: data.namaToko ?? "Toko Penjual",
                    ),
                  ),
                );
              } else {
                // --- SKENARIO A: TAMBAH KE KERANJANG ---
                try {
                  await cartProvider.addToCart(
                    product: itemToSend,
                    quantity: modalQuantity,
                    selectedSize:
                        modalSelectedVarian?.namaVarian ?? data.variasi,
                    idVarian:
                        modalSelectedVarian!.id!, // <-- Mengirim ID Varian
                  );

                  if (mounted) Navigator.pop(ctx);
                  _showToast("Produk ditambahkan ke keranjang!");
                  cartProvider.fetchCart();
                } catch (e) {
                  _showToast(
                    e.toString().replaceAll('Exception: ', ''),
                    isError: true,
                  );
                }
              }
            }
            // --- Selesai Aksi Konfirmasi ---

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  // [PERBAIKAN] Tambahkan padding.bottom agar naik di iPhone X / Android Full Screen
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).padding.bottom +
                      16.0,
                ),
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
                            widget.product.foto,
                            context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatCurrency(
                                  modalSelectedVarian?.harga ?? data.harga,
                                ),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stok: ${modalSelectedVarian?.stok ?? data.stok}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (availableVarians.isNotEmpty) ...[
                              Text(
                                'Ukuran / Variasi',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8.0,
                                children: availableVarians.map((varian) {
                                  return _buildVarianChip(
                                    varian,
                                    isSelected:
                                        modalSelectedVarian?.id == varian.id,
                                    onSelect: _selectModalVarian,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                            Text('Jumlah', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            _buildQuantityControl(
                              theme: theme,
                              quantity: modalQuantity,
                              onDecrement: _decrementModalQuantity,
                              onIncrement: _incrementModalQuantity,
                            ),
                            const SizedBox(height: 20),
                            _buildSpecificationsSection(
                              theme,
                              (data.spesifikasi ?? '')
                                  .split(',')
                                  .where((s) => s.trim().isNotEmpty)
                                  .toList(),
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

  Widget _buildVarianChip(
    ProdukVarianModel varian, {
    required bool isSelected,
    required Function(ProdukVarianModel) onSelect,
  }) {
    final theme = Theme.of(context);
    final bool isStokHabis = varian.stok == 0;

    return ChoiceChip(
      label: Text(varian.namaVarian),
      selected: isSelected,
      onSelected: isStokHabis
          ? null
          : (selected) {
              if (selected) {
                onSelect(varian);
              }
            },
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      labelStyle: TextStyle(
        color: isStokHabis
            ? theme.disabledColor
            : (isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface),
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

          // [PERBAIKAN] Panggil fungsi helper
          final item = _mapProdukModelToCardData(produk);

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _buildSimilarProductCard(
              theme,
              item,
              produk,
            ), // Kirim model asli
          );
        },
      ),
    );
  }

  Widget _buildSimilarProductCard(
    ThemeData theme,
    Map<String, dynamic> item,
    ProdukModel model,
  ) {
    return SizedBox(
      width: 140,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // [PERBAIKAN] Kirim model-nya, bukan map
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DetailProdukScreen(product: model),
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
                    Text(
                      item['title'] ?? 'Nama Produk',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['price_final'] ?? 'Rp 0',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
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
