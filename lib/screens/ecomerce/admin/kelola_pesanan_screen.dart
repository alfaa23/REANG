import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KelolaPesananScreen extends StatefulWidget {
  const KelolaPesananScreen({super.key});

  @override
  State<KelolaPesananScreen> createState() => _KelolaPesananScreenState();
}

class _KelolaPesananScreenState extends State<KelolaPesananScreen> {
  String _selectedStatus = 'Perlu Dikonfirmasi';

  final List<String> _statusFilters = const [
    'Perlu Dikonfirmasi',
    'Siap Dikemas',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  // Data Dummy (Pastikan ada data untuk setiap status agar badge muncul)
  final List<Map<String, dynamic>> _allDummyPesanan = [
    {
      'no_transaksi': 'TRX-111',
      'nama_pemesan': 'Budi Santoso',
      'total': 150000,
      'jumlah_item': 2,
      'status': 'menunggu_konfirmasi', // <- 1
      'tanggal_pesan': DateTime.now().subtract(const Duration(minutes: 30)),
      'nama_produk_utama': 'Kemeja Batik Lengan Panjang Pria',
      'foto_produk':
          'https://plus.unsplash.com/premium_photo-1673482322369-183416b4125f?w=500&q=80',
    },
    {
      'no_transaksi': 'TRX-222',
      'nama_pemesan': 'Citra Lestari',
      'total': 75000,
      'jumlah_item': 1,
      'status': 'diproses', // <- 1
      'tanggal_pesan': DateTime.now().subtract(const Duration(hours: 2)),
      'nama_produk_utama': 'Kaos Polos Cotton Combed 30s',
      'foto_produk':
          'https://images.unsplash.com/photo-1622470953794-aa69c6e0017c?w=500&q=80',
    },
    {
      'no_transaksi': 'TRX-333',
      'nama_pemesan': 'Agus Setiawan',
      'total': 320000,
      'jumlah_item': 5,
      'status': 'dikirim', // <- 1
      'tanggal_pesan': DateTime.now().subtract(const Duration(days: 1)),
      'nama_produk_utama': 'Celana Jeans Pria Slim Fit',
      'foto_produk':
          'https://images.unsplash.com/photo-1602293589930-4535a9a720d0?w=500&q=80',
    },
    {
      'no_transaksi': 'TRX-444',
      'nama_pemesan': 'Dewi Anggraini',
      'total': 55000,
      'jumlah_item': 1,
      'status': 'diproses', // <- 2
      'tanggal_pesan': DateTime.now().subtract(const Duration(hours: 3)),
      'nama_produk_utama': 'Jilbab Instan Bergo',
      'foto_produk':
          'https://images.unsplash.com/photo-1585294336108-76PA31a28d6c?w=500&q=80',
    },
    {
      'no_transaksi': 'TRX-666',
      'nama_pemesan': 'Fina Mustika',
      'total': 210000,
      'jumlah_item': 3,
      'status': 'menunggu_konfirmasi', // <- 2
      'tanggal_pesan': DateTime.now().subtract(const Duration(hours: 1)),
      'nama_produk_utama': 'Gamis Wanita Modern Syar\'i',
      'foto_produk':
          'https://images.unsplash.com/photo-1590132622037-036ef3f5451e?w=500&q=80',
    },
    {
      'no_transaksi': 'TRX-777',
      'nama_pemesan': 'Rian Hidayat',
      'total': 80000,
      'jumlah_item': 1,
      'status': 'dibatalkan', // <- 1
      'tanggal_pesan': DateTime.now().subtract(const Duration(days: 1)),
      'nama_produk_utama': 'Topi Baseball Polos',
      'foto_produk':
          'https://images.unsplash.com/photo-1588850561407-ed7080f145f8?w=500&q=80',
    },
  ];

  // --- [PERBAIKAN 1]: Fungsi untuk menghitung notifikasi/badge ---
  Map<String, int> _getStatusCounts() {
    final counts = {
      'Perlu Dikonfirmasi': 0,
      'Siap Dikemas': 0,
      'Dikirim': 0,
      'Selesai': 0,
      'Dibatalkan': 0,
    };
    for (var pesanan in _allDummyPesanan) {
      final status = pesanan['status'];
      if (status == 'menunggu_konfirmasi') {
        counts['Perlu Dikonfirmasi'] = counts['Perlu Dikonfirmasi']! + 1;
      } else if (status == 'diproses') {
        counts['Siap Dikemas'] = counts['Siap Dikemas']! + 1;
      } else if (status == 'dikirim') {
        counts['Dikirim'] = counts['Dikirim']! + 1;
      } else if (status == 'selesai') {
        counts['Selesai'] = counts['Selesai']! + 1;
      } else if (status == 'dibatalkan') {
        counts['Dibatalkan'] = counts['Dibatalkan']! + 1;
      }
    }
    return counts;
  }

  // Helper untuk mem-filter data dummy berdasarkan chip yang dipilih
  List<Map<String, dynamic>> _filterPesanan(String status) {
    String statusKey = '';
    switch (status) {
      case 'Perlu Dikonfirmasi':
        statusKey = 'menunggu_konfirmasi';
        break;
      case 'Siap Dikemas':
        statusKey = 'diproses';
        break;
      case 'Dikirim':
        statusKey = 'dikirim';
        break;
      case 'Selesai':
        statusKey = 'selesai';
        break;
      case 'Dibatalkan':
        statusKey = 'dibatalkan';
        break;
    }
    return _allDummyPesanan.where((p) => p['status'] == statusKey).toList();
  }

  // --- [PERBAIKAN 2]: Helper untuk ikon di chip ---
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
    final filteredList = _filterPesanan(_selectedStatus);
    // [PERBAIKAN 3]: Panggil fungsi hitung badge
    final statusCounts = _getStatusCounts();

    return SingleChildScrollView(
      // Padding utama halaman, sama seperti Analitik
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul halaman (dengan padding horizontal agar sejajar)
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

          // [PERBAIKAN 4]: Chip Filter yang sudah diperbaiki
          _buildChipFilters(theme, statusCounts),
          const SizedBox(height: 24),

          // Daftar pesanan (dengan padding horizontal agar sejajar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildPesananList(context, theme, filteredList),
          ),
        ],
      ),
    );
  }

  // --- [PERBAIKAN 5]: Widget Chip Filter (Desain & Layout Baru) ---
  Widget _buildChipFilters(ThemeData theme, Map<String, int> counts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // [PERBAIKAN KUNCI]:
      // 'clipBehavior: Clip.none' mengizinkan bayangan/shadow chip terlihat
      // 'padding' horizontal di sini memberikan 'ruang' di awal dan akhir
      // list yang bisa di-scroll, sehingga terasa natural.
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: _statusFilters.map((status) {
          final bool isSelected = _selectedStatus == status;
          final count = counts[status] ?? 0;

          // Tampilkan badge hanya untuk tab yang butuh aksi
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
                  // [PERBAIKAN 6]: Tampilkan Badge (Notifikasi)
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
              // Bentuk chip lebih rounded
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                // Hilangkan border saat terpilih
                side: isSelected
                    ? BorderSide.none
                    : BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
              ),
              showCheckmark: false,
              elevation: 1, // Beri sedikit bayangan
            ),
          );
        }).toList(),
      ),
    );
  }

  // (Tidak ada perubahan di sini)
  Widget _buildPesananList(
    BuildContext context,
    ThemeData theme,
    List<Map<String, dynamic>> pesananList,
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
        return _PesananAdminCard(pesanan: pesananList[index]);
      },
    );
  }
}

// ==========================================================
// KARTU PESANAN KHUSUS ADMIN (Desain dari v1, sudah bagus)
// =DARI SINI KE BAWAH TIDAK ADA PERUBAHAN=
// ==========================================================
class _PesananAdminCard extends StatelessWidget {
  final Map<String, dynamic> pesanan;

  const _PesananAdminCard({required this.pesanan});

  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  Widget _buildAksiButton(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status) {
      case 'menunggu_konfirmasi':
        return ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('TODO: Buka halaman cek bukti bayar'),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Cek Pembayaran'),
        );
      case 'diproses':
        return ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('TODO: Buka halaman input resi')),
            );
          },
          icon: const Icon(Icons.local_shipping_outlined, size: 18),
          label: const Text('Proses Kirim'),
        );
      case 'dikirim':
        return OutlinedButton(
          onPressed: () {
            /* TODO: Tandai Selesai */
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green.shade700,
            side: BorderSide(color: Colors.green.shade700),
          ),
          child: const Text('Tandai Selesai'),
        );
      default:
        return OutlinedButton(
          onPressed: () {
            /* TODO: Navigasi ke Detail (Read-only) */
          },
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // --- Header: Info Pemesan ---
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
                    pesanan['nama_pemesan']!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  DateFormat(
                    'dd MMM, HH:mm',
                    'id_ID',
                  ).format(pesanan['tanggal_pesan']!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 0.5),

            // --- Body: Info Produk ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menampilkan Gambar Produk
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    pesanan['foto_produk']!,
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
                        pesanan['no_transaksi']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pesanan['nama_produk_utama']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pesanan['jumlah_item']} Item',
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

            // --- Footer: Total & Aksi ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Pesanan:', style: theme.textTheme.bodySmall),
                    Text(
                      _formatCurrency(pesanan['total']!),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                // Tombol Aksi
                _buildAksiButton(context, pesanan['status']!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
