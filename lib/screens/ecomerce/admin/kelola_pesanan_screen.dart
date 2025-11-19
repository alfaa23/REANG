import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/models/admin_pesanan_model.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

// Import halaman detail
import 'detail_pesanan_admin_screen.dart';

// =============================================================================
// 1. PARENT WIDGET: Mengelola Badge, Chip, dan PageView
// =============================================================================
class KelolaPesananScreen extends StatefulWidget {
  const KelolaPesananScreen({super.key});

  @override
  State<KelolaPesananScreen> createState() => _KelolaPesananScreenState();
}

class _KelolaPesananScreenState extends State<KelolaPesananScreen> {
  final ApiService _apiService = ApiService();
  late AuthProvider _authProvider;

  // Controller untuk geser halaman (Ganti TabController manual)
  final PageController _pageController = PageController();
  int _selectedIndex = 0; // Untuk menandai Chip mana yang aktif

  // State untuk Badge (Counts)
  Map<String, int> _counts = {};
  // bool _isLoadingCounts = true; // Tidak dipakai di UI, jadi opsional

  final List<String> _statusFilters = const [
    'Perlu Dikonfirmasi',
    'Siap Dikemas',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  // Mapping untuk API
  final List<String> _apiStatusKeys = const [
    'menunggu_konfirmasi',
    'diproses',
    'dikirim',
    'selesai',
    'dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _fetchBadgeCounts();
  }

  // Ambil badge saja (Ringan)
  Future<void> _fetchBadgeCounts() async {
    if (!_authProvider.isLoggedIn || _authProvider.user?.idToko == null) return;

    try {
      final data = await _apiService.fetchOrderCounts(
        token: _authProvider.token!,
        idToko: _authProvider.user!.idToko!,
      );
      if (mounted) {
        setState(() {
          _counts = data;
        });
      }
    } catch (e) {
      debugPrint("Gagal load badge: $e");
    }
  }

  // Refresh badge dan halaman aktif
  void _globalRefresh() {
    _fetchBadgeCounts();
    setState(() {}); // Trigger rebuild untuk update badge di chip
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'Perlu Dikonfirmasi':
        return Icons.hourglass_top_outlined;
      case 'Siap Dikemas':
        return Icons.inventory_2_outlined;
      case 'Dikirim':
        return Icons.local_shipping_outlined;
      case 'Selesai':
        return Icons.check_circle_outline;
      case 'Dibatalkan':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Judul (Padding sama persis dengan code lama)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            'Kelola Pesanan Masuk',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 2. Chip Filters (Scrollable Horizontal)
        // Menggunakan SizedBox height agar pas dengan ukuran chip
        SizedBox(
          height: 40, // Tinggi standar chip + padding
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ), // Padding kiri kanan sama
            scrollDirection: Axis.horizontal,
            itemCount: _statusFilters.length,
            separatorBuilder: (ctx, index) =>
                const SizedBox(width: 8), // Jarak antar chip
            itemBuilder: (context, index) {
              final status = _statusFilters[index];
              final apiStatus = _apiStatusKeys[index];

              final bool isSelected = _selectedIndex == index;
              final int count = _counts[apiStatus] ?? 0;

              // Logika badge sama persis
              final bool showBadge =
                  (status == 'Perlu Dikonfirmasi' ||
                      status == 'Siap Dikemas' ||
                      status == 'Dikirim') &&
                  count > 0;

              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForStatus(status),
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(status),

                    if (showBadge) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onError,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedIndex = index);
                    _pageController.jumpToPage(index); // Geser PageView
                  }
                },
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                selectedColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: isSelected
                      ? BorderSide.none
                      : BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                ),
                showCheckmark: false,
                elevation: 1,
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // 3. Konten List (PageView untuk Lazy Load)
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _statusFilters.length,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            itemBuilder: (context, index) {
              // Panggil Widget Anak Per-Tab
              return OrderListTab(
                apiStatus: _apiStatusKeys[index],
                onUpdate: _globalRefresh, // Callback refresh
              );
            },
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 2. CHILD WIDGET: List Pesanan Per Tab (Lazy Load)
// =============================================================================
class OrderListTab extends StatefulWidget {
  final String apiStatus;
  final VoidCallback onUpdate;

  const OrderListTab({
    super.key,
    required this.apiStatus,
    required this.onUpdate,
  });

  @override
  State<OrderListTab> createState() => _OrderListTabState();
}

class _OrderListTabState extends State<OrderListTab>
    with AutomaticKeepAliveClientMixin {
  // Agar tab tidak reload saat digeser

  late Future<List<AdminPesananModel>> _futurePesanan;
  final ApiService _apiService = ApiService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData(); // Hanya dipanggil saat tab dibuka pertama kali (Lazy)
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn && auth.user?.idToko != null) {
      _futurePesanan = _apiService.fetchAdminPesanan(
        token: auth.token!,
        idToko: auth.user!.idToko!,
        status: widget.apiStatus, // Filter spesifik tab
      );
    } else {
      _futurePesanan = Future.error("Data toko tidak ditemukan");
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
    widget.onUpdate(); // Update badge di parent
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return FutureBuilder<List<AdminPesananModel>>(
      future: _futurePesanan,
      builder: (context, snapshot) {
        // 1. Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // 2. Error
        if (snapshot.hasError) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: _buildErrorState(theme, snapshot.error.toString()),
              ),
            ),
          );
        }

        final list = snapshot.data ?? [];

        // 3. Kosong
        if (list.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: theme.hintColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada pesanan di status ini.',
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // 4. Ada Data
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            // Padding sama persis dengan code lama
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
            itemCount: list.length,
            itemBuilder: (ctx, index) {
              return _PesananAdminCard(
                pesanan: list[index],
                onActionSuccess: _refresh,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Pesanan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceAll("Exception: ", ""),
              style: TextStyle(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 3. KARTU PESANAN (SAMA PERSIS SEPERTI CODE LAMA)
// =============================================================================
class _PesananAdminCard extends StatelessWidget {
  final AdminPesananModel pesanan;
  final VoidCallback onActionSuccess;

  const _PesananAdminCard({
    required this.pesanan,
    required this.onActionSuccess,
  });

  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

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
      backgroundColor: isError ? theme.colorScheme.error : Colors.green,
      textStyle: TextStyle(color: theme.colorScheme.onError),
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      animDuration: const Duration(milliseconds: 150),
      duration: const Duration(seconds: 2),
      borderRadius: BorderRadius.circular(25),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _goToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPesananAdminScreen(
          noTransaksi: pesanan.noTransaksi,
          onActionSuccess: onActionSuccess,
        ),
      ),
    );
  }

  void _showSelesaiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 50,
        ),
        title: const Text(
          'Hati-hati!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Apakah Anda yakin barang SUDAH SAMPAI di tangan pembeli?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tindakan ini akan menyelesaikan pesanan secara otomatis dan tidak dapat dibatalkan lagi.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              try {
                final api = ApiService();
                final token = context.read<AuthProvider>().token!;

                final response = await api.adminTandaiSelesai(
                  token: token,
                  noTransaksi: pesanan.noTransaksi,
                );

                if (!context.mounted) return;

                _showToast(context, response['message'] ?? 'Pesanan selesai!');
                onActionSuccess();
              } catch (e) {
                if (!context.mounted) return;
                _showToast(
                  context,
                  e.toString().replaceAll("Exception: ", ""),
                  isError: true,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Saya Yakin'),
          ),
        ],
      ),
    );
  }

  Widget _buildAksiButton(BuildContext context, String status) {
    final theme = Theme.of(context);

    switch (status) {
      case 'menunggu_konfirmasi':
        return ElevatedButton.icon(
          onPressed: () => _goToDetail(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Cek Pembayaran'),
        );
      case 'diproses':
        return ElevatedButton.icon(
          onPressed: () => _goToDetail(context),
          icon: const Icon(Icons.local_shipping_outlined, size: 18),
          label: const Text('Proses Kirim'),
        );
      case 'dikirim':
        return OutlinedButton(
          onPressed: () => _showSelesaiDialog(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green.shade700,
            side: BorderSide(color: Colors.green.shade700),
          ),
          child: const Text('Tandai Selesai'),
        );
      default:
        return OutGarisButton(
          onPressed: () => _goToDetail(context),
          child: const Text('Lihat Detail'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _goToDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pesanan.namaPemesan,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat(
                      'dd MMM, HH:mm',
                      'id_ID',
                    ).format(pesanan.createdAt.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
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
                      pesanan.fotoProduk ?? "",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: theme.colorScheme.surfaceContainer,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pesanan.noTransaksi,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pesanan.namaProdukUtama,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pesanan.jumlah} Item',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Pesanan:', style: theme.textTheme.bodySmall),
                      Text(
                        _formatCurrency(pesanan.total),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  _buildAksiButton(context, pesanan.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OutGarisButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  const OutGarisButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: child);
  }
}
