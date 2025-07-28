import 'package:flutter/material.dart';

class DetailLaporanScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const DetailLaporanScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Gunakan null-aware operator agar tidak error
    final String imageUrl = data['imagePath'] as String? ?? '';
    final String id = data['id'] as String? ?? '-';
    final String status = data['status'] as String? ?? '-';
    final Color statusColor = data['statusColor'] as Color? ?? Colors.grey;
    final String title = data['title'] as String? ?? '-';
    final String category = data['category'] as String? ?? '-';
    final String address = data['address'] as String? ?? '-';
    final String description = data['description'] as String? ?? '-';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Stack(
                children: [
                  Image.asset(
                    imageUrl,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 240,
                        color: theme.colorScheme.surface,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: theme.hintColor,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ID & Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID Laporan',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(id),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(status),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: statusColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(theme, 'Judul Laporan:', title),
                      _buildDetailRow(theme, 'Kategori:', category),
                      _buildDetailRow(theme, 'Alamat:', address),
                      _buildDetailRow(theme, 'Deskripsi:', description),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Laporan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TimelineEntry(
                      dotColor: Colors.green,
                      title: 'Selesai',
                      subtitle:
                          'Laporan dinyatakan selesai oleh BIRO PEMERINTAHAN',
                      timestamp: '24 Jul 2025 • 08:46',
                      comment:
                          'Komentar petugas: tindak lanjut sudah sesuai dengan laporan. terima kasih',
                    ),
                    _TimelineEntry(
                      dotColor: Colors.blue,
                      title: 'Validasi',
                      subtitle:
                          'Tindak lanjut laporan sedang divalidasi oleh BIRO PEMERINTAHAN',
                      timestamp: '23 Jul 2025 • 19:40',
                    ),
                    _TimelineEntry(
                      dotColor: Colors.red,
                      title: 'Menunggu',
                      subtitle: 'Laporan diterima oleh KELURAHAN PEGADUNGAN',
                      timestamp: '27 Jul 2025 • 18:45',
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final Color dotColor;
  final String title;
  final String subtitle;
  final String timestamp;
  final String? comment;
  final bool isLast;

  const _TimelineEntry({
    required this.dotColor,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.comment,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 100, color: theme.dividerColor),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dotColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                timestamp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              if (comment != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(comment!, style: theme.textTheme.bodyMedium),
                ),
              ],
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
