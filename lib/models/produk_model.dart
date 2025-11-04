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
  });

  // Factory constructor untuk membuat instance dari JSON (Map)
  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'],
      idToko: json['id_toko'],
      nama: json['nama'],
      foto: json['foto'],
      // Menggunakan (as num).toInt() agar aman jika data dari server
      // dikirim sebagai int (15000) atau double (15000.0)
      harga: (json['harga'] as num).toInt(),
      variasi: json['variasi'],
      deskripsi: json['deskripsi'],
      spesifikasi: json['spesifikasi'],
      lokasi: json['lokasi'],
      fitur: json['fitur'],
      stok: (json['stok'] as num).toInt(),
    );
  }

  // --- Opsional, tapi sangat berguna untuk nanti ---

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
    };
  }

  // Method untuk meng-copy object (berguna untuk state management)
  ProdukModel copyWith({
    int? id,
    int? idToko,
    String? nama,
    String? foto,
    int? harga,
    String? variasi,
    String? deskripsi,
    String? spesifikasi,
    String? lokasi,
    String? fitur,
    int? stok,
  }) {
    return ProdukModel(
      id: id ?? this.id,
      idToko: idToko ?? this.idToko,
      nama: nama ?? this.nama,
      foto: foto ?? this.foto,
      harga: harga ?? this.harga,
      variasi: variasi ?? this.variasi,
      deskripsi: deskripsi ?? this.deskripsi,
      spesifikasi: spesifikasi ?? this.spesifikasi,
      lokasi: lokasi ?? this.lokasi,
      fitur: fitur ?? this.fitur,
      stok: stok ?? this.stok,
    );
  }
}
