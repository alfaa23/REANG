import 'package:flutter/material.dart';
import 'package:reang_app/screens/peta/peta_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:reang_app/screens/layanan/sekolah/ppdb_webview_screen.dart';
import 'package:reang_app/screens/layanan/sekolah/berita_pendidikan_view.dart';
import 'package:reang_app/services/api_service.dart';

class SekolahYuScreen extends StatefulWidget {
  const SekolahYuScreen({super.key});
  @override
  State<SekolahYuScreen> createState() => _SekolahYuScreenState();
}

class _SekolahYuScreenState extends State<SekolahYuScreen> {
  int _selectedTab = 0;
  // --- PERUBAHAN 1: Tambahkan state untuk menyimpan jumlah sekolah --- hehehe
  Map<String, int> _schoolCounts = {};
  // -----------------------------------------------------------------

  final List<Map<String, dynamic>> _tabs = const [
    {'label': 'Cari Sekolah', 'icon': Icons.search},
    {'label': 'PPDB Indramayu', 'icon': Icons.assignment_ind_outlined},
    {'label': 'Berita Pendidikan', 'icon': Icons.article_outlined},
  ];

  bool _isPpdbInitiated = false;
  // --- TAMBAHAN BARU: State untuk lazy load Berita Pendidikan ---
  bool _isBeritaInitiated = false;
  WebViewController? _ppdbWebViewController;

  final List<Map<String, dynamic>> _schools = const [
    {
      'icon': Icons.palette_outlined,
      'iconColor': Colors.deepOrange,
      'title': 'Taman Kanak-Kanak',
      'subtitle': 'Usia 4-6 tahun',
      'description':
          'Pendidikan anak usia dini dengan metode bermain sambil belajar',
      'fitur': 'tk',
    },
    {
      'icon': Icons.menu_book_outlined,
      'iconColor': Colors.blue,
      'title': 'Sekolah Dasar',
      'subtitle': 'Kelas 1-6',
      'description':
          'Pendidikan dasar 6 tahun untuk membangun fondasi akademik yang kuat',
      'fitur': 'sd',
    },
    {
      'icon': Icons.school_outlined,
      'iconColor': Colors.green,
      'title': 'Sekolah Menengah Pertama',
      'subtitle': 'Kelas 7-9',
      'description':
          'Pendidikan menengah pertama dengan kurikulum wajib & peminatan ringan',
      'fitur': 'smp',
    },
    {
      'icon': Icons.cast_for_education_outlined,
      'iconColor': Colors.purple,
      'title': 'Sekolah Menengah Atas',
      'subtitle': 'Kelas 10-12',
      'description':
          'Pendidikan menengah dengan berbagai jurusan dan peminatan',
      'fitur': 'sma',
    },
    {
      'icon': Icons.account_balance_outlined,
      'iconColor': Colors.brown,
      'title': 'Universitas',
      'subtitle': 'S1/S2/S3',
      'description':
          'Pendidikan tinggi dengan berbagai program studi dan fakultas',
      'fitur': 'kuliah',
    },
  ];

  // --- PERUBAHAN 2: Panggil fungsi untuk fetch data saat screen pertama kali dibuka ---
  @override
  void initState() {
    super.initState();
    _fetchSchoolCounts();
  }
  // ----------------------------------------------------------------------------------

  // --- PERUBAHAN 3: Buat fungsi baru untuk mengambil data jumlah sekolah ---
  // Fungsi ini berjalan di latar belakang tanpa mengganggu UI.
  // Jika gagal (tidak ada internet), _schoolCounts akan tetap kosong (default 0).
  Future<void> _fetchSchoolCounts() async {
    try {
      final sekolahList = await ApiService().fetchTempatSekolah();
      final Map<String, int> counts = {};
      for (var s in sekolahList) {
        counts[s.fitur] = (counts[s.fitur] ?? 0) + 1;
      }
      // Cek jika widget masih ada di tree sebelum setState
      if (mounted) {
        setState(() {
          _schoolCounts = counts;
        });
      }
    } catch (e) {
      // Jika terjadi error (misal: tidak ada koneksi), biarkan saja.
      // Tidak perlu menampilkan pesan error di halaman ini.
      // _schoolCounts akan tetap kosong, sehingga count akan jadi 0.
      debugPrint("Gagal mengambil data jumlah sekolah: $e");
    }
  }
  // -------------------------------------------------------------------------

  void _openMap(BuildContext context, String jenjang, String judulHalaman) {
    final String apiUrl = 'tempat-sekolah?fitur=$jenjang';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetaScreen(
          apiUrl: apiUrl,
          judulHalaman: judulHalaman,
          defaultIcon: Icons.school,
          defaultColor: Colors.blue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (_selectedTab == 1 && _ppdbWebViewController != null) {
          if (await _ppdbWebViewController!.canGoBack()) {
            await _ppdbWebViewController!.goBack();
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
                'Sekolah-Yu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                'Temukan sekolah terbaik di Indramayu',
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            _buildTabs(theme),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildCariSekolahView(theme),
                  _isPpdbInitiated
                      ? PpdbWebView(
                          onControllerCreated: (controller) {
                            _ppdbWebViewController = controller;
                          },
                        )
                      : Container(),
                  // --- PERUBAHAN: Menerapkan lazy load ---
                  _isBeritaInitiated
                      ? const BeritaPendidikanView()
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
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
            onTap: () {
              setState(() {
                _selectedTab = i;
                if (i == 1 && !_isPpdbInitiated) {
                  _isPpdbInitiated = true;
                }
                // --- PERUBAHAN: Mengaktifkan lazy load untuk Berita ---
                if (i == 2 && !_isBeritaInitiated) {
                  _isBeritaInitiated = true;
                }
              });
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

  // --- PERUBAHAN 4: Hapus FutureBuilder ---
  Widget _buildCariSekolahView(ThemeData theme) {
    // Tidak ada lagi FutureBuilder, langsung bangun ListView.
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Cari Sekolah Terdekat',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih jenjang pendidikan untuk menemukan sekolah terbaik di sekitar Anda',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        ),
        const SizedBox(height: 16),
        // Gunakan data dari state _schoolCounts
        ..._schools.map((s) {
          final fitur = s['fitur'] as String;
          // Ambil jumlah dari state, jika tidak ada, defaultnya 0.
          final count = _schoolCounts[fitur] ?? 0;
          return _SchoolCard(
            data: {
              ...s,
              'countText': count > 0
                  ? "$count Sekolah Tersedia"
                  : "0 Sekolah Tersedia", // Tampilkan 0 jika tidak ada
            },
            onTapCari: () => _openMap(context, fitur, s['title']),
          );
        }).toList(),
      ],
    );
  }

  // -------------------------------------------
}

class _SchoolCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTapCari;

  const _SchoolCard({required this.data, required this.onTapCari});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  data['icon'] as IconData,
                  size: 28,
                  color: data['iconColor'] as Color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['subtitle'],
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              data['description'] as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.school_outlined, size: 14, color: theme.hintColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data['countText'],
                    style: TextStyle(fontSize: 13, color: theme.hintColor),
                  ),
                ),
                GestureDetector(
                  onTap: onTapCari,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Cari Sekolah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
