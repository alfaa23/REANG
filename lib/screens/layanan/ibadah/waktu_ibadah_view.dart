import 'package:flutter/material.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class WaktuIbadahView extends StatefulWidget {
  const WaktuIbadahView({super.key});

  @override
  State<WaktuIbadahView> createState() => _WaktuIbadahViewState();
}

class _WaktuIbadahViewState extends State<WaktuIbadahView> {
  final ApiService _apiService = ApiService();

  /// Future yang pertama-tama menginisialisasi locale 'id_ID'
  /// lalu memanggil API jadwal sholat.
  late Future<Map<String, String>> _jadwalFuture;

  @override
  void initState() {
    super.initState();

    // Buat Future gabungan: inisialisasi locale, baru fetch jadwal
    _jadwalFuture = (() async {
      // Pastikan binding Flutter sudah siap jika dipanggil di luar main()
      // WidgetsFlutterBinding.ensureInitialized();

      // Inisialisasi data locale untuk 'id_ID'
      await initializeDateFormatting('id_ID', null);

      // Setelah locale siap, panggil API
      return await _apiService.fetchJadwalSholat();
    })();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _jadwalFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Tidak ada jadwal tersedia.'));
        }

        // Data sudah ada
        final jadwal = snapshot.data!;
        final List<Map<String, dynamic>> jadwalSholat = [
          {
            "nama": "Shubuh",
            "waktu": jadwal['Fajr'],
            "icon": Icons.wb_twilight_outlined,
          },
          {
            "nama": "Zuhur",
            "waktu": jadwal['Dhuhr'],
            "icon": Icons.wb_sunny_outlined,
          },
          {
            "nama": "Ashar",
            "waktu": jadwal['Asr'],
            "icon": Icons.brightness_6_outlined,
          },
          {
            "nama": "Maghrib",
            "waktu": jadwal['Maghrib'],
            "icon": Icons.wb_cloudy_outlined,
          },
          {
            "nama": "Isya",
            "waktu": jadwal['Isha'],
            "icon": Icons.nights_stay_outlined,
          },
        ];

        return _buildContentView(context, jadwalSholat);
      },
    );
  }

  Widget _buildContentView(
    BuildContext context,
    List<Map<String, dynamic>> jadwalSholat,
  ) {
    final theme = Theme.of(context);

    // Sekarang locale 'id_ID' sudah ter-initialize
    final String tanggalHariIni = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Jadwal Sholat Hari Ini",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tanggalHariIni,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 16, color: theme.hintColor),
                    const SizedBox(width: 4),
                    Text(
                      "Indramayu, Indonesia",
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...jadwalSholat.map((item) => _buildJadwalTile(theme, item)),
      ],
    );
  }

  Widget _buildJadwalTile(ThemeData theme, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(item['icon'], color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Text(
            item['nama']!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            item['waktu']!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
