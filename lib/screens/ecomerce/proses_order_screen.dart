import 'package:flutter/material.dart';

// --- DUMMY DATA ---
// [PERBAIKAN] Menambahkan 2 item baru untuk 'Belum Dibayar'
final List<Map<String, dynamic>> dummyOrders = [
  {
    'store': 'Apple Store Official',
    'status': 'Belum Dibayar',
    'product_name': 'iPhone 15 Pro Max 256GB',
    'price': 'Rp 18.999.000',
    'quantity': 1,
    'date': '05 Nov 2025',
    'eta': 'Bayar sebelum 06 Nov, 12:00', // ETA diubah jadi batas bayar
    'image': 'assets/images/elektronik.webp',
    'tab': 'Belum Dibayar', // Tab baru
  },
  {
    'store': 'Garmen Lokal',
    'status': 'Belum Dibayar',
    'product_name': 'Jaket Kulit Asli',
    'price': 'Rp 750.000',
    'quantity': 1,
    'date': '05 Nov 2025',
    'eta': 'Bayar sebelum 06 Nov, 12:00',
    'image': 'assets/images/baju.webp',
    'tab': 'Belum Dibayar', // Tab baru
  },
  {
    'store': 'Samsung Official Store',
    'status': 'Sedang Dikemas',
    'product_name': 'Samsung Galaxy S24 Ultra',
    'price': 'Rp 16.999.000',
    'quantity': 1,
    'date': '24 Okt 2025',
    'eta': '27-29 Okt 2025',
    'image': 'assets/images/elektronik.webp',
    'tab': 'Dikemas',
  },
  {
    'store': 'Xiaomi Official',
    'status': 'Sudah Dikirim',
    'product_name': 'Xiaomi Pad 6',
    'price': 'Rp 5.999.000',
    'quantity': 2,
    'date': '20 Okt 2025',
    'eta': '23-25 Okt 2025',
    'image': 'assets/images/elektronik.webp',
    'tab': 'Dikirim',
  },
  {
    'store': 'Toko Lain',
    'status': 'Dibatalkan',
    'product_name': 'Kaos Polo Premium',
    'price': 'Rp 199.000',
    'quantity': 3,
    'date': '15 Okt 2025',
    'eta': 'Dibatalkan',
    'image': 'assets/images/baju.webp',
    'tab': 'Dibatalkan',
  },
  {
    'store': 'Toko Elektronik A',
    'status': 'Selesai',
    'product_name': 'Headset Gaming RGB',
    'price': 'Rp 450.000',
    'quantity': 1,
    'date': '11 Okt 2025',
    'eta': 'Selesai',
    'image': 'assets/images/elektronik.webp',
    'tab': 'Selesai',
  },
];

// Menghitung jumlah pesanan untuk badge tab
Map<String, int> getTabCounts(List<Map<String, dynamic>> orders) {
  // [PERBAIKAN] Tambahkan 'Belum Dibayar' ke penghitungan
  final counts = {
    'Belum Dibayar': 0,
    'Dikemas': 0,
    'Dikirim': 0,
    'Selesai': 0,
    'Dibatalkan': 0,
  };
  for (var order in orders) {
    if (counts.containsKey(order['tab'])) {
      counts[order['tab']] = counts[order['tab']]! + 1;
    }
  }
  return counts;
}

class ProsesOrderScreen extends StatelessWidget {
  const ProsesOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabCounts = getTabCounts(dummyOrders);

    // [PERBAIKAN] Tambahkan 'Belum Dibayar' di urutan PERTAMA
    final tabs = [
      'Belum Dibayar',
      'Dikemas',
      'Dikirim',
      'Selesai',
      'Dibatalkan',
    ];
    final theme = Theme.of(context);

    return DefaultTabController(
      length: tabs.length, // <-- Otomatis jadi 5
      // [PERBAIKAN] Kita bisa set 'initialIndex' jika mau,
      // tapi 0 (Belum Dibayar) sudah default.
      // initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan Saya'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Aksi pencarian
              },
            ),
          ],
          bottom: TabBar(
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
            tabs: tabs.map((tab) {
              final count = tabCounts[tab] ?? 0;
              return Tab(
                child: Row(
                  children: [
                    Text(tab),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        // [PERBAIKAN] 'Belum Dibayar' juga pakai warna merah
                        color:
                            count > 0 &&
                                (tab == 'Belum Dibayar' || tab == 'Dikemas')
                            ? theme
                                  .colorScheme
                                  .error // Warna merah
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              count > 0 &&
                                  (tab == 'Belum Dibayar' || tab == 'Dikemas')
                              ? theme
                                    .colorScheme
                                    .onError // Putih
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((tab) {
            final filteredOrders = dummyOrders
                .where((order) => order['tab'] == tab)
                .toList();
            return _buildOrderList(context, filteredOrders);
          }).toList(),
        ),
      ),
    );
  }

  // --- Widget untuk Daftar Pesanan berdasarkan Tab ---
  Widget _buildOrderList(
    BuildContext context,
    List<Map<String, dynamic>> orders,
  ) {
    if (orders.isEmpty) {
      return Center(
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
              'Tidak ada pesanan di status ini.',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderCard(order: orders[index]);
      },
    );
  }
}

// --- Komponen Kartu Pesanan ---
class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCard({required this.order, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    final Color onPrimaryColor = theme.colorScheme.onPrimary;

    // [PERBAIKAN] Logika warna status
    Color statusColor;
    switch (order['tab']) {
      case 'Selesai':
        statusColor = Colors.green;
        break;
      case 'Dibatalkan':
        statusColor = theme.colorScheme.error;
        break;
      case 'Belum Dibayar': // <-- Tambahkan case baru
        statusColor = theme.colorScheme.error; // Pakai warna merah
        break;
      default: // 'Dikemas' dan 'Dikirim'
        statusColor = primaryColor;
    }

    // [PERBAIKAN] Cek apakah ini tab "Belum Dibayar"
    final bool isUnpaid = order['tab'] == 'Belum Dibayar';

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
            // BARIS ATAS: Nama Toko dan Status
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
                    order['store']!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  order['status']!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor, // Status menggunakan warna dinamis
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 0.5),

            // DETAIL PRODUK
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    order['image']!,
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
                        order['product_name']!,
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
                            order['price']!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'x${order['quantity']}',
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

            // TANGGAL DAN ESTIMASI
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
                        order['date']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        // [PERBAIKAN] Ganti ikon jika belum dibayar
                        isUnpaid
                            ? Icons.access_time_filled_outlined
                            : Icons.local_shipping_outlined,
                        size: 14,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        // [PERBAIKAN] Ganti label jika belum dibayar
                        isUnpaid ? 'Batas Pembayaran:' : 'Estimasi Tiba:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        order['eta']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- [PERBAIKAN] TOMBOL AKSI ---
            // Tampilkan tombol "Bayar" jika 'isUnpaid',
            // atau tombol "Lihat Detail" jika tidak.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Aksi Lihat Detail
                    },
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
                      // --- TAMPILKAN TOMBOL "BAYAR" ---
                      ? ElevatedButton(
                          onPressed: () {
                            // TODO: Nanti panggil halaman instruksi bayar
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) => PaymentInstructionScreen(
                            //     noTransaksi: order['no_transaksi'], // Kirim No Transaksi
                            //   )
                            // ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error, // Merah
                            foregroundColor: theme.colorScheme.onError, // Putih
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 1,
                          ),
                          child: const Text('Bayar Sekarang'),
                        )
                      // --- ATAU TAMPILKAN TOMBOL "HUBUNGI" ---
                      : ElevatedButton(
                          onPressed: () {
                            // TODO: Aksi Hubungi Penjual
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: onPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 1,
                          ),
                          child: const Text('Hubungi Penjual'),
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
