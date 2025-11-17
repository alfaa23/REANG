// Lokasi: lib/models/produk_model.dart

import 'dart:convert';
// [PERBAIKAN] Pastikan path ini benar
import 'produk_varian_model.dart';

class ProdukModel {
  final int id;
  final int idToko;
  final String nama;
  final String? foto;
  final String? deskripsi;
  final String? spesifikasi;
  final String? lokasi;
  final String? fitur;
  final String? namaToko;

  // [PERUBAHAN UTAMA] Kolom 'harga', 'stok', 'variasi' DIGANTI dengan ini:
  final List<ProdukVarianModel> varians;

  ProdukModel({
    required this.id,
    required this.idToko,
    required this.nama,
    this.foto,
    this.deskripsi,
    this.spesifikasi,
    this.lokasi,
    this.fitur,
    this.namaToko,
    this.varians = const [], // Default list kosong
  });

  // =================================================================
  // --- [PERBAIKAN LOGIKA GETTER] ---

  /// [PERBAIKAN] Mengembalikan HARGA TERENDAH dari semua varian.
  int get harga {
    if (varians.isEmpty) return 0;
    // Ambil semua harga, cari yang terkecil
    final prices = varians.map((v) => v.harga).toList();
    prices.sort(); // Urutkan dari kecil ke besar
    return prices.first; // Kembalikan yang pertama (terkecil)
  }

  /// [BENAR] Mengembalikan TOTAL STOK dari SEMUA varian.
  int get stok {
    if (varians.isEmpty) return 0;
    return varians.fold(0, (previousValue, v) => previousValue + v.stok);
  }

  /// [BENAR] Mengembalikan string gabungan dari nama varian.
  String get variasi {
    if (varians.isEmpty) return "";
    return varians.map((v) => v.namaVarian).join(', ');
  }

  // Helper parsing INT yang aman
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final cleanString = value.split('.').first;
      return int.tryParse(cleanString) ?? 0;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    // Parsing list varian jika ada di JSON
    List<ProdukVarianModel> parsedVarians = [];
    if (json['varians'] != null && json['varians'] is List) {
      parsedVarians = (json['varians'] as List)
          .map((v) => ProdukVarianModel.fromJson(v))
          .toList();
    }

    return ProdukModel(
      id: json['id'] ?? 0,
      idToko: _parseInt(json['id_toko']),
      nama: json['nama'] ?? '',
      foto: json['foto'],
      deskripsi: json['deskripsi'],
      spesifikasi: json['spesifikasi'],
      lokasi: json['lokasi'],
      fitur: json['fitur'],
      namaToko: json['nama_toko'],
      varians: parsedVarians, // Masukkan list varian
    );
  }

  // Mengubah ke JSON (untuk dikirim ke API 'store'/'update')
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_toko': idToko,
      'nama': nama,
      'foto': foto,
      'deskripsi': deskripsi,
      'spesifikasi': spesifikasi,
      'fitur': fitur,
      // Kirim varian sebagai list of map
      'varians': varians.map((v) => v.toJson()).toList(),
    };
  }
}
