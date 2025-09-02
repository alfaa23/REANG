import 'package:flutter/material.dart';
import 'package:reang_app/models/berita_pendidikan_model.dart';
import 'package:reang_app/screens/layanan/sekolah/detail_berita_pendidikan_screen.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html_unescape/html_unescape.dart'; // PENAMBAHAN BARU

class BeritaPendidikanView extends StatefulWidget {
  const BeritaPendidikanView({super.key});

  @override
  State<BeritaPendidikanView> createState() => _BeritaPendidikanViewState();
}

class _BeritaPendidikanViewState extends State<BeritaPendidikanView> {
  final ApiService _apiService = ApiService();
  Future<List<BeritaPendidikanModel>>? _beritaFuture;

  @override
  void initState() {
    super.initState();
    _loadBerita();
  }

  void _loadBerita() {
    setState(() {
      _beritaFuture = _apiService.fetchBeritaPendidikan();
    });
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  @override
  Widget build(BuildContext context) {
    if (_beritaFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<BeritaPendidikanModel>>(
      future: _beritaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Gagal memuat berita.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadBerita,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        final articles = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _BeritaCard(berita: articles[index]),
          ),
        );
      },
    );
  }
}

class _BeritaCard extends StatelessWidget {
  final BeritaPendidikanModel berita;
  const _BeritaCard({required this.berita});

  // PENAMBAHAN BARU: Fungsi untuk membersihkan HTML
  String _cleanHtml(String htmlString) {
    final unescape = HtmlUnescape();
    final String clean = htmlString.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
    return unescape.convert(clean);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // PERBAIKAN: Mengambil deskripsi bersih dari HTML
    final String cleanDescription = _cleanHtml(berita.deskripsi);

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailBeritaPendidikanScreen(artikel: berita),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              berita.foto,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 180,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.article_outlined,
                    color: theme.hintColor,
                    size: 48,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pendidikan', // Kategori statis
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    berita.judul,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // PERBAIKAN: Menambahkan deskripsi singkat 2 baris
                  Text(
                    cleanDescription,
                    style: TextStyle(color: theme.hintColor, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Dinas Pendidikan • ${timeago.format(berita.tanggal, locale: 'id')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      // PERBAIKAN: Spacer dan "Lihat Selengkapnya" dihapus
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
