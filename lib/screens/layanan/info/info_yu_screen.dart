import 'package:flutter/material.dart';
import 'package:reang_app/models/berita_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:reang_app/screens/layanan/info/detail_berita_screen.dart';
import 'package:reang_app/screens/layanan/info/jdih_screen.dart';
import 'package:reang_app/screens/layanan/info/cctv_screen.dart';

class InfoYuScreen extends StatefulWidget {
  const InfoYuScreen({super.key});

  @override
  State<InfoYuScreen> createState() => _InfoYuScreenState();
}

class _InfoYuScreenState extends State<InfoYuScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Berita>> _beritaFuture;

  int _selectedTabIndex = 0; // 0: Berita, 1: CCTV, 2: JDIH
  // PERUBAHAN: State untuk melacak apakah tab sudah pernah dibuka
  bool _isCctvInitiated = false;
  bool _isJdihInitiated = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Berita (satu-satunya yang dimuat di awal)
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _beritaFuture = _apiService.fetchBerita();
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
            const Text(
              'Info-yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Update terbaru dari Indramayu',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterChip(
                    context,
                    label: 'JDIH',
                    icon: Icons.balance,
                    index: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildBeritaView(),
                // WebView hanya akan dibuat jika _isCctvInitiated true
                _isCctvInitiated ? const CctvView() : Container(),
                // JDIH hanya akan dibuat jika _isJdihInitiated true
                _isJdihInitiated ? const JdihScreen() : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required int index,
  }) {
    final theme = Theme.of(context);
    final bool isSelected = _selectedTabIndex == index;
    final Color backgroundColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final Color foregroundColor = isSelected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          // PERUBAHAN: Logika untuk "lazy load"
          if (index == 1 && !_isCctvInitiated) {
            _isCctvInitiated = true;
          } else if (index == 2 && !_isJdihInitiated) {
            _isJdihInitiated = true;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: foregroundColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            onRefresh: () async =>
                setState(() => _beritaFuture = _apiService.fetchBerita()),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: beritaList.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: InfoCard(berita: beritaList[index]),
              ),
            ),
          );
        }
        return const Center(child: Text('Tidak ada berita tersedia.'));
      },
    );
  }
}

class InfoCard extends StatelessWidget {
  final Berita berita;
  const InfoCard({super.key, required this.berita});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailBeritaScreen(berita: berita),
        ),
      ),
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
