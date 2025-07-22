import 'package:flutter/material.dart';

// Model untuk menampung satu item dokumen hukum dari API JDIH
class PeraturanHukum {
  final String judul;
  final String jenis;
  final String singkatanJenis;
  final String nomor;
  final String tahun;
  final String status;
  final String pemrakarsa;
  final String penandatangan;
  final String tanggalPenetapan;
  final String urlDownload;

  PeraturanHukum({
    required this.judul,
    required this.jenis,
    required this.singkatanJenis,
    required this.nomor,
    required this.tahun,
    required this.status,
    required this.pemrakarsa,
    required this.penandatangan,
    required this.tanggalPenetapan,
    required this.urlDownload,
  });

  // PERBAIKAN: Fungsi ini disesuaikan agar cocok dengan struktur API yang baru
  factory PeraturanHukum.fromJson(Map<String, dynamic> json) {
    return PeraturanHukum(
      judul: json['judul'] ?? 'Tidak ada judul',
      jenis: json['jenis'] ?? 'Tidak ada jenis',
      // Menggunakan kunci 'singkatan' dari API
      singkatanJenis: json['singkatan'] ?? '',
      // Menggunakan kunci 'nomer' dari API
      nomor: json['nomer'] ?? '-',
      tahun: json['tahun'] ?? '-',
      status: json['status'] ?? 'Tidak diketahui',
      pemrakarsa: json['pemrakarsa'] ?? 'Tidak ada data',
      // Menggunakan kunci 'penandatanganan' dari API
      penandatangan: json['penandatanganan'] ?? 'Tidak ada data',
      tanggalPenetapan: json['tanggal_penetapan'] ?? '-',
      // Menggunakan kunci 'link_peraturan' dari API
      urlDownload: json['link_peraturan'] ?? '',
    );
  }

  // Helper untuk menentukan warna status (tidak ada perubahan)
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'berlaku':
        return Colors.green;
      case 'mengubah':
      case 'perubahan': // Menambahkan case untuk status "Perubahan"
        return Colors.orange;
      case 'dicabut':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper untuk menentukan ikon berdasarkan jenis (tidak ada perubahan)
  IconData get icon {
    if (jenis.toLowerCase().contains('bupati')) {
      return Icons.article_outlined;
    }
    return Icons.account_balance_outlined;
  }
}
