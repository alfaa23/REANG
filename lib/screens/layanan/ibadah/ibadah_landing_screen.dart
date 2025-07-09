import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/ibadah/peta_ibadah_screen.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart'; // Import paket intl untuk format tanggal

// PERUBAHAN: Model disesuaikan untuk membaca API Al-Adhan
class JadwalSholat {
  final String subuh, dzuhur, ashar, maghrib, isya;
  JadwalSholat({
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory JadwalSholat.fromJson(Map<String, dynamic> json) {
    return JadwalSholat(
      subuh: json['Fajr'],
      dzuhur: json['Dhuhr'],
      ashar: json['Asr'],
      maghrib: json['Maghrib'],
      isya: json['Isha'],
    );
  }
}

class IbadahLandingScreen extends StatefulWidget {
  const IbadahLandingScreen({super.key});

  @override
  State<IbadahLandingScreen> createState() => _IbadahLandingScreenState();
}

class _IbadahLandingScreenState extends State<IbadahLandingScreen> {
  late Future<JadwalSholat> _futureJadwalSholat;

  @override
  void initState() {
    super.initState();
    _futureJadwalSholat = _fetchJadwalSholat();
  }

  // PERUBAHAN: Fungsi fetch data diubah untuk menggunakan API Al-Adhan
  Future<JadwalSholat> _fetchJadwalSholat() async {
    final dio = Dio();
    // Menggunakan tanggal hari ini untuk query
    final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // URL untuk API Al-Adhan kota Indramayu, Indonesia. Metode 3 = Muslim World League
    final url =
        'http://api.aladhan.com/v1/timingsByCity/$today?city=Indramayu&country=Indonesia&method=3';

    try {
      final response = await dio.get(url);
      // Cek status code dari API Al-Adhan
      if (response.statusCode == 200 && response.data['code'] == 200) {
        // Path data di API Al-Adhan adalah response.data['data']['timings']
        return JadwalSholat.fromJson(response.data['data']['timings']);
      } else {
        throw Exception('Gagal memuat data jadwal sholat dari API Al-Adhan.');
      }
    } on DioException catch (e) {
      throw Exception('Gagal terhubung ke server: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ibadah-yu'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _futureJadwalSholat = _fetchJadwalSholat();
          });
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner (Tidak ada perubahan)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ibadah-yu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Temukan tempat ibadah terdekat dan jadwal sholat hari ini. Mari tingkatkan kualitas ibadah kita dengan mudah dan praktis.',
                    style: TextStyle(color: Colors.white, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tempat Ibadah Terdekat',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PetaIbadahScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: theme.shadowColor.withOpacity(0.1),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.mosque_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cari lokasi tempat ibadah',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Jadwal Sholat Hari Ini (Indramayu)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<JadwalSholat>(
              future: _futureJadwalSholat,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Gagal memuat jadwal. Tarik untuk menyegarkan.',
                    ),
                  );
                }
                if (snapshot.hasData) {
                  final jadwal = snapshot.data!;
                  return Column(
                    children: [
                      _buildSholatTile('Subuh', jadwal.subuh, theme),
                      _buildSholatTile('Zuhur', jadwal.dzuhur, theme),
                      _buildSholatTile('Asar', jadwal.ashar, theme),
                      _buildSholatTile('Magrib', jadwal.maghrib, theme),
                      _buildSholatTile('Isya', jadwal.isya, theme),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSholatTile (Tidak ada perubahan)
  Widget _buildSholatTile(String title, String time, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
