import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pastikan import ini ada untuk Clipboard
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/models/detail_transaksi_response.dart';
import 'package:reang_app/models/riwayat_transaksi_model.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'dialog_input_resi.dart';
import 'package:reang_app/models/user_model.dart';

class DetailPesananAdminScreen extends StatefulWidget {
  final String noTransaksi;
  final VoidCallback onActionSuccess;

  const DetailPesananAdminScreen({
    super.key,
    required this.noTransaksi,
    required this.onActionSuccess,
  });

  @override
  State<DetailPesananAdminScreen> createState() =>
      _DetailPesananAdminScreenState();
}

class _DetailPesananAdminScreenState extends State<DetailPesananAdminScreen> {
  final ApiService _apiService = ApiService();
  late Future<DetailTransaksiResponse> _detailFuture;
  late String _token;
  late AuthProvider _authProvider;

  bool _isLoading = false;
  bool _isConfirming = false;
  bool _isRejecting = false;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _token = _authProvider.token ?? '';
    _loadDetails();
  }

  void _loadDetails() {
    _detailFuture = _apiService.fetchDetailTransaksi(
      token: _token,
      noTransaksi: widget.noTransaksi,
    );
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
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

  Future<void> _runApiAction(
    Future<dynamic> Function() apiCall,
    String successMessage,
    Function(bool) setLoading,
  ) {
    setLoading(true);

    return apiCall()
        .then((response) {
          _showToast(response['message'] ?? successMessage);
          Navigator.pop(context);
          widget.onActionSuccess();
        })
        .catchError((e) {
          _showToast(e.toString().replaceAll("Exception: ", ""), isError: true);
        })
        .whenComplete(() {
          if (mounted) {
            setLoading(false);
          }
        });
  }

  void _onConfirm() {
    _runApiAction(
      () => _apiService.adminKonfirmasiPembayaran(
        token: _token,
        noTransaksi: widget.noTransaksi,
      ),
      'Pembayaran dikonfirmasi!',
      (isLoading) => setState(() => _isConfirming = isLoading),
    );
  }

  void _onReject() {
    _runApiAction(
      () => _apiService.adminTolakPembayaran(
        token: _token,
        noTransaksi: widget.noTransaksi,
      ),
      'Pembayaran ditolak.',
      (isLoading) => setState(() => _isRejecting = isLoading),
    );
  }

  void _onKirim(String nomorResi) {
    _runApiAction(
      () => _apiService.adminKirimPesanan(
        token: _token,
        noTransaksi: widget.noTransaksi,
        nomorResi: nomorResi,
      ),
      'Pesanan ditandai terkirim!',
      (isLoading) => setState(() => _isLoading = isLoading),
    );
  }

  void _onSelesai() {
    _runApiAction(
      () => _apiService.adminTandaiSelesai(
        token: _token,
        noTransaksi: widget.noTransaksi,
      ),
      'Pesanan ditandai selesai!',
      (isLoading) => setState(() => _isLoading = isLoading),
    );
  }

  void _showInputResiDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DialogInputResi(
          onSubmit: (nomorResi) {
            Navigator.pop(ctx);
            _onKirim(nomorResi);
          },
        );
      },
    );
  }

  void _openImagePreview(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => _ImagePreviewScreen(imageUrl: imageUrl),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DetailTransaksiResponse>(
      future: _detailFuture,
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        Widget body;
        RiwayatTransaksiModel? transaksi;

        if (snapshot.connectionState == ConnectionState.waiting) {
          body = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          body = Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          transaksi = snapshot.data!.transaksi;
          final items = snapshot.data!.items;
          final String? buktiBayarUrl = transaksi.buktiPembayaran;

          body = SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(theme, transaksi, _authProvider.user),
                const SizedBox(height: 16),
                if (transaksi.status == 'menunggu_konfirmasi') ...[
                  _buildPaymentProofCard(theme, buktiBayarUrl, transaksi),
                  const SizedBox(height: 16),
                ],
                _buildProductListCard(theme, items),
                const SizedBox(height: 16),
                _buildCostCard(theme, transaksi),
              ],
            ),
          );
        } else {
          body = const Center(child: Text('Data tidak ditemukan.'));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Pesanan'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: (_isLoading || _isConfirming || _isRejecting)
                  ? const LinearProgressIndicator()
                  : Container(),
            ),
          ),
          body: body,
          bottomNavigationBar: transaksi != null
              ? _buildDynamicActionButtons(context, theme, transaksi)
              : null,
        );
      },
    );
  }

  // --- WIDGET BUILDER ---

  Widget _buildStatusCard(
    ThemeData theme,
    RiwayatTransaksiModel transaksi,
    UserModel? user,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Pesanan', style: theme.textTheme.titleSmall),
            Text(
              transaksi.getUiStatus,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(height: 24),
            Text('Info Pelanggan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _InfoRow(theme: theme, label: 'Nama', value: user?.name ?? '...'),
            _InfoRow(
              theme: theme,
              label: 'No. HP',
              value: user?.phone ?? '...',
            ),
            const SizedBox(height: 8),
            Text('Alamat Pengiriman:', style: theme.textTheme.bodySmall),

            // [PERBAIKAN ADA DI SINI]
            // Bungkus alamat dengan InkWell untuk aksi copy
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: transaksi.alamat));
                _showToast('Alamat pengiriman disalin');
              },
              borderRadius: BorderRadius.circular(4.0), // Untuk ripple effect
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        transaksi.alamat,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.copy_outlined, size: 16, color: theme.hintColor),
                  ],
                ),
              ),
            ),

            // [SELESAI PERBAIKAN]
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentProofCard(
    ThemeData theme,
    String? buktiBayarUrl,
    RiwayatTransaksiModel transaksi,
  ) {
    // (Tidak ada perubahan di sini)
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bukti Pembayaran Pelanggan",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                if (buktiBayarUrl != null &&
                    buktiBayarUrl.isNotEmpty &&
                    buktiBayarUrl != 'ditolak') {
                  _openImagePreview(context, buktiBayarUrl);
                } else {
                  _showToast(
                    'Tidak ada bukti pembayaran untuk dilihat.',
                    isError: true,
                  );
                }
              },
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child:
                    (buktiBayarUrl == null ||
                        buktiBayarUrl.isEmpty ||
                        buktiBayarUrl == 'ditolak')
                    ? Center(
                        child: Text(
                          'Bukti bayar tidak ditemukan.',
                          style: TextStyle(color: theme.hintColor),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              buktiBayarUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Text(
                                      'Gagal memuat gambar',
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              theme: theme,
              label: "Total Tagihan",
              value: _formatCurrency(transaksi.total),
              isTotal: true,
            ),
            const Divider(height: 20),
            _InfoRow(
              theme: theme,
              label: "Metode Tujuan",
              value: transaksi.metodePembayaran ?? '-',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              theme: theme,
              label: "A.n. Penerima",
              value: transaksi.namaPenerima ?? '-',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              theme: theme,
              label: "No. Rek/Tujuan",
              value: transaksi.nomorTujuan ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListCard(ThemeData theme, List<ItemDetailModel> items) {
    // (Tidak ada perubahan di sini)
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Produk (${items.length} item)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Column(
              children: items.map((item) {
                return _ProductDetailRow(
                  theme: theme,
                  item: item,
                  showDivider: item != items.last,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard(ThemeData theme, RiwayatTransaksiModel transaksi) {
    // (Tidak ada perubahan di sini)
    double biayaLayanan =
        transaksi.total - transaksi.subtotal - transaksi.ongkir;
    if (biayaLayanan < 0) biayaLayanan = 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rincian Biaya',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _InfoRow(
              theme: theme,
              label: 'Subtotal Produk',
              value: _formatCurrency(transaksi.subtotal),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              theme: theme,
              label: 'Ongkos Kirim',
              value: _formatCurrency(transaksi.ongkir),
            ),
            if (biayaLayanan > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _InfoRow(
                  theme: theme,
                  label: 'Biaya Layanan',
                  value: _formatCurrency(biayaLayanan),
                ),
              ),
            const Divider(height: 24, thickness: 1),
            _InfoRow(
              theme: theme,
              label: 'Total Pembayaran',
              value: _formatCurrency(transaksi.total),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildDynamicActionButtons(
    BuildContext context,
    ThemeData theme,
    RiwayatTransaksiModel transaksi,
  ) {
    // (Tidak ada perubahan di sini)
    bool isActionLoading = _isLoading || _isConfirming || _isRejecting;
    Widget content;

    switch (transaksi.status) {
      case 'menunggu_konfirmasi':
        content = Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isActionLoading ? null : _onReject,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isRejecting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.error,
                        ),
                      )
                    : const Text(
                        "Tolak",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isActionLoading ? null : _onConfirm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isConfirming
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Konfirmasi Pembayaran",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        );
        break;

      case 'diproses':
        content = ElevatedButton.icon(
          onPressed: isActionLoading ? null : _showInputResiDialog,
          icon: const Icon(Icons.local_shipping_outlined),
          label: const Text("Input Resi & Kirim Pesanan"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        break;

      case 'dikirim':
        content = ElevatedButton(
          onPressed: isActionLoading ? null : _onSelesai,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Tandai Pesanan Selesai"),
        );
        break;

      default:
        return null; // Tidak ada tombol
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom, // Safe area
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: content,
    );
  }
}

// ===============================================
// --- Widget Helper Internal (TIDAK BERUBAH) ---
// ===============================================

class _ProductDetailRow extends StatelessWidget {
  // (Tidak ada perubahan di sini)
  const _ProductDetailRow({
    required this.theme,
    required this.item,
    required this.showDivider,
  });

  final ThemeData theme;
  final ItemDetailModel item;
  final bool showDivider;

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.foto ?? "",
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 64,
                    height: 64,
                    color: theme.colorScheme.surfaceContainer,
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: theme.hintColor.withOpacity(0.7),
                      size: 30,
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
                    item.namaProduk,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.jumlah} item x ${_formatCurrency(item.harga)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatCurrency(item.subtotal),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (showDivider) const Divider(height: 24),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  // (Tidak ada perubahan di sini)
  const _InfoRow({
    required this.theme,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final ThemeData theme;
  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ),
        SizedBox(width: 16),
        Flexible(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ),
      ],
    );
  }
}

class _ImagePreviewScreen extends StatelessWidget {
  // (Tidak ada perubahan di sini)
  final String imageUrl;
  const _ImagePreviewScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text(
                    'Gagal memuat gambar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.black.withOpacity(0.5),
                shape: const CircleBorder(),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
