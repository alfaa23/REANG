import 'package:flutter/material.dart';
import 'package:reang_app/models/info_pajak_model.dart';
import 'package:reang_app/screens/layanan/pajak/cek_pajak_webview.dart';
import 'package:reang_app/screens/layanan/pajak/detail_pajak_screen.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html_unescape/html_unescape.dart'; // Import untuk membersihkan HTML

class PajakYuScreen extends StatefulWidget {
  const PajakYuScreen({super.key});
  @override
  State<PajakYuScreen> createState() => _PajakYuScreenState();
}

class _PajakYuScreenState extends State<PajakYuScreen> {
  int _selectedTab = 0;
  bool _isWebViewInitiated = false;

  // State untuk memanggil API
  final ApiService _apiService = ApiService();
  late Future<List<InfoPajak>> _infoPajakFuture;

  @override
  void initState() {
    super.initState();
    _loadInfoPajak();
  }

  void _loadInfoPajak() {
    _infoPajakFuture = _apiService.fetchInfoPajak();
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadInfoPajak();
    });
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
              'Pajak‑Yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Informasi dan pengecekan pajak daerah Indramayu',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Info Pajak', 'Cek Pajak'].asMap().entries.map((e) {
                final i = e.key;
                final label = e.value;
                final sel = i == _selectedTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedTab = i;
                      if (i == 1 && !_isWebViewInitiated) {
                        _isWebViewInitiated = true;
                      }
                    }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            color: sel
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildInfoPajakView(theme),
                _isWebViewInitiated ? const CekPajakWebView() : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPajakView(ThemeData theme) {
    return FutureBuilder<List<InfoPajak>>(
      future: _infoPajakFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Gagal memuat informasi.\nSilakan tarik ke bawah untuk mencoba lagi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
            ),
          );
        }
        final articles = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                'Informasi Seputar Pajak',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ketahui jenis pajak yang berlaku di daerah Anda dan cara mengurusnya.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 16),
              ...articles.map((a) => _ArticleCard(data: a)).toList(),
            ],
          ),
        );
      },
    );
  }
}

/// Kartu artikel pajak dengan tampilan baru
class _ArticleCard extends StatelessWidget {
  final InfoPajak data;
  const _ArticleCard({required this.data});

  // Fungsi untuk membersihkan tag HTML dari deskripsi
  String _getExcerpt(String htmlText) {
    final unescape = HtmlUnescape();
    // Menghapus tag HTML dan membersihkan entitas HTML
    final String text = htmlText.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
    // PERBAIKAN: Menambahkan .trim() untuk menghapus spasi di awal dan akhir
    return unescape.convert(text).trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String excerpt = _getExcerpt(data.deskripsi);

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPajakScreen(artikel: data),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              data.foto,
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
                  child: Center(
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: theme.hintColor,
                      size: 48,
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
                  Text(
                    data.kategori,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // PERBAIKAN: Menambahkan kembali deskripsi singkat
                  const SizedBox(height: 6),
                  Text(
                    excerpt,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.hintColor),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Bapenda Indramayu • ${timeago.format(data.tanggal, locale: 'id')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Lihat Selengkapnya ›',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
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
