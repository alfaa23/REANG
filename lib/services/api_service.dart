import 'package:dio/dio.dart';
import 'package:intl/intl.dart'; // Diperlukan untuk format tanggal
import 'package:reang_app/models/berita_model.dart';
import 'package:reang_app/models/jdih_model.dart';
import 'package:reang_app/models/artikel_sehat_model.dart';

/// Kelas ini bertanggung jawab untuk semua komunikasi dengan API eksternal.
class ApiService {
  final Dio _dio = Dio();

  // =======================================================================
  // API BERITA
  // =======================================================================
  final String _baseUrlBerita =
      'https://indramayukab.go.id/wp-json/wp/v2/posts?_embed';

  Future<List<Berita>> fetchBerita() async {
    try {
      final response = await _dio.get(_baseUrlBerita);
      if (response.statusCode == 200) {
        final List<Berita> beritaList = (response.data as List)
            .map((item) => Berita.fromJson(item))
            .toList();
        return beritaList;
      } else {
        throw Exception('Gagal memuat berita');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil berita: $e');
    }
  }

  // =======================================================================
  // API JDIH (Jaringan Dokumentasi dan Informasi Hukum)
  // =======================================================================
  final String _baseUrlJdih = 'https://jdih.indramayukab.go.id/api/integrasi';

  Future<List<PeraturanHukum>> fetchJdih() async {
    try {
      final response = await _dio.get(_baseUrlJdih);
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('data')) {
          final List<dynamic> data = response.data['data'];
          final List<PeraturanHukum> peraturanList = data
              .map((item) => PeraturanHukum.fromJson(item))
              .toList();
          return peraturanList;
        } else {
          throw Exception('Format data tidak sesuai');
        }
      } else {
        throw Exception('Gagal memuat data JDIH');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil data JDIH: $e');
    }
  }

  // =======================================================================
  // API WAKTU IBADAH (JADWAL SHOLAT)
  // Mengambil data dari Aladhan API berdasarkan kota dan tanggal.
  // =======================================================================
  Future<Map<String, String>> fetchJadwalSholat() async {
    try {
      // Mendapatkan tanggal hari ini dalam format dd-MM-yyyy
      final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final String url =
          'http://api.aladhan.com/v1/timingsByCity/$today?city=Indramayu&country=Indonesia&method=3';

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data['data'] != null) {
        // Langsung mengembalikan map 'timings'
        final timings =
            response.data['data']['timings'] as Map<String, dynamic>;
        // Mengonversi semua value menjadi String untuk keamanan
        return timings.map((key, value) => MapEntry(key, value.toString()));
      } else {
        throw Exception('Gagal memuat jadwal sholat');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil jadwal sholat: $e');
    }
  }

  // =======================================================================
  // API ARTIKEL KESEHATAN (BARU)
  // =======================================================================
  final String _baseUrlInfoSehat = 'http://192.168.255.91:8000/api/info-sehat';

  Future<List<ArtikelSehat>> fetchArtikelKesehatan() async {
    try {
      final response = await _dio.get(_baseUrlInfoSehat);
      if (response.statusCode == 200) {
        final List<ArtikelSehat> artikelList = (response.data as List)
            .map((item) => ArtikelSehat.fromJson(item))
            .toList();
        return artikelList;
      } else {
        throw Exception('Gagal memuat artikel kesehatan');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil artikel kesehatan: $e');
    }
  }
}
