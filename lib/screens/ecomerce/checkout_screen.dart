import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/models/cart_item_model.dart';
import 'package:reang_app/models/OngkirModel.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:reang_app/providers/cart_provider.dart';

// Helper class untuk menyimpan state per toko
class _CheckoutTokoState {
  final int tokoId;
  final String namaToko;
  final List<CartItemModel> items;
  final TextEditingController noteController;

  List<OngkirModel> ongkirOptions = [];
  bool isLoadingOngkir = true;
  String? ongkirError;

  // [PERBAIKAN 1] Dibuat nullable, tidak ada nilai default
  OngkirModel? selectedOngkirOption;

  _CheckoutTokoState({
    required this.tokoId,
    required this.namaToko,
    required this.items,
  }) : noteController = TextEditingController();

  void dispose() {
    noteController.dispose();
  }

  double get subtotalToko {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // Getter dinamis (otomatis 0.0 jika selectedOngkirOption null)
  double get selectedOngkir => selectedOngkirOption?.harga ?? 0.0;
  String get selectedJasaPengiriman =>
      selectedOngkirOption?.daerah ?? "Belum dipilih";
}
// =========================================================================

class CheckoutScreen extends StatefulWidget {
  final Map<int, List<CartItemModel>>? itemsByToko;
  final Map<String, dynamic>? directBuyItem;
  final int? directBuyQty;

  const CheckoutScreen({
    super.key,
    this.itemsByToko,
    this.directBuyItem,
    this.directBuyQty,
  }) : assert(
         (itemsByToko != null && directBuyItem == null) ||
             (itemsByToko == null && directBuyItem != null),
         "Harus menyediakan 'itemsByToko' ATAU 'directBuyItem'",
       );

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Map<int, _CheckoutTokoState> _tokoStates;

  double _subtotalProduk = 0;
  double _subtotalOngkir = 0;
  double _biayaLayanan = 5000;
  double _totalPembayaran = 0;

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // --- [PERBAIKAN 3] State untuk UI Error ---
  bool _validationFailed = false;
  // --- [PERBAIKAN 3 SELESAI] ---

  @override
  void initState() {
    super.initState();
    _tokoStates = {};
    _buildDisplayItemsAndFetchOngkir();
    _calculateTotals();
  }

  @override
  void dispose() {
    _tokoStates.values.forEach((state) => state.dispose());
    super.dispose();
  }

  void _buildDisplayItemsAndFetchOngkir() {
    final String? token = context.read<AuthProvider>().token;
    if (token == null) {
      return;
    }

    if (widget.itemsByToko != null) {
      // Skenario A: Dari Keranjang
      widget.itemsByToko!.forEach((tokoId, items) {
        final state = _CheckoutTokoState(
          tokoId: tokoId,
          namaToko: items.first.namaToko,
          items: items,
        );
        _tokoStates[tokoId] = state;
        _fetchOngkirForToko(state, token);
      });
    } else {
      // Skenario B: Beli Langsung
      final itemMap = widget.directBuyItem!;
      final qty = widget.directBuyQty!;
      final int harga =
          (itemMap['price_final'] as String)
              .replaceAll(RegExp(r'[Rp. ]'), '')
              .isNotEmpty
          ? int.tryParse(
                  itemMap['price_final'].replaceAll(RegExp(r'[Rp. ]'), ''),
                ) ??
                0
          : 0;

      final fakeCartItem = CartItemModel(
        id: 0,
        idToko: itemMap['id_toko'],
        idUser: 0,
        idProduk: itemMap['id'],
        harga: harga,
        stok: itemMap['stock'],
        jumlah: qty,
        subtotal: (harga * qty),
        namaProduk: itemMap['title'],
        foto: itemMap['image'],
        namaToko:
            "Nama Toko (dari API Produk)", // TODO: API Produk perlu kirim nama_toko
        lokasiToko: itemMap['location'],
        variasi: itemMap['variasi'],
      );

      final state = _CheckoutTokoState(
        tokoId: fakeCartItem.idToko,
        namaToko: fakeCartItem.namaToko,
        items: [fakeCartItem],
      );
      _tokoStates[fakeCartItem.idToko] = state;
      _fetchOngkirForToko(state, token);
    }
  }

  /// [PERBAIKAN 1] Fungsi untuk memanggil API ongkir per toko
  Future<void> _fetchOngkirForToko(
    _CheckoutTokoState tokoState,
    String token,
  ) async {
    try {
      final options = await _apiService.getOngkirOptions(
        token: token,
        idToko: tokoState.tokoId,
      );

      if (mounted) {
        setState(() {
          tokoState.ongkirOptions = options;
          tokoState.isLoadingOngkir = false;

          // --- [PERBAIKAN 1] HAPUS AUTO-SELECT ---
          // if (options.isNotEmpty) {
          //   tokoState.selectedOngkirOption = options.first;
          //   _calculateTotals(); // Hitung ulang total
          // }
          // --- [PERBAIKAN 1 SELESAI] ---
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          tokoState.ongkirError = e.toString().replaceAll('Exception: ', '');
          tokoState.isLoadingOngkir = false;
        });
      }
    }
  }

  /// Helper untuk menghitung total harga
  void _calculateTotals() {
    double newSubtotalProduk = 0;
    double newSubtotalOngkir = 0;

    _tokoStates.values.forEach((toko) {
      newSubtotalProduk += toko.subtotalToko;
      newSubtotalOngkir += toko.selectedOngkir;
    });

    setState(() {
      _subtotalProduk = newSubtotalProduk;
      _subtotalOngkir = newSubtotalOngkir;
      _totalPembayaran = _subtotalProduk + _subtotalOngkir + _biayaLayanan;
    });
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  /// [PERBAIKAN 2] Fungsi "Bayar Sekarang" dengan Validasi
  Future<void> _handlePayment() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null || auth.user == null) {
      _showErrorToast("Anda harus login untuk melanjutkan.", Theme.of(context));
      return;
    }

    // --- [PERBAIKAN 2] VALIDASI ONGKIR ---
    bool allOngkirSelected = true;
    _tokoStates.forEach((tokoId, state) {
      // Cek: Apakah ongkir belum dipilih DAN ada opsi yang tersedia
      if (state.selectedOngkirOption == null &&
          state.ongkirOptions.isNotEmpty) {
        allOngkirSelected = false;
      }
    });

    if (!allOngkirSelected) {
      setState(() {
        _validationFailed = true; // <-- Aktifkan UI Merah
      });
      _showErrorToast(
        "Harap pilih ongkir untuk semua toko.",
        Theme.of(context),
      );
      return; // Stop
    }
    // --- [PERBAIKAN 2 SELESAI] ---

    setState(() {
      _isLoading = true;
      _validationFailed = false; // Reset error jika validasi lolos
    });

    // (Sisa logika tidak berubah)
    final String alamat = "Jl. Sudirman No. 123 (Dummy)";
    final String metodePembayaran = "Transfer Bank";

    try {
      List<Map<String, dynamic>>? pesananPerToko;
      Map<String, dynamic>? directItem;

      if (widget.itemsByToko != null) {
        pesananPerToko = [];
        _tokoStates.forEach((tokoId, state) {
          pesananPerToko!.add({
            "id_toko": tokoId,
            "item_ids": state.items.map((item) => item.id).toList(),
            "jasa_pengiriman": state.selectedJasaPengiriman,
            "ongkir": state.selectedOngkir,
            "catatan": state.noteController.text.isNotEmpty
                ? state.noteController.text
                : null,
          });
        });
      } else {
        final state = _tokoStates.values.first;
        final item = state.items.first;
        directItem = {
          'id_produk': item.idProduk,
          'id_toko': item.idToko,
          'jumlah': item.jumlah,
          'harga': item.harga,
          'jasa_pengiriman': state.selectedJasaPengiriman,
          'ongkir': state.selectedOngkir,
          'catatan': state.noteController.text.isNotEmpty
              ? state.noteController.text
              : null,
        };
      }

      final response = await _apiService.createOrder(
        token: auth.token!,
        userId: auth.user!.id,
        alamat: alamat,
        metodePembayaran: metodePembayaran,
        pesananPerToko: pesananPerToko,
        directItem: directItem,
      );

      setState(() {
        _isLoading = false;
      });
      final String noPembayaran = response['no_pembayaran'];

      showToast(
        "Checkout Berhasil! No Pembayaran: $noPembayaran",
        context: context,
        backgroundColor: Colors.green,
        position: StyledToastPosition.top,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        animDuration: const Duration(milliseconds: 150),
        duration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(25),
        textStyle: const TextStyle(color: Colors.white),
        curve: Curves.fastOutSlowIn,
      );

      if (widget.itemsByToko != null) {
        context.read<CartProvider>().fetchCart();
      }

      Navigator.pop(context); // Kembali dari Checkout
      if (widget.itemsByToko != null) {
        Navigator.pop(context); // Kembali dari Cart
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorToast(
        e.toString().replaceAll('Exception: ', ''),
        Theme.of(context),
      );
    }
  }

  void _showErrorToast(String message, ThemeData theme) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.top,
      backgroundColor: theme.colorScheme.error,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      animDuration: const Duration(milliseconds: 150),
      duration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(25),
      textStyle: const TextStyle(color: Colors.white),
      curve: Curves.fastOutSlowIn,
    );
  }

  /// [PERBAIKAN] Fungsi Modal Ongkir
  Future<void> _showOngkirModal(
    BuildContext context,
    _CheckoutTokoState tokoState,
  ) {
    final theme = Theme.of(context);

    // Simpan pilihan sementara di dalam modal
    OngkirModel? tempSelected = tokoState.selectedOngkirOption;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Pengiriman',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  Text(
                    'Untuk pesanan dari ${tokoState.namaToko}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const Divider(height: 24),

                  if (tokoState.isLoadingOngkir)
                    const Center(child: CircularProgressIndicator())
                  else if (tokoState.ongkirError != null)
                    Center(
                      child: Text(
                        tokoState.ongkirError!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    )
                  else if (tokoState.ongkirOptions.isEmpty)
                    const Center(
                      child: Text('Tidak ada opsi pengiriman untuk toko ini.'),
                    )
                  else
                    // Tampilkan Pilihan Ongkir
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tokoState.ongkirOptions.length,
                        itemBuilder: (listContext, index) {
                          final option = tokoState.ongkirOptions[index];
                          return RadioListTile<OngkirModel>(
                            title: Text(option.daerah),
                            subtitle: Text(_formatCurrency(option.harga)),
                            value: option,
                            groupValue: tempSelected,
                            onChanged: (OngkirModel? value) {
                              modalSetState(() {
                                tempSelected = value;
                              });
                              // [PERBAIKAN] Jangan langsung tutup,
                              // biarkan user lihat pilihannya
                            },
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  // [BARU] Tombol Konfirmasi Pilihan Ongkir
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      // Kirim data HANYA saat tombol ini ditekan
                      if (tempSelected != null) {
                        setState(() {
                          tokoState.selectedOngkirOption = tempSelected;
                          _calculateTotals(); // Hitung ulang total
                        });
                        Navigator.pop(modalContext);
                      } else {
                        // (Atau tampilkan error jika perlu)
                      }
                    },
                    child: const Text('Pilih'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double bottomBarHeight = 72.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: theme.cardColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Transaksi',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: bottomBarHeight),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AddressCard(theme: theme),
                    const SizedBox(height: 18),

                    ..._tokoStates.values.map((tokoState) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: StoreCard(
                          theme: theme,
                          tokoState: tokoState,
                          // [PERBAIKAN 3] Kirim state validasi
                          validationFailed: _validationFailed,
                          onOngkirPressed: () {
                            _showOngkirModal(context, tokoState);
                          },
                        ),
                      );
                    }).toList(),

                    CostBreakdownCard(
                      theme: theme,
                      subtotal: _subtotalProduk,
                      ongkir: _subtotalOngkir,
                      biayaLayanan: _biayaLayanan,
                      total: _totalPembayaran,
                      itemCount: _tokoStates.length,
                      formatCurrency: _formatCurrency,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildActionButtons(context, theme),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Container(
      color: theme.cardColor,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Total Pembayaran', style: theme.textTheme.bodyMedium),
                Text(
                  _formatCurrency(_totalPembayaran),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withOpacity(0.3),
              ),
              onPressed: _isLoading ? null : _handlePayment,
              child: Text(
                'Bayar Sekarang',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// --- WIDGET-WIDGET CARD (DIMODIFIKASI) ---
// =========================================================================

class AddressCard extends StatelessWidget {
  // ... (Tidak berubah) ...
  final ThemeData theme;
  const AddressCard({super.key, required this.theme});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Andi Pratama | +62 812-3456-7890',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jl. Sudirman No. 123, RT 05/RW 02, Kelurahan Menteng, Kecamatan Menteng, Jakarta Pusat, DKI Jakarta 10310',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- [PERBAIKAN 3] WIDGET KARTU TOKO ---
class StoreCard extends StatelessWidget {
  final ThemeData theme;
  final _CheckoutTokoState tokoState;
  final VoidCallback onOngkirPressed;
  final bool validationFailed; // <-- [BARU] Terima status error

  const StoreCard({
    super.key,
    required this.theme,
    required this.tokoState,
    required this.onOngkirPressed,
    required this.validationFailed, // <-- [BARU]
  });

  @override
  Widget build(BuildContext context) {
    // Cek apakah HARUS error
    final bool hasError =
        validationFailed &&
        tokoState.selectedOngkirOption == null &&
        tokoState.ongkirOptions.isNotEmpty;

    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storefront, color: theme.colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  tokoState.namaToko,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tokoState.items
                .map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ProductRow(theme: theme, product: product),
                  ),
                )
                .toList(),

            const Divider(height: 16),

            // --- [PERBAIKAN 3] Pilihan Ongkir ---
            Container(
              decoration: BoxDecoration(
                border: hasError
                    ? Border.all(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ) // <-- TAMPILAN MERAH
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  'Pilihan Pengiriman',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    // Ubah warna teks jika error
                    color: hasError ? theme.colorScheme.error : null,
                  ),
                ),
                subtitle: Text(
                  tokoState.isLoadingOngkir
                      ? 'Memuat opsi...'
                      : (tokoState.ongkirError != null
                            ? 'Gagal memuat ongkir'
                            : tokoState
                                  .selectedJasaPengiriman), // "Belum dipilih"
                  style: TextStyle(
                    color: tokoState.ongkirError != null
                        ? theme.colorScheme.error
                        : theme.hintColor,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!tokoState.isLoadingOngkir &&
                        tokoState.ongkirError == null)
                      Text(
                        _formatCurrency(tokoState.selectedOngkir),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: hasError ? theme.colorScheme.error : null,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: hasError
                          ? theme.colorScheme.error
                          : theme.hintColor,
                    ),
                  ],
                ),
                onTap: tokoState.isLoadingOngkir ? null : onOngkirPressed,
              ),
            ),

            // --- [PERBAIKAN 3 SELESAI] ---
            const Divider(height: 16),

            // Catatan per Toko
            NoteCard(theme: theme, controller: tokoState.noteController),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }
}

// --- WIDGET SATU BARIS PRODUK ---
class ProductRow extends StatelessWidget {
  final ThemeData theme;
  final CartItemModel product;

  const ProductRow({super.key, required this.theme, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: (product.foto == null || product.foto!.isEmpty)
                ? Center(
                    child: Text(
                      'IMG',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  )
                : Image.network(product.foto!, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.namaProduk,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.variasi ?? 'Standar',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(product.harga),
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'x${product.jumlah}',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(product.subtotal),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET KARTU CATATAN ---
class NoteCard extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;

  const NoteCard({super.key, required this.theme, required this.controller});

  @override
  Widget build(BuildContext context) {
    // ... (Tidak berubah) ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catatan untuk Penjual',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Tinggalkan pesan... (Opsional)',
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}

// --- WIDGET KARTU RINCIAN BIAYA ---
class CostBreakdownCard extends StatelessWidget {
  final ThemeData theme;
  final double subtotal;
  final double ongkir;
  final double biayaLayanan;
  final double total;
  final int itemCount; // Ini sekarang adalah jumlah TOKO
  final String Function(double) formatCurrency;

  const CostBreakdownCard({
    super.key,
    required this.theme,
    required this.subtotal,
    required this.ongkir,
    required this.biayaLayanan,
    required this.total,
    required this.itemCount,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    // ... (Tidak berubah) ...
    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rincian Biaya',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _costRow(
              'Harga Produk (dari $itemCount toko)',
              formatCurrency(subtotal),
              theme,
            ),
            const SizedBox(height: 8),
            _costRow('Ongkos Kirim', formatCurrency(ongkir), theme),
            const SizedBox(height: 8),
            _costRow('Biaya Layanan', formatCurrency(biayaLayanan), theme),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  formatCurrency(total),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _costRow(String left, String right, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        ),
        Text(
          right,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
