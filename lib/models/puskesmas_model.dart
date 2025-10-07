class PuskesmasModel {
  final int id;
  final String nama;
  final String alamat;
  final String jam;
  final int? dokterTersedia; // <-- DITAMBAHKAN (nullable)

  PuskesmasModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.jam,
    this.dokterTersedia, // <-- DITAMBAHKAN
  });

  factory PuskesmasModel.fromJson(Map<String, dynamic> json) {
    return PuskesmasModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? 'Tanpa Nama',
      alamat: json['alamat'] ?? 'Tanpa Alamat',
      jam: json['jam'] ?? 'Tidak Diketahui',
      dokterTersedia: json['dokter_tersedia'], // <-- DITAMBAHKAN
    );
  }
}
