import 'package:flutter/material.dart';

class SemuaLayananScreen extends StatelessWidget {
  const SemuaLayananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Ambil data tema saat ini untuk digunakan di seluruh widget
    final theme = Theme.of(context);

    return Scaffold(
      // PERBAIKAN: Gunakan warna latar dari tema
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // PERBAIKAN: Gunakan warna AppBar dari tema
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          // Warna ikon akan otomatis mengikuti tema AppBar
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // PERBAIKAN: Kirim 'theme' ke helper widget
        title: _buildSearchBar(theme),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          // PERBAIKAN: Gunakan warna divider dari tema
          child: Container(color: theme.dividerColor, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildCategorySection(context, 'Laporan dan Kedaruratan', [
            _buildLayananItem(
              context,
              theme: theme, // PERBAIKAN: Kirim 'theme'
              icon: Icons.campaign_outlined,
              nama: 'Dumas-Yu',
              deskripsi: 'Lapor masalah di sekitar Anda jadi mudah',
            ),
            _buildLayananItem(
              context,
              theme: theme, // PERBAIKAN: Kirim 'theme'
              icon: Icons.info_outline,
              nama: 'Info-Yu',
              deskripsi: 'Informasi penting dan darurat',
            ),
          ]),
          _buildCategorySection(context, 'Kesehatan & Pendidikan', [
            _buildLayananItem(
              context,
              theme: theme, // PERBAIKAN: Kirim 'theme'
              icon: Icons.health_and_safety_outlined,
              nama: 'Sehat-Yu',
              deskripsi: 'Akses layanan kesehatan terdekat',
            ),
            _buildLayananItem(
              context,
              theme: theme, // PERBAIKAN: Kirim 'theme'
              icon: Icons.school_outlined,
              nama: 'Sekolah-Yu',
              deskripsi: 'Informasi seputar pendidikan',
            ),
          ]),
          // ... (Ulangi untuk semua _buildLayananItem lainnya)
          _buildCategorySection(context, 'Sosial dan Ekonomi', [
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.receipt_long_outlined,
              nama: 'Pajak-Yu',
              deskripsi: 'Cek dan bayar tagihan pajak Anda',
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.storefront_outlined,
              nama: 'Pasar-Yu',
              deskripsi: 'Cek harga pangan di pasar terdekat',
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.work_outline,
              nama: 'Kerja-Yu',
              deskripsi: 'Informasi lowongan pekerjaan',
            ),
          ]),
          _buildCategorySection(context, 'Pariwisata & Keagamaan', [
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.beach_access_outlined,
              nama: 'Plesir-Yu',
              deskripsi: 'Temukan destinasi wisata menarik',
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.mosque_outlined,
              nama: 'Ibadah-Yu',
              deskripsi: 'Cari lokasi tempat ibadah terdekat',
            ),
          ]),
          _buildCategorySection(context, 'Layanan Publik Lainnya', [
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.badge_outlined,
              nama: 'Adminduk-Yu',
              deskripsi: 'Urus dokumen kependudukan Anda',
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.construction_outlined,
              nama: 'Renbang-Yu',
              deskripsi: 'Partisipasi dalam rencana pembangunan',
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.description_outlined,
              nama: 'Izin-Yu',
              deskripsi: 'Pengajuan perizinan jadi lebih mudah',
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.wifi_outlined,
              nama: 'WiFi-Yu',
              deskripsi: 'Temukan titik WiFi publik gratis',
            ),
          ]),
        ],
      ),
    );
  }

  // Helper widget untuk search bar
  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        // PERBAIKAN: Gunakan warna yang lebih adaptif untuk background search bar
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        // PERBAIKAN: Warna teks akan otomatis mengikuti tema
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Cari Layanan di Reang',
          // PERBAIKAN: Gunakan warna hint dari tema
          hintStyle: TextStyle(color: theme.hintColor),
          prefixIcon: Icon(Icons.search, color: theme.hintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 4,
          ),
        ),
      ),
    );
  }

  // Helper widget untuk satu seksi kategori
  Widget _buildCategorySection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            // PERBAIKAN: Warna teks dan style akan otomatis dari tema
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(children: items),
        ],
      ),
    );
  }

  // Helper widget untuk satu item layanan
  Widget _buildLayananItem(
    BuildContext context, {
    required ThemeData theme, // PERBAIKAN: Terima 'theme'
    required IconData icon,
    required String nama,
    required String deskripsi,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // PERBAIKAN: Gunakan warna primer dari tema untuk aksen
              color: theme.colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            // PERBAIKAN: Gunakan warna primer dari tema untuk ikon
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          // PERBAIKAN: Warna teks akan otomatis mengikuti tema
          title: Text(nama),
          subtitle: Text(
            deskripsi,
            // PERBAIKAN: Gunakan warna hint dari tema untuk deskripsi
            style: TextStyle(color: theme.hintColor),
          ),
          onTap: () {
            // TODO: Tambahkan navigasi untuk setiap fitur
          },
        ),
        // PERBAIKAN: Gunakan warna divider dari tema
        Divider(color: theme.dividerColor, height: 1),
      ],
    );
  }
}
