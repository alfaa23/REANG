import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KelolaOngkirScreen extends StatefulWidget {
  const KelolaOngkirScreen({super.key});

  @override
  State<KelolaOngkirScreen> createState() => _KelolaOngkirScreenState();
}

class _KelolaOngkirScreenState extends State<KelolaOngkirScreen> {
  // --- Data Dummy ---
  final List<Map<String, dynamic>> _ongkirOptions = [
    {'daerah': 'Kec. Indramayu', 'harga': 10000, 'estimasi': '1-2 hari'},
    {'daerah': 'Kec. Haurgeulis', 'harga': 20000, 'estimasi': '2-3 hari'},
    {'daerah': 'Kec. Karangampel', 'harga': 15000, 'estimasi': '1-2 hari'},
    {'daerah': 'Luar Kab. Indramayu', 'harga': 30000, 'estimasi': '3-5 hari'},
  ];

  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Opsi Pengiriman')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigasi ke halaman Tambah/Edit Ongkir
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('TODO: Buka halaman tambah ongkir')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _ongkirOptions.length,
        itemBuilder: (context, index) {
          final option = _ongkirOptions[index];
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
                Icons.local_shipping_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                option['daerah']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Estimasi: ${option['estimasi']}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(option['harga']!),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      /* TODO: Hapus */
                    },
                    child: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
