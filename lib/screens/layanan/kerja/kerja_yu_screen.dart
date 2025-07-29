import 'package:flutter/material.dart';

class KerjaYuScreen extends StatefulWidget {
  const KerjaYuScreen({super.key});
  @override
  State<KerjaYuScreen> createState() => _KerjaYuScreenState();
}

class _KerjaYuScreenState extends State<KerjaYuScreen> {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _tabs = const [
    {'label': 'Semua', 'icon': Icons.work_outline},
    {'label': 'Lowongan', 'icon': Icons.apartment_outlined},
    {'label': 'Job Fair', 'icon': Icons.event_available_outlined},
    {'label': 'Pelatihan', 'icon': Icons.model_training_outlined},
  ];

  final List<Map<String, dynamic>> _jobs = const [
    {
      'category': 'Lowongan',
      'logoPath': 'assets/logos/daya_anugrah.png',
      'title': 'CRM Operation & Customer Handling',
      'company': 'PT Daya Anugrah Mandiri',
      'type': 'Full-Time',
      'location': 'Bandung, Jawa Barat',
      'salary': 'Rp 6.000.000 - Rp 7.000.000 per bulan',
      'benefits': [
        'Gaji Kompetitif',
        'BPJS Kesehatan & Ketenagakerjaan',
        'Kesempatan Pengembangan Karier',
      ],
      'description':
          'Mengelola administrasi barang/PO, koordinasi dengan banyak pihak, dan memastikan kelancaran proses pengadaan barang untuk kebutuhan penjualan.',
    },
    {
      'category': 'Lowongan',
      'logoPath': 'assets/logos/pertamina.png',
      'title': 'Operator Kilang Minyak',
      'company': 'PT Pertamina (Persero)',
      'type': 'Kontrak',
      'location': 'Indramayu, Jawa Barat',
      'salary': 'Gaji Kompetitif',
      'benefits': [
        'Tunjangan Hari Raya',
        'Asuransi Kesehatan',
        'Program Pensiun',
      ],
      'description':
          'Bertanggung jawab atas operasional harian di unit kilang untuk memastikan produksi berjalan sesuai target dan standar keselamatan.',
    },
    {
      'category': 'Job Fair',
      'logoPath': 'assets/logos/disnaker.png',
      'title': 'Indramayu Job Fair 2025',
      'company': 'Disnaker Indramayu',
      'type': 'Acara',
      'location': 'GOR Singalodra',
      'salary': '25 - 27 Agustus 2025',
      'benefits': [
        'Puluhan perusahaan terkemuka',
        'Ribuan lowongan tersedia',
        'Seminar karir gratis',
      ],
      'description':
          'Acara bursa kerja terbesar di Indramayu yang mempertemukan pencari kerja dengan perusahaan-perusahaan ternama.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Map<String, dynamic>> filteredJobs = _jobs;

    // Filter berdasarkan kategori
    if (_selectedTab != 0) {
      filteredJobs = _jobs
          .where((j) => j['category'] == _tabs[_selectedTab]['label'])
          .toList();
    }

    // Filter berdasarkan pencarian
    if (_searchQuery.isNotEmpty) {
      filteredJobs = filteredJobs
          .where(
            (j) => (j['title'] as String).toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    // PERUBAHAN: Menentukan teks hint untuk search bar secara dinamis
    final String searchHint = _selectedTab == 0
        ? 'Cari semua...'
        : 'Cari di ${_tabs[_selectedTab]['label']}...';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kerja-Yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Temukan karir impianmu',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // PERUBAHAN: Mengirim teks hint yang dinamis ke widget search bar
          _buildSearchBar(theme, searchHint),
          const SizedBox(height: 16),
          _buildFilterTabs(theme),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredJobs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _JobCard(data: filteredJobs[i]),
            ),
          ),
        ],
      ),
    );
  }

  // PERUBAHAN: Widget search bar sekarang menerima parameter hintText
  Widget _buildSearchBar(ThemeData theme, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          // Menggunakan hintText dari parameter
          hintText: hintText,
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
    );
  }

  Widget _buildFilterTabs(ThemeData theme) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final tabData = _tabs[i];
          final sel = i == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: sel
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tabData['icon'] as IconData,
                    size: 20,
                    color: sel
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tabData['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      color: sel
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
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

/// Kartu lowongan kerja dengan desain baru yang terinspirasi dari JobStreet
class _JobCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _JobCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Menentukan warna kartu dan teks berdasarkan tema
    final cardColor = isDark ? const Color(0xFF2E2E2E) : theme.cardColor;
    final textColor = isDark ? Colors.white : theme.textTheme.bodyLarge!.color;
    final subtleTextColor = isDark ? Colors.white70 : theme.hintColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: InkWell(
        onTap: () {
          // TODO: Navigasi ke halaman detail lowongan
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Perusahaan
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  data['logoPath'],
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.business,
                      size: 40,
                      color: Colors.grey.shade400,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Judul & Perusahaan
              Text(
                data['title'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data['company'],
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
              const SizedBox(height: 8),

              // Info Tambahan
              Text(data['type'], style: TextStyle(color: subtleTextColor)),
              Text(data['location'], style: TextStyle(color: subtleTextColor)),
              const SizedBox(height: 4),
              Text(
                data['salary'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Benefits
              if (data['benefits'] != null)
                ...List<Widget>.from(
                  (data['benefits'] as List<String>).map(
                    (b) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(color: textColor, fontSize: 14),
                          ),
                          Expanded(
                            child: Text(
                              b,
                              style: TextStyle(color: textColor, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Deskripsi
              Text(
                data['description'],
                style: TextStyle(color: subtleTextColor, height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
