import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/sekolah/detail_berita_pendidikan_screen.dart';

// Model data dummy untuk berita
class BeritaPendidikan {
  final String imagePath; // Ditambahkan
  final String title;
  final String excerpt;
  final String timeAgo;
  final String author; // Ditambahkan
  final String content; // Ditambahkan

  const BeritaPendidikan({
    required this.imagePath,
    required this.title,
    required this.excerpt,
    required this.timeAgo,
    required this.author,
    required this.content,
  });
}

class BeritaPendidikanView extends StatefulWidget {
  const BeritaPendidikanView({super.key});

  @override
  State<BeritaPendidikanView> createState() => _BeritaPendidikanViewState();
}

class _BeritaPendidikanViewState extends State<BeritaPendidikanView> {
  // Data dummy untuk tampilan awal (diperbarui dengan data lengkap)
  final List<BeritaPendidikan> _beritaList = const [
    BeritaPendidikan(
      imagePath: 'assets/images/artikel_ppdb.png',
      title: 'Tahun Ajaran Baru 2025/2026 Dimulai',
      excerpt:
          'Dinas Pendidikan Indramayu mengumumkan dimulainya tahun ajaran baru dengan beberapa penyesuaian kurikulum...',
      timeAgo: '1 hari yang lalu',
      author: 'Dinas Pendidikan',
      content:
          'Dinas Pendidikan Indramayu mengumumkan dimulainya tahun ajaran baru dengan beberapa penyesuaian kurikulum. Perubahan ini bertujuan untuk meningkatkan relevansi pendidikan dengan kebutuhan zaman sekarang.\n\nKepala Dinas Pendidikan menyatakan bahwa fokus utama adalah pada pengembangan keterampilan digital dan karakter siswa.',
    ),
    BeritaPendidikan(
      imagePath: 'assets/images/artikel_kurikulum.png',
      title: 'Lomba Cerdas Cermat Tingkat SMP Digelar',
      excerpt:
          'Puluhan sekolah menengah pertama berpartisipasi dalam lomba cerdas cermat tahunan yang diadakan di Pendopo...',
      timeAgo: '3 hari yang lalu',
      author: 'Disdik Indramayu',
      content:
          'Puluhan sekolah menengah pertama berpartisipasi dalam lomba cerdas cermat tahunan yang diadakan di Pendopo Kabupaten Indramayu. Acara ini bertujuan untuk mengasah kemampuan akademik dan sportivitas para siswa.',
    ),
    BeritaPendidikan(
      imagePath: 'assets/images/artikel_vaksin.png',
      title: 'Program Beasiswa untuk Siswa Berprestasi Dibuka',
      excerpt:
          'Pemerintah daerah membuka pendaftaran program beasiswa bagi siswa-siswi berprestasi di tingkat SMA/SMK...',
      timeAgo: '5 hari yang lalu',
      author: 'Admin Disdik',
      content:
          'Pemerintah daerah membuka pendaftaran program beasiswa bagi siswa-siswi berprestasi di tingkat SMA/SMK. Program ini mencakup bantuan biaya pendidikan hingga lulus serta program pembinaan khusus.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Untuk saat ini, kita gunakan ListView langsung dengan data dummy
    // Nanti bisa diganti dengan FutureBuilder jika sudah ada API
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _beritaList.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _BeritaCard(berita: _beritaList[index]),
      ),
    );
  }
}

// Widget kartu berita yang digabung di sini (private)
class _BeritaCard extends StatelessWidget {
  final BeritaPendidikan berita;
  const _BeritaCard({required this.berita});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        // PERBAIKAN: Navigasi ke halaman detail berita
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBeritaPendidikanScreen(
              // Mengirim data dalam format Map yang diharapkan oleh halaman detail
              articleData: {
                'imagePath': berita.imagePath,
                'title': berita.title,
                'author': berita.author,
                'waktu': berita.timeAgo,
                'content': berita.content,
              },
            ),
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
            // PERBAIKAN: Menampilkan gambar dari data
            Image.asset(
              berita.imagePath,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.hintColor,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Text(
                berita.timeAgo,
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
