import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// PERUBAHAN: Import file view, bukan screen
import 'package:reang_app/screens/layanan/sekolah/ppdb_webview_screen.dart';

class SekolahYuScreen extends StatefulWidget {
  const SekolahYuScreen({super.key});
  @override
  State<SekolahYuScreen> createState() => _SekolahYuScreenState();
}

class _SekolahYuScreenState extends State<SekolahYuScreen> {
  int _selectedTab = 0;
  final List<Map<String, dynamic>> _tabs = const [
    {'label': 'Cari Sekolah', 'icon': Icons.search},
    {'label': 'PPDB Indramayu', 'icon': Icons.assignment_ind_outlined},
    {'label': 'Berita Pendidikan', 'icon': Icons.article_outlined},
    {'label': 'Info Beasiswa', 'icon': Icons.card_giftcard_outlined},
  ];

  bool _isPpdbInitiated = false;
  // PERUBAHAN: Menambahkan variabel untuk menyimpan controller dari child
  WebViewController? _ppdbWebViewController;

  final List<Map<String, dynamic>> _schools = const [
    {
      'icon': Icons.palette_outlined,
      'iconColor': Colors.deepOrange,
      'title': 'Taman Kanak-Kanak',
      'subtitle': 'Usia 4-6 tahun',
      'description':
          'Pendidikan anak usia dini dengan metode bermain sambil belajar',
      'countText': '15 sekolah tersedia',
    },
    {
      'icon': Icons.menu_book_outlined,
      'iconColor': Colors.blue,
      'title': 'Sekolah Dasar',
      'subtitle': 'Kelas 1-6',
      'description':
          'Pendidikan dasar 6 tahun untuk membangun fondasi akademik yang kuat',
      'countText': '28 sekolah tersedia',
    },
    {
      'icon': Icons.school_outlined,
      'iconColor': Colors.green,
      'title': 'Sekolah Menengah Pertama',
      'subtitle': 'Kelas 7-9',
      'description':
          'Pendidikan menengah pertama dengan kurikulum wajib & peminatan ringan',
      'countText': '22 sekolah tersedia',
    },
    {
      'icon': Icons.cast_for_education_outlined,
      'iconColor': Colors.purple,
      'title': 'Sekolah Menengah Atas',
      'subtitle': 'Kelas 10-12',
      'description':
          'Pendidikan menengah dengan berbagai jurusan dan peminatan',
      'countText': '18 sekolah tersedia',
    },
    {
      'icon': Icons.account_balance_outlined,
      'iconColor': Colors.brown,
      'title': 'Universitas',
      'subtitle': 'S1/S2/S3',
      'description':
          'Pendidikan tinggi dengan berbagai program studi dan fakultas',
      'countText': '8 universitas tersedia',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // PERUBAHAN: Membungkus Scaffold dengan WillPopScope
    return WillPopScope(
      onWillPop: () async {
        // Jika tab PPDB yang aktif dan WebView bisa kembali
        if (_selectedTab == 1 && _ppdbWebViewController != null) {
          if (await _ppdbWebViewController!.canGoBack()) {
            // Kembali di dalam WebView, dan jangan keluar dari halaman
            await _ppdbWebViewController!.goBack();
            return false;
          }
        }
        // Jika tidak, izinkan untuk keluar dari halaman
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
                      // PERUBAHAN: Mengirim callback untuk menerima controller
                      ? PpdbWebView(
                          onControllerCreated: (controller) {
                            _ppdbWebViewController = controller;
                          },
                        )
                      : Container(),
                  _buildPlaceholderView(_tabs[2]['label'] as String),
                  _buildPlaceholderView(_tabs[3]['label'] as String),
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

  Widget _buildCariSekolahView(ThemeData theme) {
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
        ..._schools.map((s) => _SchoolCard(data: s)).toList(),
      ],
    );
  }

  Widget _buildPlaceholderView(String title) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: theme.hintColor),
          const SizedBox(height: 16),
          Text("Halaman $title", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            "Fitur ini sedang dalam pengembangan.",
            style: TextStyle(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SchoolCard({required this.data});

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
                TextButton(
                  onPressed: () {
                    // TODO: aksi Cari Terdekat
                  },
                  child: const Text('Cari Terdekat ›'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
