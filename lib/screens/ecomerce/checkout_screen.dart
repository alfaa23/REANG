import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Data dummy produk di keranjang
  final List<Map<String, dynamic>> cartItems = const [
    {
      'title': 'iPhone 15 Pro Max 256GB',
      'variant': 'Varian: Natural Titanium',
      'price': 'Rp 18.999.000',
      'qty': 'x1',
      'total': 'Rp 18.999.000',
    },
    {
      'title': 'Samsung Galaxy S24 Ultra',
      'variant': 'Varian: Titanium Black, 512GB',
      'price': 'Rp 16.999.000',
      'qty': 'x1',
      'total': 'Rp 16.999.000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double bottomBarHeight = 72.0;

    return Scaffold(
      // --- PERBAIKAN 1: Mencegah tombol bawah terdorong oleh keyboard ---
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
      // --- PERBAIKAN 2: Menambahkan GestureDetector untuk menutup keyboard ---
      body: GestureDetector(
        onTap: () {
          // Menutup keyboard saat area kosong di-tap
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
                    StoreCard(theme: theme, products: cartItems),
                    const SizedBox(height: 18),
                    NoteCard(theme: theme),
                    const SizedBox(height: 18),
                    CostBreakdownCard(theme: theme),
                  ],
                ),
              ),
            ),
            // Tombol Aksi di Bawah
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildActionButtons(context, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.dividerColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.phone, color: theme.colorScheme.onSurface),
              label: Text(
                'Hubungi Penjual',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              onPressed: () {
                // handle contact
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withOpacity(0.3),
              ),
              onPressed: () {
                // handle payment
              },
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

// --- WIDGET KARTU ALAMAT ---
class AddressCard extends StatelessWidget {
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

// --- WIDGET KARTU TOKO & PRODUK ---
class StoreCard extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> products;
  const StoreCard({super.key, required this.theme, required this.products});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.storefront, color: theme.colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Toko Elektronik Jaya',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...products
                .map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ProductRow(theme: theme, product: product),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET SATU BARIS PRODUK ---
class ProductRow extends StatelessWidget {
  final ThemeData theme;
  final Map<String, dynamic> product;

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
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'IMG',
                style: TextStyle(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w700,
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
                  product['title'] ?? 'Nama Produk',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['variant'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      product['price'] ?? 'Rp 0',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      product['qty'] ?? 'x0',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            product['total'] ?? 'Rp 0',
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
  const NoteCard({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
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
              decoration: InputDecoration(
                hintText: 'Tinggalkan pesan...',
                hintStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET KARTU RINCIAN BIAYA ---
class CostBreakdownCard extends StatelessWidget {
  final ThemeData theme;
  const CostBreakdownCard({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
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
            _costRow('Harga Produk (2 item)', 'Rp 35.998.000', theme),
            const SizedBox(height: 8),
            _costRow('Ongkos Kirim', 'Rp 25.000', theme),
            const SizedBox(height: 8),
            _costRow('Biaya Layanan', 'Rp 5.000', theme),
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
                  'Rp 36.028.000',
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
