import 'package:flutter/material.dart';

class KelolaMetodePembayaranScreen extends StatefulWidget {
  const KelolaMetodePembayaranScreen({super.key});

  @override
  State<KelolaMetodePembayaranScreen> createState() =>
      _KelolaMetodePembayaranScreenState();
}

class _KelolaMetodePembayaranScreenState
    extends State<KelolaMetodePembayaranScreen> {
  // --- Data Dummy ---
  final List<Map<String, String>> _paymentMethods = [
    {
      'metode': 'Transfer Bank BCA',
      'penerima': 'Rizky Pratama',
      'nomor': '1234567890',
      'type': 'bank',
    },
    {
      'metode': 'QRIS',
      'penerima': 'Toko Fashion Modern',
      'nomor': 'NMID: ID1234567890',
      'type': 'qris',
    },
    {
      'metode': 'GoPay',
      'penerima': 'Rizky Pratama',
      'nomor': '081234567890',
      'type': 'ewallet',
    },
  ];

  IconData _getIconForType(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance_outlined;
      case 'qris':
        return Icons.qr_code_2_outlined;
      case 'ewallet':
        return Icons.wallet_outlined;
      default:
        return Icons.payment_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigasi ke halaman Tambah/Edit Metode Pembayaran
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('TODO: Buka halaman tambah metode bayar'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _paymentMethods.length,
        itemBuilder: (context, index) {
          final method = _paymentMethods[index];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Icon(
                _getIconForType(method['type']!),
                color: theme.colorScheme.primary,
              ),
              title: Text(
                method['metode']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${method['penerima']}\n${method['nomor']}"),
              isThreeLine: true,
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                onPressed: () {
                  // TODO: Logika Hapus Data
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
