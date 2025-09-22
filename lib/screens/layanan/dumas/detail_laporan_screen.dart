import 'package:flutter/material.dart';
import 'package:reang_app/models/dumas_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class DetailLaporanScreen extends StatelessWidget {
  final int dumasId;
  const DetailLaporanScreen({super.key, required this.dumasId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DumasModel>(
        future: ApiService().fetchDumasDetail(dumasId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Gagal memuat detail laporan.'));
          }

          final data = snapshot.data!;
          final theme = Theme.of(context);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, theme, data),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(theme, data),
                      const SizedBox(height: 24),
                      _buildDetailInfo(theme, data),
                      const SizedBox(height: 24),
                      Text(
                        'Status Laporan',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // --- PERBAIKAN: Timeline sekarang dinamis ---
                      _buildDynamicTimeline(theme, data),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    ThemeData theme,
    DumasModel data,
  ) {
    return SliverAppBar(
      expandedHeight: 240.0,
      pinned: true,
      stretch: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.5),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Kembali',
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: (data.buktiLaporan != null && data.buktiLaporan!.isNotEmpty)
            ? Image.network(
                data.buktiLaporan!,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _buildImageError(theme),
              )
            : _buildImageError(theme),
      ),
    );
  }

  Widget _buildImageError(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: theme.hintColor,
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, DumasModel data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                  Text('#${data.id}'),
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
                      Text(data.status),
                      const SizedBox(width: 6),
                      Icon(Icons.circle, size: 12, color: data.statusColor),
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

  Widget _buildDetailInfo(ThemeData theme, DumasModel data) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(theme, 'Judul Laporan:', data.jenisLaporan),
          _buildDetailRow(theme, 'Kategori:', data.kategoriLaporan),
          _buildDetailRow(theme, 'Alamat:', data.lokasiLaporan),
          _buildDetailRow(theme, 'Deskripsi:', data.deskripsi, isLast: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    String title,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
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

  // --- FUNGSI BARU: Untuk membangun timeline secara dinamis ---
  Widget _buildDynamicTimeline(ThemeData theme, DumasModel data) {
    final statusOrder = ['menunggu', 'diproses', 'selesai'];
    final currentStatus = data.status.toLowerCase();
    int currentStatusIndex = statusOrder.indexOf(currentStatus);

    // Jika statusnya ditolak, tampilkan 'Menunggu' dan 'Ditolak'
    if (currentStatus == 'ditolak') {
      return Column(
        children: [
          _TimelineEntry(
            dotColor: Colors.grey, // Menunggu dianggap selesai
            title: 'Menunggu',
            subtitle: 'Laporan diterima oleh sistem',
            timestamp: timeago.format(data.createdAt, locale: 'id'),
          ),
          _TimelineEntry(
            dotColor: Colors.red,
            title: 'Ditolak',
            subtitle: 'Laporan ditolak oleh instansi terkait.',
            timestamp: timeago.format(
              data.createdAt,
              locale: 'id',
            ), // Gunakan tanggal yang sama jika tidak ada tanggal update
            comment: data.tanggapan,
            isLast: true,
          ),
        ],
      );
    }

    // Jika status tidak dikenali atau tidak ada di urutan
    if (currentStatusIndex == -1) {
      return _TimelineEntry(
        dotColor: data.statusColor,
        title: data.status,
        subtitle: 'Status laporan saat ini.',
        timestamp: timeago.format(data.createdAt, locale: 'id'),
        isLast: true,
      );
    }

    final List<Map<String, dynamic>> timelineConfig = [
      {
        'status': 'Menunggu',
        'subtitle': 'Laporan diterima oleh sistem',
        'color': Colors.orange,
      },
      {
        'status': 'Diproses',
        'subtitle': 'Laporan sedang ditindaklanjuti oleh instansi terkait',
        'color': Colors.blue,
      },
      {
        'status': 'Selesai',
        'subtitle': 'Laporan telah selesai ditindaklanjuti',
        'color': Colors.green,
      },
    ];

    return Column(
      children: List.generate(currentStatusIndex + 1, (index) {
        final step = timelineConfig[index];
        final bool isLast = index == currentStatusIndex;

        return _TimelineEntry(
          dotColor: isLast ? step['color'] : Colors.grey,
          title: step['status'],
          subtitle: step['subtitle'],
          timestamp: timeago.format(data.createdAt, locale: 'id'),
          isLast: isLast,
          comment: (isLast) ? data.tanggapan : null,
        );
      }),
    );
  }
}

// --- Widget Timeline Entry (Tidak Berubah) ---
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
              Container(width: 2, height: 120, color: theme.dividerColor),
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
              if (comment != null && comment!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
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
