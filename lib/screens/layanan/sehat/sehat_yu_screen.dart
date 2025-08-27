// File: lib/screens/layanan/sehat/sehat_yu_screen.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:reang_app/models/artikel_sehat_model.dart';
import 'package:reang_app/screens/layanan/sehat/detail_artikel_screen.dart';
import 'package:reang_app/screens/layanan/sehat/konsultasi_dokter_screen.dart';
import 'package:reang_app/screens/peta/peta_screen.dart';
import 'package:reang_app/models/lokasi_peta_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

/// SehatYuScreen (full) with robust image loading for artikel cards.
class SehatYuScreen extends StatefulWidget {
  const SehatYuScreen({super.key});

  @override
  State<SehatYuScreen> createState() => _SehatYuScreenState();
}

class _SehatYuScreenState extends State<SehatYuScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<ArtikelSehat>> _artikelFuture;

  @override
  void initState() {
    super.initState();
    _loadArtikel();
  }

  void _loadArtikel() {
    _artikelFuture = _apiService.fetchArtikelKesehatan();
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadArtikel();
    });
    try {
      await _artikelFuture;
    } catch (_) {}
  }

  // PENAMBAHAN BARU: Fungsi untuk membuka peta
  void _openMap(BuildContext context, String type) async {
    try {
      // Tampilkan dialog loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      List<Map<String, dynamic>> dataLokasi;
      String judulHalaman;
      IconData icon;
      Color color;

      if (type == 'hospital') {
        // PERBAIKAN: Endpoint diubah menjadi 'hospital'
        dataLokasi = await _apiService.fetchLokasiPeta('hospital');
        judulHalaman = 'Peta Rumah Sakit';
        icon = Icons.local_hospital_outlined;
        color = Colors.blue;
      } else {
        dataLokasi = await _apiService.fetchLokasiPeta('sehat-olahraga');
        judulHalaman = 'Peta Tempat Olahraga';
        icon = Icons.sports_soccer_outlined;
        color = Colors.orange;
      }

      final List<LokasiPeta> daftarLokasi = dataLokasi.map((data) {
        return LokasiPeta(
          nama: data['name'] ?? 'Tanpa Nama',
          alamat: data['address'] ?? 'Tanpa Alamat',
          lokasi: LatLng(
            double.tryParse(data['latitude'].toString()) ?? 0.0,
            double.tryParse(data['longitude'].toString()) ?? 0.0,
          ),
          fotoUrl: data['foto'],
          icon: icon,
          warna: color,
        );
      }).toList();

      Navigator.of(context).pop(); // Tutup dialog loading

      if (daftarLokasi.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data lokasi tidak ditemukan.')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PetaScreen(
            daftarLokasi: daftarLokasi,
            judulHalaman: judulHalaman,
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Tutup dialog loading jika error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data peta: $e')));
    }
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
              'Sehat-Yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Layanan Kesehatan Digital',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            _buildInfoLokasi(theme),
            _buildSectionTitle(theme, 'Layanan Utama'),
            _buildLayananUtama(context, theme),
            _buildSectionTitle(theme, 'Artikel Kesehatan'),
            _buildArtikelKesehatan(theme),
            _buildSectionTitle(theme, 'Aplikasi Rekomendasi'),
            _buildAplikasiRekomendasi(),
            _buildSectionTitle(theme, 'Informasi Layanan'),
            _buildInformasiLayanan(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLokasi(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temukan informasi dan lokasi fasilitas kesehatan seperti rumah sakit, puskesmas, dan apotek di sekitar Anda. Dapatkan juga edukasi seputar gaya hidup sehat dengan mudah di sini.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLayananUtama(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _LayananCard(
                    icon: Icons.local_hospital_outlined,
                    title: 'Rumah Sakit Terdekat',
                    subtitle: '24 tersedia',
                    color: Colors.blue,
                    onTap: () => _openMap(context, 'hospital'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LayananCard(
                    icon: Icons.sports_soccer_outlined,
                    title: 'Tempat Olahraga',
                    subtitle: '12 tersedia',
                    color: Colors.orange,
                    onTap: () => _openMap(context, 'olahraga'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _LayananCard(
            icon: Icons.chat_bubble_outline,
            title: 'Konsultasi Dokter Berdasarkan Puskesmas',
            subtitle: '8 tersedia',
            isFullWidth: true,
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KonsultasiDokterScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArtikelKesehatan(ThemeData theme) {
    return FutureBuilder<List<ArtikelSehat>>(
      future: _artikelFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Gagal memuat artikel.\nSilakan tarik ke bawah untuk mencoba lagi.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final articles = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: articles.map((data) => _ArtikelCard(data: data)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAplikasiRekomendasi() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _RekomendasiCard(
            logoPath: 'assets/logos/halodoc.webp',
            title: 'Halodoc',
            subtitle: 'Konsultasi dokter online 24/7',
            appUrlScheme: 'halodoc://',
            storeUrl:
                'https://play.google.com/store/apps/details?id=com.linkdokter.halodoc.android', // iOS: https://apps.apple.com/app/id1067217981
          ),
          _RekomendasiCard(
            logoPath: 'assets/logos/mobilejkn.webp',
            title: 'Mobile JKN',
            subtitle: 'Layanan BPJS Kesehatan',
            appUrlScheme: 'mobilejkn://', // Contoh, mungkin perlu disesuaikan
            storeUrl:
                'https://play.google.com/store/apps/details?id=app.bpjs.mobile', // iOS: https://apps.apple.com/app/id1237601115
          ),
          _RekomendasiCard(
            logoPath: 'assets/logos/alodokter.webp',
            title: 'Alodokter',
            subtitle: 'Informasi kesehatan terpercaya',
            appUrlScheme: 'alodokter://',
            storeUrl:
                'https://play.google.com/store/apps/details?id=com.alodokter.android', // iOS: https://apps.apple.com/app/id1405482962
          ),
        ],
      ),
    );
  }

  Widget _buildInformasiLayanan(BuildContext context) {
    const infoItems = [
      {
        'icon': Icons.access_time_outlined,
        'title': 'Jam Operasional',
        'lines': [
          'Senin - Jumat: 08:00 - 16:00',
          'Sabtu: 08:00 - 12:00',
          'Minggu: Tutup',
        ],
      },
      {
        'icon': Icons.phone_outlined,
        'title': 'Kontak Bantuan',
        'lines': [
          'Telepon: (0234) 1234567',
          'WhatsApp: 0812-3456-7890',
          'Email: adminduk@desa.go.id',
        ],
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Lokasi Kantor',
        'lines': [
          'Jl. Ir. H. Juanda No.1, Singajaya, Kec. Indramayu, Jawa Barat 45218',
        ],
      },
      {
        'icon': Icons.lightbulb_outline,
        'title': 'Tips',
        'lines': [
          'Tulis keluhan dengan jelas',
          'Sebutkan sudah berapa lama sakit',
          'Lampirkan foto jika perlu',
        ],
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _InfoCard(data: infoItems[0])),
                const SizedBox(width: 12),
                Expanded(child: _InfoCard(data: infoItems[1])),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _InfoCard(data: infoItems[2])),
                const SizedBox(width: 12),
                Expanded(child: _InfoCard(data: infoItems[3])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- small widgets (unchanged) ---
class _LayananCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFullWidth;
  final VoidCallback? onTap;
  final Color? color;

  const _LayananCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isFullWidth = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.cardColor;
    final contentColor = cardColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isFullWidth
              ? Row(
                  children: [
                    _buildIcon(theme, contentColor),
                    const SizedBox(width: 12),
                    Expanded(child: _buildText(theme, contentColor)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIcon(theme, contentColor),
                    const SizedBox(height: 12),
                    _buildText(theme, contentColor),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 24, color: iconColor),
    );
  }

  Widget _buildText(ThemeData theme, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// --- Download Queue to throttle concurrent downloads ---
class _DownloadQueue {
  static int _active = 0;
  static const int _maxActive = 4; // batasi concurrent download
  static final List<Completer<void>> _waiters = [];

  static Future<void> acquire() async {
    if (_active < _maxActive) {
      _active++;
      return;
    }
    final c = Completer<void>();
    _waiters.add(c);
    await c.future;
    _active++;
  }

  static void release() {
    _active = max(0, _active - 1);
    if (_waiters.isNotEmpty) {
      final c = _waiters.removeAt(0);
      if (!c.isCompleted) c.complete();
    }
  }
}

class RobustNetworkImageWithDio extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final int maxAttempts;
  final Duration baseDelay;
  final Map<String, String>? headers;

  const RobustNetworkImageWithDio({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.maxAttempts = 5, // lebih sabar: 5 percobaan
    this.baseDelay = const Duration(seconds: 1),
    this.headers,
    super.key,
  });

  @override
  State<RobustNetworkImageWithDio> createState() =>
      _RobustNetworkImageWithDioState();
}

class _RobustNetworkImageWithDioState extends State<RobustNetworkImageWithDio> {
  final Dio _dio = Dio();
  Uint8List? _bytes;
  bool _loading = false;
  bool _error = false; // sekarang dipakai di build
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  @override
  void didUpdateWidget(covariant RobustNetworkImageWithDio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.headers != widget.headers) {
      _resetAndStart();
    }
  }

  void _resetAndStart() {
    _cancelToken?.cancel("updated");
    _bytes = null;
    _error = false;
    _loading = false;
    _startDownload();
  }

  Future<void> _startDownload() async {
    // pastikan state loading true saat mulai
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = false;
    });

    _cancelToken = CancelToken();

    for (int attempt = 1; attempt <= widget.maxAttempts && mounted; attempt++) {
      await _DownloadQueue.acquire();
      bool released = false;
      try {
        // tambahkan param retry agar bypass cache jika perlu
        final uri = Uri.parse(widget.imageUrl);
        final urlWithRetry = uri
            .replace(
              queryParameters: {
                ...uri.queryParameters,
                'v': DateTime.now().millisecondsSinceEpoch.toString(),
              },
            )
            .toString();

        final response = await _dio.get<List<int>>(
          urlWithRetry,
          options: Options(
            responseType: ResponseType.bytes,
            sendTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers:
                widget.headers ??
                {
                  'Cache-Control': 'no-cache, no-store, must-revalidate',
                  'Pragma': 'no-cache',
                },
            validateStatus: (s) => s != null && s >= 200 && s < 400,
          ),
          cancelToken: _cancelToken,
        );

        final data = Uint8List.fromList(response.data ?? <int>[]);
        if (data.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _bytes = data;
            _loading = false;
            _error = false;
          });
          // release dan keluar
          _DownloadQueue.release();
          released = true;
          return;
        } else {
          // anggap error — biarkan retry logic menangani
        }
      } catch (e) {
        if (!mounted) {
          if (!released) _DownloadQueue.release();
          return;
        }
        if (_cancelToken != null && _cancelToken!.isCancelled) {
          if (!released) _DownloadQueue.release();
          return;
        }
        if (attempt == widget.maxAttempts) {
          if (mounted) {
            setState(() {
              _error = true;
              _loading = false;
            });
          }
          if (!released) _DownloadQueue.release();
          return;
        } else {
          // backoff before next attempt
          final backoffMillis =
              widget.baseDelay.inMilliseconds * pow(2, attempt - 1);
          if (!released) _DownloadQueue.release();
          await Future.delayed(Duration(milliseconds: backoffMillis.toInt()));
          continue;
        }
      } finally {
        // jika belum direlease di blok diatas, release sekarang
        if (!released) {
          try {
            _DownloadQueue.release();
          } catch (_) {}
        }
      }
    }
  }

  void _retryDownload() {
    if (!mounted) return;
    setState(() {
      _bytes = null;
      _loading = false;
      _error = false;
    });
    _startDownload();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        height: widget.height,
        width: widget.width ?? double.infinity,
        fit: widget.fit,
        gaplessPlayback: true,
      );
    }

    // Jika sedang loading → tunjukkan spinner
    if (_loading && !_error) {
      return Container(
        height: widget.height,
        width: widget.width ?? double.infinity,
        color: theme.colorScheme.surfaceVariant,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Jika error → tunjukkan broken image + teks retry (penggunaan _error supaya analyzer senang)
    if (_error) {
      return GestureDetector(
        onTap: _retryDownload,
        child: Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          color: theme.colorScheme.surfaceVariant,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: theme.hintColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ketuk untuk coba lagi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // fallback (seharusnya jarang terjadi karena kita set _loading true saat mulai)
    return Container(
      height: widget.height,
      width: widget.width ?? double.infinity,
      color: theme.colorScheme.surfaceVariant,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// --- Artikel card using RobustNetworkImageWithDio ---
class _ArtikelCard extends StatelessWidget {
  final ArtikelSehat data;
  const _ArtikelCard({required this.data});

  String _noCacheUrl(String url) {
    if (url.isEmpty) return url;
    // gunakan url apa adanya — downloader akan menambahkan param v
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawUrl = _noCacheUrl(data.foto);

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => DetailArtikelScreen(artikel: data)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rawUrl.isNotEmpty)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: RobustNetworkImageWithDio(
                  imageUrl: rawUrl,
                  height: 160,
                  width: double.infinity,
                ),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        timeago.format(data.tanggal, locale: 'id'),
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

// PERBAIKAN: Widget ini diubah untuk menangani logika pembukaan aplikasi
class _RekomendasiCard extends StatelessWidget {
  final String logoPath, title, subtitle, appUrlScheme, storeUrl;

  const _RekomendasiCard({
    required this.logoPath,
    required this.title,
    required this.subtitle,
    required this.appUrlScheme,
    required this.storeUrl,
  });

  Future<void> _launchAppOrStore() async {
    final appUri = Uri.parse(appUrlScheme);
    final storeUri = Uri.parse(storeUrl);

    if (await canLaunchUrl(appUri)) {
      // Jika bisa membuka skema URL, buka aplikasinya
      await launchUrl(appUri);
    } else {
      // Jika tidak, buka Play Store/App Store
      await launchUrl(storeUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _launchAppOrStore, // Menjalankan fungsi saat diklik
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // PERBAIKAN: Menambahkan ClipRRect untuk membuat sudut melengkung
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  logoPath,
                  width: 48,
                  height: 48,
                  errorBuilder: (c, e, s) =>
                      const SizedBox(width: 48, height: 48),
                ),
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
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating dihapus sesuai permintaan
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _InfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data['icon'] as IconData,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              data['title'] as String,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ...List<Widget>.from(
              (data['lines'] as List<String>).map(
                (line) => Text(
                  line,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
