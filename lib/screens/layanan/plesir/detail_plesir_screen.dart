import 'package:flutter/material.dart';

class DetailPlesirScreen extends StatelessWidget {
  // PERBAIKAN: Menerima data destinasi dari halaman sebelumnya
  final Map<String, dynamic> destinationData;
  const DetailPlesirScreen({super.key, required this.destinationData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mengambil data dari map yang dikirim
    final String title = destinationData['title'] ?? 'Detail Wisata';
    final String locationName = destinationData['name'] ?? 'Lokasi';
    final String address =
        destinationData['location'] ?? 'Alamat tidak tersedia';
    final String description =
        destinationData['description'] ?? 'Deskripsi tidak tersedia.';
    final String imagePath =
        'assets/images/pantai_balongan.png'; // Ganti dengan path gambar dinamis jika ada

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: theme.colorScheme.surface,
                  child: Center(
                    child: Text(
                      'Article Image',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              theme,
                              Icons.location_on,
                              "Lokasi:",
                              "$locationName\n$address",
                            ),
                            const Divider(height: 32),
                            _buildDetailRow(
                              theme,
                              Icons.description,
                              "Deskripsi:",
                              description,
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Aksi untuk membuka peta
                                },
                                icon: const Icon(Icons.map_outlined, size: 18),
                                label: const Text('Lihat Lokasi di Peta'),
                                style: ElevatedButton.styleFrom(
                                  // PERUBAHAN: Mengubah warna tombol
                                  backgroundColor: Colors.blue.shade800,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Rating dan Ulasan",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRatingSummary(
                      theme,
                      destinationData['rating'] ?? 0.0,
                    ),
                    const Divider(height: 32),
                    _buildUlasan(
                      theme,
                      "Rimba",
                      "24/07/25",
                      "Tempatnya indah dan bagus, cocok untuk liburan bareng keluarga. Pemandangannya juga sangat memukau.",
                    ),
                    const SizedBox(height: 16),
                    _buildUlasan(
                      theme,
                      "Siti",
                      "22/07/25",
                      "Akses jalannya mudah dan pantainya bersih. Sangat direkomendasikan!",
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

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSummary(ThemeData theme, double rating) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                if (rating >= index + 1) {
                  return const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 22,
                  );
                } else if (rating > index) {
                  return const Icon(
                    Icons.star_half_rounded,
                    color: Colors.amber,
                    size: 22,
                  );
                }
                return const Icon(
                  Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 22,
                );
              }),
            ),
            const SizedBox(height: 2),
            Text(
              "dari 120 ulasan",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUlasan(
    ThemeData theme,
    String nama,
    String tanggal,
    String ulasan,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(nama[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      nama,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tanggal,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ulasan,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
