import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/kerja/detail_lowongan_screen.dart';
import 'package:reang_app/screens/layanan/kerja/silelakerja_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KerjaYuScreen extends StatefulWidget {
  const KerjaYuScreen({super.key});
  @override
  State<KerjaYuScreen> createState() => _KerjaYuScreenState();
}

class _KerjaYuScreenState extends State<KerjaYuScreen> {
  int _mainTab = 0;
  int _selectedFilterTab = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode(); // FocusNode untuk search
  String _searchQuery = '';

  // Controller untuk Silelakerja WebView
  WebViewController? _silelakerjaController;

  final List<Map<String, dynamic>> _mainTabs = const [
    {'label': 'Beranda', 'icon': Icons.home_outlined},
    {'label': 'Silelakerja', 'icon': Icons.location_city_outlined},
  ];

  final List<Map<String, dynamic>> _filterTabs = const [
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
      'logoPath': 'assets/logos/bank_bca.png',
      'title': 'Staf Legal Korporasi',
      'company': 'PT Bank Central Asia Tbk',
      'type': 'Full-Time',
      'location': 'Indramayu, Jawa Barat',
      'salary': 'Rp 5.500.000 - Rp 6.500.000 per bulan',
      'benefits': ['Asuransi Jiwa', 'Tunjangan Hari Raya', 'Program Pensiun'],
      'description':
          'Melakukan review perjanjian kerjasama, legal drafting, serta memberikan opini hukum untuk mendukung kegiatan operasional perusahaan.',
    },
    {
      'category': 'Pelatihan',
      'logoPath': 'assets/logos/kemnaker.png',
      'title': 'Pelatihan Digital Marketing',
      'company': 'Balai Latihan Kerja (BLK) Indramayu',
      'type': 'Gratis',
      'location': 'Indramayu, Jawa Barat',
      'salary': 'Sertifikat Kompetensi',
      'benefits': [
        'Modul Pelatihan',
        'Instruktur Ahli',
        'Sertifikat dari BNSP',
      ],
      'description':
          'Program pelatihan intensif selama 1 bulan untuk menguasai SEO, SEM, Social Media Marketing, dan Content Marketing. Terbuka untuk umum.',
    },
    {
      'category': 'Job Fair',
      'logoPath': 'assets/logos/indramayu.png',
      'title': 'Indramayu Career Expo 2025',
      'company': 'Disnaker Indramayu',
      'type': 'Acara',
      'location': 'Gedung Sport Center Indramayu',
      'salary': '25-26 Agustus 2025',
      'benefits': [
        'Puluhan Perusahaan Ternama',
        'Walk-in Interview',
        'Seminar Karir',
      ],
      'description':
          'Bursa kerja terbesar di Indramayu. Bawa CV terbaikmu dan temukan ratusan lowongan dari berbagai industri. Acara ini gratis dan terbuka untuk umum.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose(); // dispose focus node
    super.dispose();
  }

  // Helper: unfocus global
  void _unfocusGlobal() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // WillPopScope untuk menangani back di WebView
    return WillPopScope(
      onWillPop: () async {
        if (_mainTab == 1 && _silelakerjaController != null) {
          if (await _silelakerjaController!.canGoBack()) {
            await _silelakerjaController!.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
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
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) {
            final focused = FocusManager.instance.primaryFocus;
            if (focused != null && focused.context != null) {
              try {
                final renderObject = focused.context!.findRenderObject();
                if (renderObject is RenderBox) {
                  final box = renderObject;
                  final topLeft = box.localToGlobal(Offset.zero);
                  final rect = topLeft & box.size;
                  if (!rect.contains(details.globalPosition)) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                } else {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              } catch (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            } else {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildMainTabs(theme),
              // PERUBAHAN: Atur jarak antara filter utama dan konten di bawahnya
              const SizedBox(height: 24),
              Expanded(
                child: IndexedStack(
                  index: _mainTab,
                  children: [
                    _buildBerandaView(theme),
                    // Memberikan callback ke SilelakerjaView
                    SilelakerjaView(
                      onWebViewCreated: (controller) {
                        _silelakerjaController = controller;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainTabs(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _mainTabs.asMap().entries.map((entry) {
          final i = entry.key;
          final tab = entry.value;
          final isSelected = i == _mainTab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _mainTab = i);
                // NONAKTIFKAN search saat beralih tab utama
                _unfocusGlobal();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'],
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab['label'],
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBerandaView(ThemeData theme) {
    List<Map<String, dynamic>> filteredJobs = _jobs;

    if (_selectedFilterTab != 0) {
      filteredJobs = _jobs
          .where(
            (j) => j['category'] == _filterTabs[_selectedFilterTab]['label'],
          )
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredJobs = filteredJobs
          .where(
            (j) => (j['title'] as String).toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    final String searchHint = _selectedFilterTab == 0
        ? 'Cari semua...'
        : 'Cari di ${_filterTabs[_selectedFilterTab]['label']}...';

    return Column(
      children: [
        _buildSearchBar(theme, searchHint),
        const SizedBox(height: 16),
        _buildFilterTabs(theme),
        const SizedBox(height: 16),
        Expanded(
          child: filteredJobs.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data tersedia',
                    style: TextStyle(color: theme.hintColor),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredJobs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (_, i) => _JobCard(data: filteredJobs[i]),
                ),
        ),
      ],
    );
  }

  // PERBAIKAN: Tampilan search bar diubah
  Widget _buildSearchBar(ThemeData theme, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          autofocus: false,
          focusNode: _searchFocus,
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(Icons.search, color: theme.hintColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
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
        itemCount: _filterTabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final tabData = _filterTabs[i];
          final sel = i == _selectedFilterTab;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilterTab = i);
              // NONAKTIFKAN search saat memilih filter
              _unfocusGlobal();
            },
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

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _JobCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF2E2E2E) : theme.cardColor;
    final textColor = isDark ? Colors.white : theme.textTheme.bodyLarge!.color;
    final subtleTextColor = isDark ? Colors.white70 : theme.hintColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: InkWell(
        onTap: () {
          // NONAKTIFKAN search secara global sebelum navigasi
          FocusManager.instance.primaryFocus?.unfocus();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailLowonganScreen(data: data),
            ),
          ).then((_) {
            // Pastikan search tetap nonaktif saat kembali dari halaman detail
            FocusManager.instance.primaryFocus?.unfocus();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
