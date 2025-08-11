import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/dumas/form_laporan_screen.dart';
import 'package:reang_app/screens/layanan/dumas/detail_laporan_screen.dart';

class DumasYuHomeScreen extends StatefulWidget {
  // PERUBAHAN: Menambahkan parameter untuk navigasi langsung
  final bool bukaLaporanSaya;

  const DumasYuHomeScreen({
    Key? key,
    this.bukaLaporanSaya = false, // Defaultnya adalah false (membuka Beranda)
  }) : super(key: key);

  @override
  DumasYuHomeScreenState createState() => DumasYuHomeScreenState();
}

class DumasYuHomeScreenState extends State<DumasYuHomeScreen> {
  late bool isBerandaSelected;

  // Data dummy untuk Laporan Terbaru
  final List<Map<String, dynamic>> _laporanTerbaru = const [
    {
      'imagePath': 'assets/images/jalan_rusak.png',
      'title': 'Jalan Rusak di Malioboro',
      'category': 'Infrastruktur',
      'address': 'Jl. Malioboro, dekat Tugu',
      'status': 'Dalam Proses',
      'statusColor': Colors.orange,
      'timeAgo': '2 hari lalu',
    },
    {
      'imagePath': 'assets/images/lampu_mati.png',
      'title': 'Lampu Jalan Mati',
      'category': 'Fasilitas Umum',
      'address': 'Area Alun-alun Indramayu',
      'status': 'Selesai',
      'statusColor': Colors.green,
      'timeAgo': '5 hari lalu',
    },
  ];

  // Data dummy untuk Laporan Saya (dibuat bisa diubah)
  List<Map<String, dynamic>> _laporanSaya = [];

  @override
  void initState() {
    super.initState();
    // PERUBAHAN: Mengatur tab awal berdasarkan parameter
    isBerandaSelected = !widget.bukaLaporanSaya;

    // Contoh: Isi _laporanSaya dengan data jika ada, atau biarkan kosong
    // _laporanSaya = []; // Untuk mengetes tampilan kosong
    _laporanSaya = const [
      {
        'imagePath': 'assets/images/laporan_lampu.png',
        'title': 'Lampu jalan di depan rumah mati total',
        'category': 'Fasilitas Umum',
        'address': 'Depan rumah, Jl. Kenanga No. 5',
        'status': 'Diproses',
        'statusColor': Colors.orange,
        'timeAgo': '5 hari lalu',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dumas-yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Layanan Pengaduan Masyarakat',
              style: TextStyle(color: theme.hintColor, fontSize: 13),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isBerandaSelected = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isBerandaSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '🏠 Beranda',
                          style: TextStyle(
                            color: isBerandaSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isBerandaSelected = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isBerandaSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '🗒️ Laporan Saya',
                          style: TextStyle(
                            color: !isBerandaSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: isBerandaSelected ? 0 : 1,
              children: [
                _buildBerandaView(theme),
                _buildLaporanSayaView(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBerandaView(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang di Dumas-Yu',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Platform pengaduan masyarakat untuk meningkatkan kualitas pelayanan publik dan infrastruktur kota',
                  style: TextStyle(fontSize: 14, color: theme.hintColor),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormLaporanScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '+ Buat Laporan Baru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Laporan Terbaru',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._laporanTerbaru
              .map((laporan) => _ReportCard(data: laporan))
              .toList(),
        ],
      ),
    );
  }

  // PERUBAHAN: Widget ini sekarang memiliki alternatif jika kosong
  Widget _buildLaporanSayaView(ThemeData theme) {
    if (_laporanSaya.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off_outlined, size: 80, color: theme.hintColor),
              const SizedBox(height: 16),
              Text(
                'Anda belum memiliki laporan',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ayo buat laporan pertama Anda untuk membantu meningkatkan layanan publik.',
                style: TextStyle(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormLaporanScreen(),
                    ),
                  );
                },
                child: const Text('Buat Laporan'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 8),
        ..._laporanSaya.map((laporan) => _ReportCard(data: laporan)).toList(),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ReportCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailLaporanScreen(data: data),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              data['imagePath'],
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 140,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: theme.hintColor,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['category'].toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (data['statusColor'] as Color).withOpacity(
                            0.2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['status'],
                          style: TextStyle(
                            fontSize: 12,
                            color: data['statusColor'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['title'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${data['address']} • ${data['timeAgo']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
