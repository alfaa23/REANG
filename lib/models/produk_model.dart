// lib/models/produk_model.dart

class ProdukModel {
  final int id;
  final int idToko;
  final String nama;
  final String? foto; // Bisa null
  final int harga;
  final String? variasi; // Bisa null
  final String? deskripsi; // Bisa null
  final String? spesifikasi; // Bisa null
  final String? lokasi; // Bisa null
  final String? fitur; // Bisa null
  final int stok;
  final String? namaToko;

  ProdukModel({
    required this.id,
    required this.idToko,
    required this.nama,
    this.foto,
    required this.harga,
    this.variasi,
    this.deskripsi,
    this.spesifikasi,
    this.lokasi,
    this.fitur,
    required this.stok,
    this.namaToko,
  });

  // [BARU] Helper function untuk mem-parsing dari String, num, atau int
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      // Jika ada desimal (.00), hilangkan dulu, lalu parse
      final cleanString = value.split('.').first;
      return int.tryParse(cleanString) ?? 0;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  // Factory constructor untuk membuat instance dari JSON (Map)
  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'] as int,
      idToko: json['id_toko'] as int,
      nama: json['nama'],
      foto: json['foto'],

      // [PERBAIKAN KRITIS]: Menggunakan helper untuk parsing String harga ke Int
      harga: _parseInt(json['harga']),

      variasi: json['variasi'],
      deskripsi: json['deskripsi'],
      spesifikasi: json['spesifikasi'],
      lokasi: json['lokasi'],
      fitur: json['fitur'],

      // [PERBAIKAN KEDUA]: Menggunakan helper untuk stok (jaga-jaga jika dikirim string)
      stok: _parseInt(json['stok']),

      // Field ini mungkin tidak selalu ada di respons API produk show
      namaToko: json['nama_toko'] as String?,
    );
  }

  // Method untuk mengubah instance menjadi Map (misal untuk POST/UPDATE)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_toko': idToko,
      'nama': nama,
      'foto': foto,
      'harga': harga,
      'variasi': variasi,
      'deskripsi': deskripsi,
      'spesifikasi': spesifikasi,
      'lokasi': lokasi,
      'fitur': fitur,
      'stok': stok,
      'nama_toko': namaToko,
    };
  }
}
