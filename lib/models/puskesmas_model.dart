import 'package:reang_app/models/dokter_model.dart';

class PuskesmasModel {
  final int id;
  final String nama;
  final String alamat;
  final String jam;
  final int? adminId; // Dibuat nullable, karena data Anda ada yg null
  final int dokterTersedia;
  List<DokterModel>? dokter; // Opsional, jika Anda ingin menampilkannya

  PuskesmasModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.jam,
    this.adminId,
    required this.dokterTersedia,
    this.dokter,
  });

  factory PuskesmasModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk parsing integer/null dengan aman
    int? _safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return PuskesmasModel(
      id: _safeParseInt(json['id']) ?? 0,
      nama: json['nama'] ?? 'Tanpa Nama',
      alamat: json['alamat'] ?? '',
      jam: json['jam'] ?? '',
      adminId: _safeParseInt(json['admin_id']),
      dokterTersedia: _safeParseInt(json['dokter_tersedia']) ?? 0,
      // Jika API Anda menyertakan data dokter, Anda bisa parsing di sini
      // dokter: (json['dokter'] as List<dynamic>?)
      //     ?.map((d) => DokterModel.fromJson(d))
      //     .toList(),
    );
  }
}
