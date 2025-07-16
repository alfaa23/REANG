import 'package:dio/dio.dart';
import 'package:reang_app/models/berita_model.dart';

class ApiService {
  final Dio _dio = Dio();
  // URL dasar dari API WordPress
  // _embed digunakan untuk menyertakan data penulis dan gambar
  final String _baseUrl =
      'https://indramayukab.go.id/wp-json/wp/v2/posts?_embed';

  Future<List<Berita>> fetchBerita() async {
    try {
      final response = await _dio.get(_baseUrl);
      if (response.statusCode == 200) {
        // Mengubah setiap item di list JSON menjadi objek Berita
        final List<Berita> beritaList = (response.data as List)
            .map((item) => Berita.fromJson(item))
            .toList();
        return beritaList;
      } else {
        throw Exception('Gagal memuat berita');
      }
    } catch (e) {
      // Menangani error jika terjadi masalah koneksi atau lainnya
      throw Exception('Terjadi error: $e');
    }
  }
}
