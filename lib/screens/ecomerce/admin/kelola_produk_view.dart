// Lokasi: lib/screens/ecomerce/admin/kelola_produk_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:reang_app/models/produk_model.dart';
import 'package:reang_app/models/produk_varian_model.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';

import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'form_produk_screen.dart';

class KelolaProdukView extends StatefulWidget {
  const KelolaProdukView({super.key});

  @override
  State<KelolaProdukView> createState() => _KelolaProdukViewState();
}

class _KelolaProdukViewState extends State<KelolaProdukView> {
  final ApiService _apiService = ApiService();

  List<ProdukModel> _produkList = [];
  bool _isLoading = true;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    _fetchProdukSaya();
  }

  // ===========================================================
  // FETCH DATA
  // ===========================================================

  Future<void> _fetchProdukSaya() async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    if (auth.token == null || auth.user?.idToko == null) {
      setState(() {
        _isLoading = false;
        _apiError = "Tidak dapat memuat produk: ID Toko tidak ditemukan.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final List<ProdukModel> data = await _apiService.fetchProdukByToko(
        token: auth.token!,
        idToko: auth.user!.idToko!,
      );

      if (mounted) {
        setState(() {
          _produkList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _apiError = e.toString().replaceAll("Exception: ", "");
        });
      }
    }
  }

  // ===========================================================
  // UI HELPERS
  // ===========================================================

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
      backgroundColor: isError
          ? theme.colorScheme.error
          : Colors.black.withOpacity(0.8),
    );
  }

  // ===========================================================
  // NAVIGASI
  // ===========================================================

  void _goToAddProduk() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormProdukScreen(produk: null),
      ),
    ).then((result) {
      if (result == true) _fetchProdukSaya();
    });
  }

  void _editProduk(ProdukModel produk) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormProdukScreen(produk: produk)),
    ).then((result) {
      if (result == true) _fetchProdukSaya();
    });
  }

  // ===========================================================
  // HAPUS PRODUK
  // ===========================================================

  Future<void> _hapusProduk(int produkId, String namaProduk) async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;

    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: Text(
          "Anda yakin ingin menghapus '$namaProduk'? "
          "Aksi ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              "Ya, Hapus",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      final res = await _apiService.deleteProduk(
        token: auth.token!,
        produkId: produkId,
      );

      _showToast(res['message'] ?? "Produk berhasil dihapus");
      _fetchProdukSaya();
    } catch (e) {
      _showToast(e.toString().replaceAll("Exception: ", ""), isError: true);
    }
  }

  // ===========================================================
  // DATA FORMATTER
  // ===========================================================

  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String _getPriceRange(List<ProdukVarianModel> varians) {
    if (varians.isEmpty) return "Rp 0";

    final list = varians.map((v) => v.harga).toList()..sort();
    final minPrice = _formatCurrency(list.first);
    final maxPrice = _formatCurrency(list.last);

    return minPrice == maxPrice ? minPrice : "$minPrice - $maxPrice";
  }

  String _getTotalStok(List<ProdukVarianModel> varians) {
    if (varians.isEmpty) return "0";
    return varians.fold<int>(0, (sum, v) => sum + v.stok).toString();
  }

  // ===========================================================
  // UI COMPONENTS
  // ===========================================================

  Widget _buildStatItem(ThemeData theme, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool primary = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: primary
            ? ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 16),
                label: Text(text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              )
            : OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 16),
                label: Text(text),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
      ),
    );
  }

  // ===========================================================
  // BUILD UI
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddProduk,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),

      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _apiError != null
            ? Center(
                child: Text(
                  _apiError!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              )
            : _produkList.isEmpty
            ? Center(
                child: Text(
                  "Anda belum memiliki produk.",
                  style: TextStyle(color: theme.hintColor),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + 72 + bottomPad),
                itemCount: _produkList.length,
                itemBuilder: (context, i) {
                  final produk = _produkList[i];

                  return Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto
                        Image.network(
                          produk.foto ?? "",
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 180,
                            color: theme.colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 50,
                              color: theme.hintColor,
                            ),
                          ),
                        ),

                        // Nama dan ID
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produk.nama,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "ID: ${produk.id}",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Statistik
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              _buildStatItem(
                                theme,
                                _getPriceRange(produk.varians),
                                "Harga",
                              ),
                              _buildStatItem(
                                theme,
                                _getTotalStok(produk.varians),
                                "Total Stok",
                              ),
                              _buildStatItem(theme, "0", "Terjual"),
                            ],
                          ),
                        ),

                        const Divider(indent: 16, endIndent: 16),

                        // Aksi
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              _buildActionButton(
                                text: "Edit",
                                icon: Icons.edit_outlined,
                                color: theme.colorScheme.primary,
                                primary: true,
                                onPressed: () => _editProduk(produk),
                              ),
                              _buildActionButton(
                                text: "Hapus",
                                icon: Icons.delete_outline,
                                color: theme.colorScheme.error,
                                onPressed: () =>
                                    _hapusProduk(produk.id, produk.nama),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
