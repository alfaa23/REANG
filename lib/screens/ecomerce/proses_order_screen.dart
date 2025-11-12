import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/models/riwayat_transaksi_model.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:reang_app/screens/ecomerce/payment_instruction_screen.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:reang_app/screens/ecomerce/detail_order_screen.dart';

// [PERUBAHAN] ProsesOrderScreen kembali ke implementasi yang lebih sederhana.
class ProsesOrderScreen extends StatefulWidget {
  const ProsesOrderScreen({super.key});

  @override
  State<ProsesOrderScreen> createState() => _ProsesOrderScreenState();
}

class _ProsesOrderScreenState extends State<ProsesOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  final List<String> _tabs = const [
    'Belum Dibayar',
    'Dikemas',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  // [BARU] Kita hanya menyimpan daftar pesanan lengkap secara global
  List<RiwayatTransaksiModel> _allOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    // [PERUBAHAN] Kita memuat data awal di sini agar badge terisi
    _fetchAllOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // [BARU] Fungsi global untuk memuat semua data
  Future<List<RiwayatTransaksiModel>> _fetchAllOrders() async {
    // Gunakan FutureBuilder di OrderListTabView untuk menunjukkan loading/error
    // Tapi data tetap diambil di sini agar badge update
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn || auth.user == null || auth.token == null) {
      // Melemparkan pengecualian agar FutureBuilder di OrderListTabView menangkapnya
      throw Exception('Anda harus login untuk melihat pesanan.');
    }

    try {
      final List<RiwayatTransaksiModel> orders = await _apiService
          .fetchRiwayatTransaksi(token: auth.token!, userId: auth.user!.id);

      // Simpan di state global untuk update badge dan untuk diakses oleh OrderListTabView
      if (mounted) {
        setState(() {
          _allOrders = orders;
        });
      }
      return orders;
    } catch (e) {
      // Biarkan exception diteruskan ke FutureBuilder di OrderListTabView
      rethrow;
    }
  }

  // [BARU] Fungsi refresh global yang memicu pembaruan
  void _globalRefresh() {
    // Kita panggil API dan minta setiap tab untuk rebuild
    // Ini akan memperbarui _allOrders dan memicu rebuild TabBar
    _fetchAllOrders();
  }

  // Fungsi penghitung tab tetap sama, tapi sekarang menggunakan data global
  Map<String, int> _getTabCounts() {
    final counts = {
      'Belum Dibayar': 0,
      'Dikemas': 0,
      'Dikirim': 0,
      'Selesai': 0,
      'Dibatalkan': 0,
    };
    for (var order in _allOrders) {
      final tab = order.getTabKategori;
      if (counts.containsKey(tab)) {
        counts[tab] = counts[tab]! + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter hitungan dari data global
    final tabCounts = _getTabCounts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        actions: const [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: _tabController,
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant
                .withOpacity(0.7),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
            tabs: _tabs.map((tab) {
              final count = tabCounts[tab] ?? 0;
              final bool showBadge =
                  (tab == 'Belum Dibayar' ||
                      tab == 'Dikemas' ||
                      tab == 'Dikirim') &&
                  count > 0;

              return Tab(
                child: Row(
                  children: [
                    Text(tab),
                    if (showBadge)
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onError,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      // [PERUBAHAN UTAMA] Body: Cukup TabBarView tanpa FutureBuilder global
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          return OrderListTabView(
            key: ValueKey(tab), // Memberi key unik penting untuk tab
            tabCategory: tab,
            // Kirim future untuk memuat semua data
            ordersFuture: _fetchAllOrders,
            onRefresh: _globalRefresh,
            // Hapus parameter 'allOrders' yang statis
          );
        }).toList(),
      ),
    );
  }
}

// ===============================================
// --- [WIDGET BARU] Order List Tab View (Lazy Load Murni) ---
// (Tidak ada perubahan di sini)
// ===============================================
class OrderListTabView extends StatefulWidget {
  final String tabCategory;
  final Future<List<RiwayatTransaksiModel>> Function() ordersFuture;
  final VoidCallback onRefresh;

  const OrderListTabView({
    super.key,
    required this.tabCategory,
    required this.ordersFuture,
    required this.onRefresh,
  });

  @override
  State<OrderListTabView> createState() => _OrderListTabViewState();
}

class _OrderListTabViewState extends State<OrderListTabView>
    with AutomaticKeepAliveClientMixin {
  // [KUNCI 1] Tentukan Future hanya di tab ini
  late Future<List<RiwayatTransaksiModel>> _tabOrdersFuture;

  // [KUNCI 2] Ini yang menjaga tab di memori setelah dimuat
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // [KUNCI 3] Panggil Future dari Induk, tapi simpan di state anak.
    // Future ini akan dijalankan HANYA saat tab ini pertama kali di-build.
    _tabOrdersFuture = widget.ordersFuture();
  }

  // Fungsi filtering lokal
  List<RiwayatTransaksiModel> _filterOrders(
    List<RiwayatTransaksiModel> orders,
  ) {
    return orders
        .where((order) => order.getTabKategori == widget.tabCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Penting untuk AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);

    // [LOGIKA LAZY LOAD & PENGELOLAAN DATA] Gunakan FutureBuilder sebagai sumber data
    return FutureBuilder<List<RiwayatTransaksiModel>>(
      future: _tabOrdersFuture,
      builder: (context, snapshot) {
        // --- 1. Saat Loading ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Hanya tampilkan loading jika belum ada data, dan bukan saat refresh
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
        }

        // --- 2. Jika Gagal (Error) ---
        if (snapshot.hasError) {
          return _buildErrorState(context, theme, snapshot.error.toString());
        }

        // --- 3. Jika Berhasil (Punya Data) ---
        if (snapshot.hasData && snapshot.data != null) {
          List<RiwayatTransaksiModel> finalFilteredList = _filterOrders(
            snapshot.data!,
          );

          if (finalFilteredList.isEmpty) {
            return _buildEmptyState(
              context,
              "Tidak ada pesanan di status ini.",
            );
          }

          return _buildOrderList(context, finalFilteredList, theme);
        }

        // --- 4. Jika Data Kosong (Awal & tidak ada error) ---
        // Ini adalah fallback state, biasanya tidak tercapai jika loading ditangani
        return _buildEmptyState(context, "Tidak ada pesanan di status ini.");
      },
    );
  }

  // Widget untuk Daftar Pesanan
  Widget _buildOrderList(
    BuildContext context,
    List<RiwayatTransaksiModel> orders,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // [PERUBAHAN] Panggil ulang Future di tab ini saat Refresh
        setState(() {
          _tabOrdersFuture = widget.ordersFuture(); // Ambil data baru
        });
        widget
            .onRefresh(); // Panggil refresh global untuk update badge di parent
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderCard(
            order: orders[index],
            onPaymentSuccess: widget.onRefresh, // Menggunakan onRefresh global
          );
        },
      ),
    );
  }

  // Widget untuk Error State
  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    String errorMessage,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // [PERBAHAN] Panggil ulang Future di tab ini saat tarik untuk refresh
        setState(() {
          _tabOrdersFuture = widget.ordersFuture(); // Ambil data baru
        });
        widget.onRefresh(); // Refresh global untuk update badge
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight * 3,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage.replaceAll("Exception: ", ""),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Empty State
  Widget _buildEmptyState(BuildContext context, String message) {
    return RefreshIndicator(
      onRefresh: () async {
        // [PERUBAHAN] Panggil ulang Future di tab ini saat Refresh
        setState(() {
          _tabOrdersFuture = widget.ordersFuture();
        });
        widget.onRefresh(); // Refresh global untuk update badge
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight * 3,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Theme.of(context).hintColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===============================================
// --- Komponen Kartu Pesanan (OrderCard) ---
// (Perubahan ada di dalam sini)
// ===============================================

class OrderCard extends StatelessWidget {
  final RiwayatTransaksiModel order;
  final VoidCallback
  onPaymentSuccess; // Berganti nama menjadi onOrderActionSuccess

  const OrderCard({
    required this.order,
    required this.onPaymentSuccess,
    super.key,
  });

  // Helper untuk menampilkan StyledToast
  void _showToast(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
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

  void _goToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailOrderScreen(noTransaksi: order.noTransaksi),
      ),
    ).then((result) {
      // Jika DetailOrderScreen mengembalikan hasil 'true' (misal: setelah pembayaran berhasil),
      // panggil callback untuk refresh OrderListTabView (dan ProcessOrderScreen)
      if (result == true) {
        onPaymentSuccess();
      }
    });
  }

  void _goToPayment(BuildContext context) async {
    final apiService = ApiService();
    final auth = context.read<AuthProvider>();

    if (auth.token == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await apiService.fetchDetailTransaksi(
        token: auth.token!,
        noTransaksi: order.noTransaksi,
      );

      final Map<String, dynamic> paymentMap = response.transaksi.toJson();
      final List<Map<String, dynamic>> paymentData = [paymentMap];

      Navigator.pop(context); // Tutup loading

      // Tunggu hingga PaymentInstructionScreen selesai (pop)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentInstructionScreen(
            paymentData: paymentData,

            // --- [INI ADALAH PERUBAHANNYA] ---
            // Kita berikan fungsi 'onCustomClose' ke layar instruksi.
            // Saat tombol 'Back' di AppBar (atau swipe back)
            // di PaymentInstructionScreen ditekan, fungsi ini akan dijalankan.
            onCustomClose: () {
              Navigator.pop(context); // Cukup tutup layar instruksi
            },

            // --- [SELESAI PERUBAHAN] ---
          ),
        ),
      );

      // Panggil refresh setelah kembali dari instruksi pembayaran
      // untuk update status pesanan
      onPaymentSuccess();
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      _showToast(
        context,
        'Gagal memuat detail pembayaran: ${e.toString().replaceAll("Exception: ", "")}',
        isError: true,
      );
    }
  }

  // TODO: Buat fungsi _goToReview untuk Beri Ulasan
  void _goToReview(BuildContext context) {
    // Navigasi ke halaman ulasan (Rating Screen)
    _showToast(context, 'TODO: Buka halaman Beri Ulasan', isError: false);
    // Di sini Anda akan push ke ReviewScreen
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewScreen(order: order)));
    // Jika ulasan berhasil, panggil onPaymentSuccess() untuk refresh
  }

  // TODO: Buat fungsi _goToTracking untuk Lacak
  void _goToTracking(BuildContext context) {
    // Navigasi ke halaman lacak (Tracking Screen)
    _showToast(context, 'TODO: Buka halaman Lacak Pesanan', isError: false);
  }

  // TODO: Buat fungsi _goToChat untuk Hubungi Penjual
  void _goToChat(BuildContext context) {
    // Navigasi ke halaman chat
    _showToast(context, 'TODO: Buka halaman Chat Penjual', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    final Color onPrimaryColor = theme.colorScheme.onPrimary;

    final String uiStatus = order.getUiStatus;
    final String tabKategori = order.getTabKategori;
    final bool isUnpaid = tabKategori == 'Belum Dibayar';

    Color statusColor;
    switch (tabKategori) {
      case 'Selesai':
        statusColor = Colors.green;
        break;
      case 'Dibatalkan':
      case 'Belum Dibayar':
        statusColor = theme.colorScheme.error;
        break;
      default:
        statusColor = primaryColor;
    }

    // Tentukan aksi untuk tombol kedua
    VoidCallback? secondaryAction;
    String secondaryText = 'Hubungi Penjual';

    if (tabKategori == 'Selesai') {
      secondaryAction = () => _goToReview(context);
      secondaryText = 'Beri Ulasan';
    } else if (tabKategori == 'Dikirim') {
      secondaryAction = () => _goToTracking(context);
      secondaryText = 'Lacak';
    } else {
      // Dikemas, dll.
      secondaryAction = () => _goToChat(context);
      secondaryText = 'Hubungi Penjual';
    }

    return Card(
      elevation: 1,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.namaToko,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  uiStatus,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 0.5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.fotoProduk ?? "",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.surfaceContainer,
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: theme.hintColor.withOpacity(0.7),
                          size: 36,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.namaProdukUtama ?? 'Produk',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(order.total),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${order.jumlah} Item',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tanggal Pesanan:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                          'id_ID',
                        ).format(order.createdAt.toLocal()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (isUnpaid)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_outlined,
                            size: 14,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Batas Pembayaran:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(
                              order.createdAt.toLocal().add(
                                const Duration(days: 1),
                              ),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _goToDetail(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(color: theme.dividerColor),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Lihat Detail'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: isUnpaid
                      ? ElevatedButton(
                          onPressed: () => _goToPayment(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 1,
                          ),
                          child: const Text('Bayar Sekarang'),
                        )
                      : ElevatedButton(
                          onPressed:
                              secondaryAction, // Menggunakan aksi dinamis
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: onPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 1,
                          ),
                          child: Text(
                            secondaryText,
                          ), // Menggunakan teks dinamis
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
