import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

class RenbangModel {
  final int id;
  final String judul;
  final String deskripsi;
  final String fitur;
  final String gambar;
  final String alamat;

  RenbangModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.fitur,
    required this.gambar,
    required this.alamat,
  });

  // Helper untuk mendapatkan ringkasan deskripsi (menghilangkan tag HTML)
  String get summary {
    final unescape = HtmlUnescape();
    final cleanHtml = unescape.convert(deskripsi);
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return cleanHtml.replaceAll(exp, ' ').replaceAll('&nbsp;', ' ').trim();
  }

  // Helper untuk mendapatkan warna header berdasarkan fitur/kategori
  Color get headerColor {
    switch (fitur.toLowerCase()) {
      case 'infrastruktur':
        return const Color(0xFFFF6B6B);
      case 'kesehatan':
        return const Color(0xFF4ECDC4);
      case 'pendidikan':
        return const Color(0xFF1A535C);
      default:
        return Colors.grey;
    }
  }

  factory RenbangModel.fromJson(Map<String, dynamic> json) {
    return RenbangModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? 'Tanpa Judul',
      deskripsi: json['deskripsi'] ?? '',
      fitur: json['fitur'] ?? 'Umum',
      gambar: json['gambar'] ?? '',
      alamat: json['alamat'] ?? 'Lokasi tidak spesifik',
    );
  }
}
