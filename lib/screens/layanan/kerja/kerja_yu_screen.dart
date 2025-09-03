import 'package:flutter/material.dart';
import 'package:reang_app/models/info_kerja_model.dart';
import 'package:reang_app/services/api_service.dart';
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
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';
  WebViewController? _silelakerjaController;
  bool _isSilelakerjaInitiated = false;

  Future<List<InfoKerjaModel>>? _infoKerjaFuture;

  final List<Map<String, dynamic>> _mainTabs = const [
    {'label': 'Beranda', 'icon': Icons.home_outlined},
    {'label': 'Silelakerja', 'icon': Icons.location_city_outlined},
  ];

  // --- TAMBAHAN: Buat pemetaan dari nama kategori ke ikonnya ---
  final Map<String, IconData> _categoryIcons = {
    'lowongan': Icons.apartment_outlined,
    'job fair': Icons.event_available_outlined,
    'pelatihan': Icons.model_training_outlined,
    // Tambahkan pemetaan lain jika ada kategori baru di API
  };
  // ------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _infoKerjaFuture = ApiService().fetchInfoKerja();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _unfocusGlobal() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          onTap: _unfocusGlobal,
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildMainTabs(theme),
              const SizedBox(height: 24),
              Expanded(
                child: IndexedStack(
                  index: _mainTab,
                  children: [
                    _buildBerandaView(theme),
                    _isSilelakerjaInitiated
                        ? SilelakerjaView(
                            onWebViewCreated: (controller) {
                              _silelakerjaController = controller;
                            },
                          )
                        : Container(),
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
                setState(() {
                  _mainTab = i;
                  if (i == 1 && !_isSilelakerjaInitiated) {
                    _isSilelakerjaInitiated = true;
                  }
                });
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
    return FutureBuilder<List<InfoKerjaModel>>(
      future: _infoKerjaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Gagal memuat data: ${snapshot.error.toString()}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Tidak ada lowongan tersedia saat ini',
              style: TextStyle(color: theme.hintColor),
            ),
          );
        }

        final allJobs = snapshot.data!;

        // --- Buat daftar filter secara dinamis ---
        final Set<String> uniqueCategories = allJobs
            .map((job) => job.kategori)
            .toSet();
        final List<Map<String, dynamic>> dynamicFilterTabs = [
          {'label': 'Semua', 'icon': Icons.work_outline},
        ];
        for (String category in uniqueCategories) {
          dynamicFilterTabs.add({
            'label':
                category[0].toUpperCase() + category.substring(1), // Capitalize
            'icon':
                _categoryIcons[category.toLowerCase()] ?? Icons.work_outline,
          });
        }
        // ----------------------------------------------------

        List<InfoKerjaModel> filteredJobs = allJobs;

        // Gunakan dynamicFilterTabs untuk memfilter
        if (_selectedFilterTab != 0) {
          // Tambah validasi untuk mencegah error out of range
          if (_selectedFilterTab < dynamicFilterTabs.length) {
            final categoryToFilter =
                dynamicFilterTabs[_selectedFilterTab]['label'];
            filteredJobs = allJobs
                .where(
                  (j) =>
                      j.kategori.toLowerCase() ==
                      categoryToFilter.toLowerCase(),
                )
                .toList();
          }
        }

        if (_searchQuery.isNotEmpty) {
          filteredJobs = filteredJobs
              .where(
                (j) =>
                    j.posisi.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    j.namaPerusahaan.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
        }

        final String searchHint =
            (_selectedFilterTab == 0 ||
                _selectedFilterTab >= dynamicFilterTabs.length)
            ? 'Cari semua...'
            : 'Cari di ${dynamicFilterTabs[_selectedFilterTab]['label']}...';

        return Column(
          children: [
            _buildSearchBar(theme, searchHint),
            const SizedBox(height: 16),
            // Kirim daftar filter dinamis ke widget
            _buildFilterTabs(theme, dynamicFilterTabs),
            const SizedBox(height: 16),
            Expanded(
              child: filteredJobs.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada data yang cocok',
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
      },
    );
  }

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

  // --- Terima daftar tab sebagai parameter ---
  Widget _buildFilterTabs(
    ThemeData theme,
    List<Map<String, dynamic>> filterTabs,
  ) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filterTabs.length, // Gunakan panjang list dinamis
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final tabData = filterTabs[i]; // Gunakan data dari list dinamis
          final sel = i == _selectedFilterTab;
          return GestureDetector(
            onTap: () {
              // Validasi agar tidak error jika filter berubah dan index lama tidak valid
              if (i < filterTabs.length) {
                setState(() => _selectedFilterTab = i);
              }
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
  final InfoKerjaModel data;
  const _JobCard({required this.data});

  // Helper untuk mengubah HTML menjadi teks biasa untuk ringkasan
  String _stripHtml(String htmlText) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, ' ').replaceAll('&nbsp;', ' ').trim();
  }

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
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailLowonganScreen(jobData: data),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 120.0, // Batasi tinggi maksimal
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    data.foto,
                    width: 80, // Lebar tetap seperti semula
                    // Tanpa 'fit', tinggi gambar akan menyesuaikan untuk menjaga rasio
                    errorBuilder: (context, error, stackTrace) {
                      // Jika error, tampilkan kotak 80x80 yang konsisten
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.business,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.posisi,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.namaPerusahaan,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12), // Jarak ditambah
              // --- PERUBAHAN DIMULAI DI SINI ---
              Row(
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    size: 16,
                    color: subtleTextColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.jenisKerja,
                      style: TextStyle(color: subtleTextColor, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6), // Jarak antar baris
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: subtleTextColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.alamat,
                      style: TextStyle(color: subtleTextColor, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), // Jarak ditambah
              // --- AKHIR PERUBAHAN ---
              Text(
                data.formattedGaji,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _stripHtml(data.deskripsi),
                style: TextStyle(
                  color: subtleTextColor,
                  height: 1.5,
                  fontSize: 15,
                ),
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
