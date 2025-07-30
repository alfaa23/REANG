import 'package:flutter/material.dart';

class DetailLowonganScreen extends StatelessWidget {
  // Menerima data lowongan dari halaman sebelumnya
  final Map<String, dynamic> data;
  const DetailLowonganScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Menyiapkan data dummy tambahan untuk kelengkapan UI
    final kualifikasi = [
      'Pendidikan minimal DIII/S1',
      'Pengalaman minimal 2 tahun diposisi yang sama (lebih disukai dari perbankan)',
      'Siap bekerja dengan target',
      'Memiliki Mental dan daya tahan yang baik',
      'Memiliki kendaraan roda dua & SIM C',
      'Penempatan: Kota Bandung',
    ];
    final tugas = [
      'Mencari nasabah yang sesuai dengan kriteria bank',
      'Menjalin hubungan baik dengan nasabah',
      'Melakukan survei usaha dan agunan debitur',
      'Mengelola database debitur',
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          data['company'] ?? 'Detail Lowongan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        children: [
          // Header: Logo, Judul, Perusahaan
          _buildHeader(context, theme),
          const SizedBox(height: 24),

          // Seksi Benefit
          _buildSection(
            theme,
            title: 'Benefit:',
            items: data['benefits'] as List<String>? ?? [],
          ),
          const SizedBox(height: 24),

          // Seksi Deskripsi
          _buildSection(
            theme,
            title: 'Deskripsi',
            content: data['description'],
          ),
          const SizedBox(height: 24),

          // Seksi Kualifikasi
          _buildSection(theme, title: 'Kualifikasi', items: kualifikasi),
          const SizedBox(height: 24),

          // Seksi Tugas dan Tanggung Jawab
          _buildSection(theme, title: 'Tugas dan tanggung jawab', items: tugas),
          const SizedBox(height: 24),

          // Seksi Informasi Tambahan (Lokasi, Gaji, dll)
          _buildInfoSection(theme),
        ],
      ),
      // Tombol Aksi di Bagian Bawah
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Aksi untuk chat
          },
          style: ElevatedButton.styleFrom(
            // PERBAIKAN: Padding diubah agar tombol tidak terlalu besar
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('Minat? Chat Sekarang'),
        ),
      ),
    );
  }

  // Widget untuk bagian header
  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Image.asset(
            data['logoPath'],
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.business,
                size: 40,
                color: Colors.grey.shade400,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data['title'],
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data['company'],
          style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }

  // Widget reusable untuk setiap seksi (Benefit, Deskripsi, dll)
  Widget _buildSection(
    ThemeData theme, {
    required String title,
    String? content,
    List<String>? items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (content != null)
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        if (items != null)
          Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            item,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  // Widget untuk seksi informasi di bagian bawah
  Widget _buildInfoSection(ThemeData theme) {
    return Column(
      children: [
        const Divider(height: 32),
        _buildInfoRow(theme, Icons.location_on_outlined, data['location']),
        _buildInfoRow(
          theme,
          Icons.business_center_outlined,
          data['type'],
        ), // Menggunakan ikon yang lebih relevan
        _buildInfoRow(
          theme,
          Icons.access_time_outlined,
          '08.00 - 16.00 WIB',
        ), // Contoh jam kerja
        _buildInfoRow(theme, Icons.wallet_outlined, data['salary']),
        _buildInfoRow(
          theme,
          Icons.phone_outlined,
          '08743734387437473',
        ), // Contoh nomor telepon
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.hintColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
