import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/models/admin_pesanan_model.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart'; // <-- Tambahkan ini

// Ganti import dialog dengan halaman detail
import 'detail_pesanan_admin_screen.dart';
// Import dialog untuk input resi

class KelolaPesananScreen extends StatefulWidget {
  const KelolaPesananScreen({super.key});

  @override
  State<KelolaPesananScreen> createState() => _KelolaPesananScreenState();
}

class _KelolaPesananScreenState extends State<KelolaPesananScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<AdminPesananModel>> _pesananFuture;
  late AuthProvider _authProvider;

  String _selectedStatus = 'Perlu Dikonfirmasi';

  final List<String> _statusFilters = const [
    'Perlu Dikonfirmasi',
    'Siap Dikemas',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _pesananFuture = _fetchData();
  }

  Future<List<AdminPesananModel>> _fetchData() {
    if (!_authProvider.isLoggedIn || _authProvider.user?.idToko == null) {
      throw Exception('ID Toko Anda tidak ditemukan di data login.');
    }
    return _apiService.fetchAdminPesanan(
      token: _authProvider.token!,
      idToko: _authProvider.user!.idToko!,
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _pesananFuture = _fetchData();
    });
  }

  // --- Fungsi Helper untuk Filter dan Badge ---
  // (Fungsi-fungsi ini tidak berubah)
  Map<String, int> _getStatusCounts(List<AdminPesananModel> pesanan) {
    final counts = {
      'Perlu Dikonfirmasi': 0,
      'Siap Dikemas': 0,
      'Dikirim': 0,
      'Selesai': 0,
      'Dibatalkan': 0,
    };
    for (var p in pesanan) {
      final tab = p.getTabKategori;
      if (counts.containsKey(tab)) {
        counts[tab] = counts[tab]! + 1;
      }
    }
    return counts;
  }

  List<AdminPesananModel> _filterPesanan(
    List<AdminPesananModel> pesanan,
    String status,
  ) {
    return pesanan.where((p) => p.getTabKategori == status).toList();
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
  // --- Akhir Fungsi Helper ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<AdminPesananModel>>(
      future: _pesananFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorState(theme, snapshot.error.toString());
        }

        final allPesanan = snapshot.data ?? [];
        final filteredList = _filterPesanan(allPesanan, _selectedStatus);
        final statusCounts = _getStatusCounts(allPesanan);

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Kelola Pesanan Masuk',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildChipFilters(theme, statusCounts),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildPesananList(context, theme, filteredList),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChipFilters(ThemeData theme, Map<String, int> counts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: _statusFilters.map((status) {
          final bool isSelected = _selectedStatus == status;
          final count = counts[status] ?? 0;

          // [PERBAIKAN DI SINI]
          // Saya tambahkan "|| status == 'Dikirim'"
          final bool showBadge =
              (status == 'Perlu Dikonfirmasi' ||
                  status == 'Siap Dikemas' ||
                  status == 'Dikirim') &&
              count > 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
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

                  // Ini logika untuk memunculkan badge angka
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
                  setState(() {
                    _selectedStatus = status;
                  });
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
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPesananList(
    BuildContext context,
    ThemeData theme,
    List<AdminPesananModel> pesananList,
  ) {
    if (pesananList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64.0),
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
      );
    }

    return ListView.builder(
      itemCount: pesananList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _PesananAdminCard(
          pesanan: pesananList[index],
          onActionSuccess: _refreshData, // <-- Kirim fungsi refresh
        );
      },
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    // ... (Tidak ada perubahan di sini)
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: theme.colorScheme.error,
              ),
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
      ),
    );
  }
}

// ==========================================================
// KARTU PESANAN KHUSUS ADMIN (DI SINI PERUBAHANNYA)
// ==========================================================
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

  // --- [BARU] Fungsi Toast Helper ---
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

  // --- [BARU] Fungsi Konfirmasi Selesai ---
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
              // Gunakan 'onSurface' agar otomatis Hitam/Putih sesuai tema
              foregroundColor: Theme.of(context).colorScheme.onSurface,

              // Garis pinggir juga menyesuaikan tema (tidak terlalu pudar)
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
              Navigator.pop(ctx); // Tutup Dialog

              try {
                final api = ApiService();
                // Ambil token dari context card
                final token = context.read<AuthProvider>().token!;

                // Panggil API
                final response = await api.adminTandaiSelesai(
                  token: token,
                  noTransaksi: pesanan.noTransaksi, // <-- Pakai pesanan.
                );

                if (!context.mounted) return;

                // Gunakan _showToast helper yang ada di _PesananAdminCard
                _showToast(context, response['message'] ?? 'Pesanan selesai!');
                onActionSuccess(); // <-- Pakai onActionSuccess langsung
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

  // --- [BARU] Fungsi Navigasi ke Halaman Detail ---
  void _goToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPesananAdminScreen(
          noTransaksi: pesanan.noTransaksi,
          onActionSuccess: onActionSuccess, // Kirim callback refresh
        ),
      ),
    );
  }

  // --- [PERBAIKAN] Logika Tombol Aksi ---
  Widget _buildAksiButton(BuildContext context, String status) {
    final theme = Theme.of(context);

    switch (status) {
      case 'menunggu_konfirmasi':
        return ElevatedButton.icon(
          onPressed: () => _goToDetail(context), // <-- Buka Halaman Detail
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Cek Pembayaran'),
        );
      case 'diproses':
        return ElevatedButton.icon(
          onPressed: () => _goToDetail(context), // <-- Buka Dialog Resi
          icon: const Icon(Icons.local_shipping_outlined, size: 18),
          label: const Text('Proses Kirim'),
        );
      case 'dikirim':
        return OutlinedButton(
          onPressed: () =>
              _showSelesaiDialog(context), // <-- Buka Dialog Selesai
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green.shade700,
            side: BorderSide(color: Colors.green.shade700),
          ),
          child: const Text('Tandai Selesai'),
        );
      default:
        // Status 'selesai' atau 'dibatalkan'
        return OutGarisButton(
          // Menggunakan widget custom Anda
          onPressed: () => _goToDetail(context), // <-- Buka Halaman Detail
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
        // <-- [BONUS] Buat seluruh kartu bisa diklik
        onTap: () => _goToDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Header: Info Pemesan
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

              // Body: Info Produk
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

              // Footer: Total & Aksi
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

// Widget custom Anda (pastikan ini ada)
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
