import 'package:reang_app/models/puskesmas_model.dart';

class DokterModel {
  final int id;
  final String nama;
  final String pendidikan;
  final String fitur;
  final String masaKerja; // <-- Diubah dari umur
  final String nomer;
  final String? fotoUrl; // <-- Ditambahkan (nullable untuk keamanan)
  final PuskesmasModel puskesmas;

  DokterModel({
    required this.id,
    required this.nama,
    required this.pendidikan,
    required this.fitur,
    required this.masaKerja, // <-- Diubah
    required this.nomer,
    this.fotoUrl, // <-- Ditambahkan
    required this.puskesmas,
  });

  factory DokterModel.fromJson(Map<String, dynamic> json) {
    return DokterModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? 'Tanpa Nama',
      pendidikan: json['pendidikan'] ?? 'Tidak Diketahui',
      fitur: json['fitur'] ?? 'Umum',
      masaKerja: json['masa_kerja'] ?? 'N/A', // <-- Diubah
      nomer: json['nomer'] ?? 'Tidak Diketahui',
      fotoUrl: json['foto_url'], // <-- Ditambahkan
      puskesmas: PuskesmasModel.fromJson(json['puskesmas'] ?? {}),
    );
  }
}
