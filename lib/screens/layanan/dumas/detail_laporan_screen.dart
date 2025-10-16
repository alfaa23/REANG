import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/models/dumas_model.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class DetailLaporanScreen extends StatefulWidget {
  final int dumasId;
  final bool isMyReport; // Flag untuk menandai ini laporan milik user

  const DetailLaporanScreen({
    super.key,
    required this.dumasId,
    this.isMyReport = false, // Defaultnya false
  });

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  final ApiService _apiService = ApiService();
  late Future<DumasModel> _dumasFuture;

  @override
  void initState() {
    super.initState();
    _loadDumasDetail();
  }

  // Fungsi untuk memuat data, akan dipanggil ulang setelah rating dikirim
  void _loadDumasDetail() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _dumasFuture = _apiService.fetchDumasDetail(
        widget.dumasId,
        token: auth.isLoggedIn ? auth.token : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DumasModel>(
        future: _dumasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat detail laporan.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadDumasDetail,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
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
                      _buildDynamicTimeline(theme, data),
                      // --- PERBAIKAN: Tampilkan bagian ulasan jika status selesai ---
                      if (data.status.toLowerCase() == 'selesai')
                        _buildFeedbackSection(context, theme, data),
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

  // --- PERBAIKAN: Logika diubah untuk menampilkan ulasan ke publik ---
  Widget _buildFeedbackSection(
    BuildContext context,
    ThemeData theme,
    DumasModel data,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ulasan Laporan', // Judul diubah menjadi lebih umum
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Jika ada rating, tampilkan ke semua orang
          if (data.userRating != null)
            _buildAlreadyRatedView(context, theme, data)
          // Jika belum ada rating, hanya pemilik laporan yang melihat prompt
          else if (widget.isMyReport)
            _buildGiveRatingPrompt(context, theme, data)
          // Jika belum ada rating dan bukan pemilik, tampilkan pesan
          else
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('Belum ada ulasan untuk laporan ini.'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Tampilan prompt untuk memberi ulasan
  Widget _buildGiveRatingPrompt(
    BuildContext context,
    ThemeData theme,
    DumasModel data,
  ) {
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Laporan Selesai Ditangani',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bantu kami meningkatkan kualitas layanan dengan memberikan penilaian Anda.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _showRatingBottomSheet(context, data),
              child: const Text('Beri Ulasan'),
            ),
          ],
        ),
      ),
    );
  }

  // --- PERBAIKAN: Tombol opsi sekarang kondisional ---
  Widget _buildAlreadyRatedView(
    BuildContext context,
    ThemeData theme,
    DumasModel data,
  ) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < (data.userRating ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 24,
                    );
                  }),
                ),
                // Hanya tampilkan tombol opsi jika ini laporan milik user
                if (widget.isMyReport && auth.isLoggedIn)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showRatingBottomSheet(context, data);
                      } else if (value == 'hapus') {
                        _showDeleteConfirmationDialog(context);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'hapus',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 20),
                                SizedBox(width: 8),
                                Text('Hapus'),
                              ],
                            ),
                          ),
                        ],
                    icon: Icon(Icons.more_vert, color: theme.hintColor),
                  ),
              ],
            ),
            if (data.userComment != null && data.userComment!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(data.userComment!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Ulasan?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus ulasan ini? Tindakan ini tidak dapat diurungkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _apiService.deleteDumasRating(
                  dumasId: widget.dumasId,
                  token: authProvider.token!,
                );
                showToast(
                  "Ulasan berhasil dihapus",
                  context: context,
                  backgroundColor: Colors.green,
                  position: StyledToastPosition.bottom,
                  animation: StyledToastAnimation.scale,
                  reverseAnimation: StyledToastAnimation.fade,
                  animDuration: const Duration(milliseconds: 150),
                  duration: const Duration(seconds: 2),
                  borderRadius: BorderRadius.circular(25),
                  textStyle: const TextStyle(color: Colors.white),
                  curve: Curves.fastOutSlowIn,
                );
                _loadDumasDetail();
              } catch (e) {
                showToast(
                  e.toString(),
                  context: context,
                  backgroundColor: Colors.red,
                  position: StyledToastPosition.bottom,
                  animation: StyledToastAnimation.scale,
                  reverseAnimation: StyledToastAnimation.fade,
                  animDuration: const Duration(milliseconds: 150),
                  duration: const Duration(seconds: 2),
                  borderRadius: BorderRadius.circular(25),
                  textStyle: const TextStyle(color: Colors.white),
                  curve: Curves.fastOutSlowIn,
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showRatingBottomSheet(BuildContext context, DumasModel data) {
    int tempRating = data.userRating ?? 0;
    final commentController = TextEditingController(
      text: data.userComment ?? '',
    );
    bool isSubmitting = false;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (contextSheet, setSheetState) {
              final bool canSubmit = tempRating > 0;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    data.userRating != null
                        ? 'Edit Ulasan Anda'
                        : 'Beri Ulasan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          i < tempRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setSheetState(() => tempRating = i + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'Ulasan (Opsional)',
                      hintText: 'Tuliskan ulasan Anda...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                              (states) =>
                                  states.contains(MaterialState.disabled)
                                  ? Colors.grey.shade300
                                  : Colors.blue.shade800,
                            ),
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                              (states) =>
                                  states.contains(MaterialState.disabled)
                                  ? Colors.black38
                                  : Colors.white,
                            ),
                      ),
                      onPressed: canSubmit && !isSubmitting
                          ? () async {
                              setSheetState(() => isSubmitting = true);
                              try {
                                await _apiService.postDumasRating(
                                  dumasId: widget.dumasId,
                                  rating: tempRating.toDouble(),
                                  comment: commentController.text,
                                  token: auth.token!,
                                );
                                showToast(
                                  "Ulasan Anda berhasil disimpan!",
                                  context: context,
                                  backgroundColor: Colors.green,
                                  position: StyledToastPosition.bottom,
                                  animation: StyledToastAnimation.scale,
                                  reverseAnimation: StyledToastAnimation.fade,
                                  animDuration: const Duration(
                                    milliseconds: 150,
                                  ),
                                  duration: const Duration(seconds: 2),
                                  borderRadius: BorderRadius.circular(25),
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  curve: Curves.fastOutSlowIn,
                                );
                                Navigator.of(ctx).pop(); // Close the modal
                                _loadDumasDetail(); // Refresh the detail page
                              } catch (e) {
                                showToast(
                                  "Gagal mengirim ulasan: ${e.toString()}",
                                  context: context,
                                  position: StyledToastPosition.bottom,
                                  animation: StyledToastAnimation.scale,
                                  reverseAnimation: StyledToastAnimation.fade,
                                  animDuration: const Duration(
                                    milliseconds: 150,
                                  ),
                                  duration: const Duration(seconds: 2),
                                  borderRadius: BorderRadius.circular(25),
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  curve: Curves.fastOutSlowIn,
                                );
                              } finally {
                                if (mounted) {
                                  setSheetState(() => isSubmitting = false);
                                }
                              }
                            }
                          : null,
                      child: isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Kirim Ulasan'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
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

  Widget _buildDynamicTimeline(ThemeData theme, DumasModel data) {
    final statusOrder = ['menunggu', 'diproses', 'selesai'];
    final currentStatus = data.status.toLowerCase();
    int currentStatusIndex = statusOrder.indexOf(currentStatus);

    if (currentStatus == 'ditolak') {
      return Column(
        children: [
          _TimelineEntry(
            dotColor: Colors.grey,
            title: 'Menunggu',
            subtitle: 'Laporan diterima oleh sistem',
            timestamp: timeago.format(data.createdAt, locale: 'id'),
          ),
          _TimelineEntry(
            dotColor: Colors.red,
            title: 'Ditolak',
            subtitle: 'Laporan ditolak oleh instansi terkait.',
            timestamp: timeago.format(data.createdAt, locale: 'id'),
            comment: data.tanggapan,
            isLast: true,
          ),
        ],
      );
    }

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
