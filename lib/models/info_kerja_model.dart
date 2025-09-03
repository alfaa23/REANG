import 'package:html_unescape/html_unescape.dart';
import 'package:reang_app/models/berita_model.dart';

class InfoKerja {
  final int id;
  final String judul;
  final String alamat;
  final String gajiFormatted;
  final String nomorTelepon;
  final String whatsappLink;
  final String waktuKerja;
  final String jenisKerja;
  final String foto;
  final String kategori;
  final String deskripsi;
  final DateTime tanggal;

  InfoKerja({
    required this.id,
    required this.judul,
    required this.alamat,
    required this.gajiFormatted,
    required this.nomorTelepon,
    required this.whatsappLink,
    required this.waktuKerja,
    required this.jenisKerja,
    required this.foto,
    required this.kategori,
    required this.deskripsi,
    required this.tanggal,
  });

  factory InfoKerja.fromJson(Map<String, dynamic> json) {
    var unescape = HtmlUnescape();
    return InfoKerja(
      id: json['id'] ?? 0,
      judul: unescape.convert(json['judul'] ?? 'Tanpa Judul'),
      alamat: json['alamat'] ?? 'Lokasi tidak tersedia',
      gajiFormatted: json['gaji_formatted'] ?? 'Gaji tidak disebutkan',
      nomorTelepon: json['nomor_telepon'] ?? '',
      whatsappLink: json['whatsapp_link'] ?? '',
      waktuKerja: json['waktu_kerja'] ?? 'Jam kerja tidak ditentukan',
      jenisKerja: json['jenis_kerja'] ?? 'Tipe tidak ditentukan',
      foto: json['foto'] ?? '',
      kategori: json['kategori'] ?? 'Lainnya',
      deskripsi: json['deskripsi'] ?? '',
      tanggal: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
