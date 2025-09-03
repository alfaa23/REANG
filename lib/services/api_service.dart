import 'package:dio/dio.dart';
import 'package:intl/intl.dart'; // Diperlukan untuk format tanggal
import 'package:reang_app/models/berita_model.dart';
import 'package:reang_app/models/jdih_model.dart';
import 'package:reang_app/models/artikel_sehat_model.dart';
import 'package:reang_app/models/info_pajak_model.dart';
import 'package:reang_app/models/sekolah_model.dart';
import 'package:reang_app/models/berita_pendidikan_model.dart';

/// Kelas ini bertanggung jawab untuk semua komunikasi dengan API eksternal.
class ApiService {
  final Dio _dio = Dio();

  // =======================================================================
  // KONFIGURASI BASE URL
  // =======================================================================
  // Backend lokal
  final String _baseUrlBackend = 'https://d8e86de997f9.ngrok-free.app/api';

  // =======================================================================
  // API BERITA (EKSTERNAL)
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
  // API JDIH (EKSTERNAL)
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
  // API WAKTU IBADAH (EKSTERNAL)
  // =======================================================================
  Future<Map<String, String>> fetchJadwalSholat() async {
    try {
      final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final String url =
          'http://api.aladhan.com/v1/timingsByCity/$today?city=Indramayu&country=Indonesia&method=3';

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data['data'] != null) {
        final timings =
            response.data['data']['timings'] as Map<String, dynamic>;
        return timings.map((key, value) => MapEntry(key, value.toString()));
      } else {
        throw Exception('Gagal memuat jadwal sholat');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil jadwal sholat: $e');
    }
  }

  // =======================================================================
  // API ARTIKEL KESEHATAN (LOKAL)
  // =======================================================================
  Future<List<ArtikelSehat>> fetchArtikelKesehatan() async {
    try {
      // PERBAIKAN: Menggunakan _baseUrlBackend
      final response = await _dio.get('$_baseUrlBackend/info-sehat');
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

  // =======================================================================
  // API LOKASI PETA (LOKAL)
  // =======================================================================
  Future<List<Map<String, dynamic>>> fetchLokasiPeta(String endpoint) async {
    try {
      // PERBAIKAN: Menggunakan _baseUrlBackend
      final response = await _dio.get('$_baseUrlBackend/$endpoint');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Gagal memuat data lokasi');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil data lokasi: $e');
    }
  }

  // =======================================================================
  // API INFO PAJAK (BARU)
  // =======================================================================
  Future<List<InfoPajak>> fetchInfoPajak() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/info-pajak');
      if (response.statusCode == 200) {
        final List<InfoPajak> infoList = (response.data as List)
            .map((item) => InfoPajak.fromJson(item))
            .toList();
        return infoList;
      } else {
        throw Exception('Gagal memuat info pajak');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil info pajak: $e');
    }
  }

  Future<List<SekolahModel>> fetchTempatSekolah() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/tempat-sekolah');
      if (response.statusCode == 200) {
        final List<SekolahModel> sekolahList = (response.data as List)
            .map((item) => SekolahModel.fromJson(item))
            .toList();
        return sekolahList;
      } else {
        throw Exception('Gagal memuat data sekolah');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil data sekolah: $e');
    }
  }

  // =======================================================================
  // API BERITA PENDIDIKAN (BARU)
  // =======================================================================
  Future<List<BeritaPendidikanModel>> fetchBeritaPendidikan() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/info-sekolah');
      if (response.statusCode == 200) {
        final List<BeritaPendidikanModel> beritaList = (response.data as List)
            .map((item) => BeritaPendidikanModel.fromJson(item))
            .toList();
        return beritaList;
      } else {
        throw Exception('Gagal memuat berita pendidikan');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil berita pendidikan: $e');
    }
  }
}
