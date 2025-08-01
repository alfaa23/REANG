import 'package:flutter/material.dart';

class DetailEventScreen extends StatelessWidget {
  const DetailEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Kajian Tafsir Al-Quran",
                style: TextStyle(fontSize: 16),
              ),
              background: Container(
                color:
                    theme.colorScheme.primary, // Ganti dengan gambar jika ada
                child: const Center(
                  child: Icon(Icons.event, color: Colors.white, size: 80),
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
                    Row(
                      children: [
                        Icon(Icons.article, size: 18, color: theme.hintColor),
                        const SizedBox(width: 8),
                        Text(
                          "2 jam lalu",
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Kementrian Agama",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            theme,
                            Icons.calendar_month,
                            "Waktu:",
                            "Senin, 15 Januari 2024",
                          ),
                          _buildDetailRow(
                            theme,
                            Icons.access_time,
                            "",
                            "19:30 WIB s/d selesai",
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            theme,
                            Icons.mosque,
                            "Lokasi:",
                            "Masjid Al-Ikhlas",
                          ),
                          _buildDetailRow(
                            theme,
                            Icons.location_on,
                            "",
                            "KAB. Indramayu KEC. Balongan Desa Tegal Lurung",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Deskripsi:",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "- Kajian rutin setiap Senin malam tentang tafsir Al-Qur’an.\n- Terbuka untuk umum, membawa Al-Qur’an pribadi sangat dianjurkan.\n- Disampaikan oleh Ustadz pembimbing dari Kemenag.",
                      style: TextStyle(height: 1.5),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.hintColor),
          const SizedBox(width: 8),
          if (title.isNotEmpty)
            Text(
              "$title ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
