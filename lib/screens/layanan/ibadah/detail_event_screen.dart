import 'package:flutter/material.dart';

class DetailEventScreen extends StatelessWidget {
  // final Map<String, dynamic> eventData; // Nanti akan menerima data event
  const DetailEventScreen({super.key /*, required this.eventData*/});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Data dummy untuk contoh, nanti akan diganti dari eventData
    const String title = "Kajian Tafsir Al-Quran";
    const String author = "Kementerian Agama";
    const String timeAgo = "2 jam lalu";
    const String date = "Senin, 15 Januari 2024";
    const String time = "19:30 WIB s/d selesai";
    const String placeName = "Masjid Al-Ikhlas";
    const String address = "KAB. Indramayu KEC. Balongan Desa Tegal Lurung";
    const String description =
        "- Kajian rutin setiap Senin malam tentang tafsir Al-Qur’an.\n- Terbuka untuk umum, membawa Al-Qur’an pribadi sangat dianjurkan.\n- Disampaikan oleh Ustadz pembimbing dari Kemenag.";
    const String imagePath =
        'assets/images/kajian_banner.png'; // Ganti dengan path gambar Anda

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header dengan gambar event
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              // PERBAIKAN: Judul dihapus dari FlexibleSpaceBar
              background: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: theme.colorScheme.primary,
                  child: Center(
                    child: Icon(
                      Icons.event,
                      color: theme.colorScheme.onPrimary,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Konten utama
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PERBAIKAN: Judul dipindahkan ke sini
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Penyelenggara
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.corporate_fare,
                            size: 22,
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              timeAgo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Kotak Informasi Waktu & Lokasi
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              theme,
                              Icons.calendar_month_outlined,
                              "Waktu",
                              "$date\n$time",
                            ),
                            const Divider(height: 24),
                            _buildDetailRow(
                              theme,
                              Icons.location_on_outlined,
                              "Lokasi",
                              "$placeName\n$address",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Deskripsi
                    Text(
                      "Deskripsi",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk membuat baris detail yang lebih rapi
  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: theme.hintColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                // PERBAIKAN: Warna diubah dari hintColor dan ukuran disesuaikan
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
