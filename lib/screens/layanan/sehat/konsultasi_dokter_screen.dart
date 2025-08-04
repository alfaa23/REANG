import 'package:flutter/material.dart';
// PERUBAHAN: Import halaman detail puskesmas
import 'package:reang_app/screens/layanan/sehat/detail_puskesmas_screen.dart';

class KonsultasiDokterScreen extends StatefulWidget {
  const KonsultasiDokterScreen({super.key});

  @override
  State<KonsultasiDokterScreen> createState() => _KonsultasiDokterScreenState();
}

class _KonsultasiDokterScreenState extends State<KonsultasiDokterScreen> {
  // Data dummy untuk daftar puskesmas
  final List<Map<String, dynamic>> _puskesmasList = const [
    {
      'nama': 'Puskesmas Balongan',
      'alamat': 'Jl. Raya Balongan No.15, Indramayu',
      'jamBuka': 'Buka: 08.00 - 14.00 WIB',
      'dokterTersedia': 3,
    },
    {
      'nama': 'Puskesmas Sindang',
      'alamat': 'Jl. Raya Sindang No. 10, Indramayu',
      'jamBuka': 'Buka: 08.00 - 14.00 WIB',
      'dokterTersedia': 5,
    },
    {
      'nama': 'Puskesmas Plumbon',
      'alamat': 'Jl. Raya Plumbon No. 22, Indramayu',
      'jamBuka': 'Buka: 08.00 - 14.00 WIB',
      'dokterTersedia': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konsultasi Dokter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Terhubung dengan dokter puskesmas',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari puskesmas',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Judul "Puskesmas Tersedia"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Puskesmas Tersedia',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_puskesmasList.length} lokasi',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Puskesmas
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _puskesmasList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _PuskesmasCard(data: _puskesmasList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk kartu Puskesmas
class _PuskesmasCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PuskesmasCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['nama'],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data['alamat'],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(theme, Icons.access_time_outlined, data['jamBuka']),
            const SizedBox(height: 4),
            _buildInfoRow(
              theme,
              Icons.person_outline,
              '${data['dokterTersedia']} Dokter tersedia',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // PERUBAHAN: Menambahkan navigasi ke halaman detail
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailPuskesmasScreen(puskesmasData: data),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cari Dokter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.hintColor),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
