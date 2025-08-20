import 'package:flutter/material.dart';

// Model data dummy untuk berita
class BeritaPendidikan {
  final String title;
  final String excerpt;
  final String timeAgo;

  const BeritaPendidikan({
    required this.title,
    required this.excerpt,
    required this.timeAgo,
  });
}

class BeritaPendidikanView extends StatefulWidget {
  const BeritaPendidikanView({super.key});

  @override
  State<BeritaPendidikanView> createState() => _BeritaPendidikanViewState();
}

class _BeritaPendidikanViewState extends State<BeritaPendidikanView> {
  // Data dummy untuk tampilan awal
  final List<BeritaPendidikan> _beritaList = const [
    BeritaPendidikan(
      title: 'Tahun Ajaran Baru 2025/2026 Dimulai',
      excerpt:
          'Dinas Pendidikan Indramayu mengumumkan dimulainya tahun ajaran baru dengan beberapa penyesuaian kurikulum...',
      timeAgo: '1 hari yang lalu',
    ),
    BeritaPendidikan(
      title: 'Lomba Cerdas Cermat Tingkat SMP Digelar',
      excerpt:
          'Puluhan sekolah menengah pertama berpartisipasi dalam lomba cerdas cermat tahunan yang diadakan di Pendopo...',
      timeAgo: '3 hari yang lalu',
    ),
    BeritaPendidikan(
      title: 'Program Beasiswa untuk Siswa Berprestasi Dibuka',
      excerpt:
          'Pemerintah daerah membuka pendaftaran program beasiswa bagi siswa-siswi berprestasi di tingkat SMA/SMK...',
      timeAgo: '5 hari yang lalu',
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
        // TODO: Navigasi ke halaman detail berita
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder untuk gambar (sesuai permintaan)
            Container(
              height: 180,
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  color: theme.hintColor,
                  size: 48,
                ),
              ),
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
