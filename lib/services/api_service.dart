import 'package:dio/dio.dart';
import 'package:intl/intl.dart'; // Diperlukan untuk format tanggal
import 'package:reang_app/models/berita_model.dart';
import 'package:reang_app/models/jdih_model.dart';
import 'package:reang_app/models/artikel_sehat_model.dart';
import 'package:reang_app/models/info_pajak_model.dart';
import 'package:reang_app/models/sekolah_model.dart';
import 'package:reang_app/models/berita_pendidikan_model.dart';
import 'package:reang_app/models/info_kerja_model.dart';
import 'package:reang_app/models/event_keagamaan_model.dart';
import 'package:reang_app/models/info_perizinan_model.dart';
import 'package:reang_app/models/pasar_model.dart';
import 'package:reang_app/models/info_adminduk_model.dart';
import 'package:reang_app/models/slider_model.dart';
import 'package:reang_app/models/renbang_model.dart';
import 'package:reang_app/models/plesir_model.dart';
import 'package:reang_app/models/ulasan_response_model.dart';

/// Kelas ini bertanggung jawab untuk semua komunikasi dengan API eksternal.
class ApiService {
  final Dio _dio = Dio();

  // =======================================================================
  // KONFIGURASI BASE URL
  // =======================================================================
  // Backend lokal
  final String _baseUrlBackend = 'https://098be101644e.ngrok-free.app/api';

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

  // =======================================================================
  // API INFO KERJA (BARU)
  // =======================================================================
  Future<List<InfoKerjaModel>> fetchInfoKerja() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/info-kerja');
      if (response.statusCode == 200) {
        final List<InfoKerjaModel> infoKerjaList = (response.data as List)
            .map((item) => InfoKerjaModel.fromJson(item))
            .toList();
        return infoKerjaList;
      } else {
        throw Exception('Gagal memuat data pekerjaan');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil data pekerjaan: $e');
    }
  }

  // =======================================================================
  // API Event Keagamaan (BARU)
  // =======================================================================

  Future<List<EventKeagamaanModel>> fetchEventKeagamaan() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/event-agama');
      if (response.statusCode == 200) {
        final List<EventKeagamaanModel> eventList = (response.data as List)
            .map((item) => EventKeagamaanModel.fromJson(item))
            .toList();
        return eventList;
      } else {
        throw Exception('Gagal memuat data event');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil data event: $e');
    }
  }

  // =======================================================================
  // API INFO PERIZINAN (BARU)
  // =======================================================================
  Future<List<InfoPerizinanModel>> fetchInfoPerizinan() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/info-perizinan');
      if (response.statusCode == 200) {
        final List<InfoPerizinanModel> perizinanList = (response.data as List)
            .map((item) => InfoPerizinanModel.fromJson(item))
            .toList();
        return perizinanList;
      } else {
        throw Exception('Gagal memuat info perizinan');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil info perizinan: $e');
    }
  }

  // =======================================================================
  // API TEMPAT PASAR
  // =======================================================================
  Future<List<PasarModel>> fetchTempatPasar() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/tempat-pasar');
      if (response.statusCode == 200) {
        final List<PasarModel> pasarList = (response.data as List)
            .map((item) => PasarModel.fromJson(item))
            .toList();
        return pasarList;
      } else {
        throw Exception('Gagal memuat data pasar');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil data pasar: $e');
    }
  }

  // =======================================================================
  // API INFO ADMINDuk (BARU)
  // =======================================================================
  Future<List<InfoAdmindukModel>> fetchInfoAdminduk() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/info-adminduk');
      if (response.statusCode == 200) {
        final List<InfoAdmindukModel> list = (response.data as List)
            .map((item) => InfoAdmindukModel.fromJson(item))
            .toList();
        return list;
      } else {
        throw Exception('Gagal memuat info adminduk');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil info adminduk: $e');
    }
  }

  // =======================================================================
  // API SLIDERS
  // =======================================================================
  Future<List<SliderModel>> fetchSliders() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/sliders');
      // Cek apakah response sukses dan memiliki data
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<SliderModel> sliderList = (response.data['data'] as List)
            .map((item) => SliderModel.fromJson(item))
            .toList();
        return sliderList;
      } else {
        throw Exception('Gagal memuat sliders');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil sliders: $e');
    }
  }

  // =======================================================================
  // API RENCANA PEMBANGUNAN (BARU)
  // =======================================================================
  Future<List<RenbangModel>> fetchRencanaPembangunan() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/deskripsi-renbang');
      if (response.statusCode == 200) {
        final List<RenbangModel> list = (response.data as List)
            .map((item) => RenbangModel.fromJson(item))
            .toList();
        return list;
      } else {
        throw Exception('Gagal memuat Rencana Pembangunan');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil Rencana Pembangunan: $e');
    }
  }

  // =======================================================================
  // API REGISTRASI (BARU)
  // =======================================================================
  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String noKtp,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrlBackend/auth/signup',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'noKtp': noKtp,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mengembalikan seluruh data (termasuk token dan user) jika sukses
        return response.data;
      } else {
        // Menangani status code lain yang tidak diharapkan
        throw Exception('Gagal melakukan pendaftaran.');
      }
    } on DioException catch (e) {
      // Menangani error validasi dari server (misal: email sudah terdaftar)
      if (e.response != null && e.response!.data is Map) {
        final errorMessage =
            e.response!.data['message'] ?? 'Terjadi kesalahan.';
        // Jika ada detail error dari validator, ambil yang pertama
        final errors = e.response!.data['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
        throw Exception(errorMessage);
      }
      // Menangani error koneksi atau timeout
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
    } catch (e) {
      // Menangani error tak terduga lainnya
      throw Exception('Terjadi kesalahan yang tidak diketahui: $e');
    }
  }

  // =======================================================================
  // API LOGIN (BARU)
  // =======================================================================
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrlBackend/auth/signin',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        // Mengembalikan seluruh data (termasuk token dan user) jika sukses
        return response.data;
      } else {
        // Menangani status code lain yang tidak diharapkan
        throw Exception('Gagal melakukan login.');
      }
    } on DioException catch (e) {
      // Menangani error dari server (misal: email atau password salah)
      if (e.response != null && e.response!.data is Map) {
        final errorMessage =
            e.response!.data['message'] ?? 'Terjadi kesalahan.';
        throw Exception(errorMessage);
      }
      // Menangani error koneksi atau timeout
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
    } catch (e) {
      // Menangani error tak terduga lainnya
      throw Exception('Terjadi kesalahan yang tidak diketahui: $e');
    }
  }

  // =======================================================================
  // API INFO PLESIR (BARU)
  // =======================================================================
  Future<List<PlesirModel>> fetchInfoPlesir() async {
    try {
      final response = await _dio.get('$_baseUrlBackend/info-plesir');
      if (response.statusCode == 200) {
        final List<PlesirModel> list = (response.data as List)
            .map((item) => PlesirModel.fromJson(item))
            .toList();
        return list;
      } else {
        throw Exception('Gagal memuat info plesir');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil info plesir: $e');
    }
  }

  // =======================================================================
  // API RATING & ULASAN (DIPERBARUI)
  // =======================================================================

  // Fungsi untuk MENGAMBIL ulasan dengan pagination
  Future<UlasanResponseModel> fetchUlasan(int plesirId, int page) async {
    try {
      final response = await _dio.get(
        '$_baseUrlBackend/info-plesir/$plesirId/ratings?page=$page',
      );
      if (response.statusCode == 200) {
        return UlasanResponseModel.fromJson(response.data);
      } else {
        throw Exception('Gagal memuat ulasan');
      }
    } catch (e) {
      throw Exception('Terjadi error saat mengambil ulasan: $e');
    }
  }

  // Fungsi untuk MENGIRIM ulasan baru
  Future<Map<String, dynamic>> postUlasan({
    required int plesirId,
    required int userId,
    required int rating,
    required String comment,
    required String token, // Token dibutuhkan untuk otentikasi
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrlBackend/rating',
        data: {
          'info_plesir_id': plesirId,
          'user_id': userId,
          'rating': rating,
          'comment': comment,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Gagal mengirim ulasan');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw Exception(e.response!.data['message'] ?? 'Terjadi kesalahan.');
      }
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }

  // FUNGSI BARU: Untuk MENGEDIT ulasan yang sudah ada
  Future<Map<String, dynamic>> updateUlasan({
    required int ratingId,
    required int rating,
    required String comment,
    required String token,
  }) async {
    try {
      final response = await _dio.put(
        '$_baseUrlBackend/rating/$ratingId', // Menggunakan method PUT
        data: {'rating': rating, 'comment': comment},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Gagal memperbarui ulasan');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw Exception(e.response!.data['message'] ?? 'Terjadi kesalahan.');
      }
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }
}
