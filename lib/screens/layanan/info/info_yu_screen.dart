import 'package:flutter/material.dart';
import 'package:reang_app/models/berita_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:reang_app/screens/layanan/info/detail_berita_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoYuScreen extends StatefulWidget {
  const InfoYuScreen({super.key});

  @override
  State<InfoYuScreen> createState() => _InfoYuScreenState();
}

class _InfoYuScreenState extends State<InfoYuScreen> {
  // State untuk API Berita
  final ApiService _apiService = ApiService();
  late Future<List<Berita>> _beritaFuture;

  // State untuk WebView CCTV
  final WebViewController _cctvController = WebViewController();
  bool _isCctvLoading = true;

  // State untuk mengontrol tab yang aktif
  int _selectedTabIndex = 0; // 0 untuk Berita, 1 untuk CCTV

  @override
  void initState() {
    super.initState();
    // Inisialisasi untuk Berita
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _beritaFuture = _apiService.fetchBerita();

    // Konfigurasi controller CCTV
    _cctvController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() => _isCctvLoading = true);
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isCctvLoading = false);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://cctv.indramayukab.go.id/')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://cctv.indramayukab.go.id/'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Info-yu'),
            Text(
              'Update terbaru dari Indramayu',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // PERUBAHAN: Membuat baris untuk tombol filter yang lebih besar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                    context,
                    label: 'Berita',
                    icon: Icons.newspaper,
                    index: 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterChip(
                    context,
                    label: 'CCTV',
                    icon: Icons.videocam,
                    index: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Menampilkan konten berdasarkan tab yang aktif
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [_buildBeritaView(), _buildCctvView()],
            ),
          ),
        ],
      ),
    );
  }

  // PERUBAHAN: Widget untuk tombol filter diubah menjadi custom agar ukurannya lebih besar
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required int index,
  }) {
    final theme = Theme.of(context);
    final bool isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan daftar berita
  Widget _buildBeritaView() {
    return FutureBuilder<List<Berita>>(
      future: _beritaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final beritaList = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _beritaFuture = _apiService.fetchBerita();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: beritaList.length,
              itemBuilder: (context, index) {
                final berita = beritaList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InfoCard(berita: berita),
                );
              },
            ),
          );
        }
        return const Center(child: Text('Tidak ada berita tersedia.'));
      },
    );
  }

  // Widget untuk menampilkan WebView CCTV
  Widget _buildCctvView() {
    return Stack(
      children: [
        WebViewWidget(controller: _cctvController),
        if (_isCctvLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

// Widget InfoCard (diperbarui untuk navigasi)
class InfoCard extends StatelessWidget {
  final Berita berita;

  const InfoCard({super.key, required this.berita});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBeritaScreen(berita: berita),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (berita.featuredImageUrl.isNotEmpty)
              Image.network(
                berita.featuredImageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: theme.hintColor,
                      size: 48,
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Text(
                timeago.format(berita.date, locale: 'id'),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                berita.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                berita.excerpt,
                style: TextStyle(color: theme.hintColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
