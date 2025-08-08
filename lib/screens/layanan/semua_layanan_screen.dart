import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/adminduk/adminduk_screen.dart';
import 'package:reang_app/screens/layanan/dumas/dumas_yu_screen.dart';
import 'package:reang_app/screens/layanan/info/info_yu_screen.dart';
import 'package:reang_app/screens/layanan/pajak/pajak_yu_screen.dart';
import 'package:reang_app/screens/layanan/sehat/sehat_yu_screen.dart';
import 'package:reang_app/screens/layanan/pasar/pasar_yu_screen.dart';
import 'package:reang_app/screens/layanan/plesir/plesir_yu_screen.dart';
import 'package:reang_app/screens/layanan/ibadah/ibadah_yu_screen.dart';
import 'package:reang_app/screens/layanan/renbang/renbang_yu_screen.dart';
import 'package:reang_app/screens/layanan/sekolah/sekolah_yu_screen.dart';
import 'package:reang_app/screens/layanan/kerja/kerja_yu_screen.dart';
import 'package:reang_app/screens/layanan/wifi/wifi_yu_screen.dart';
import 'package:reang_app/screens/layanan/izin/izin_yu_screen.dart';

class SemuaLayananScreen extends StatelessWidget {
  const SemuaLayananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _buildSearchBar(theme),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildCategorySection(context, 'Laporan dan Kedaruratan', [
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.campaign_outlined,
              nama: 'Dumas-Yu',
              deskripsi: 'Lapor masalah di sekitar Anda jadi mudah',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DumasYuHomeScreen(),
                  ),
                );
              },
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.info_outline,
              nama: 'Info-Yu',
              deskripsi: 'Informasi penting dan darurat',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InfoYuScreen()),
                );
              },
            ),
          ]),
          _buildCategorySection(context, 'Kesehatan & Pendidikan', [
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.health_and_safety_outlined,
              nama: 'Sehat-Yu',
              deskripsi: 'Akses layanan kesehatan terdekat',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SehatYuScreen(),
                  ),
                );
              },
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.school_outlined,
              nama: 'Sekolah-Yu',
              deskripsi: 'Informasi seputar pendidikan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SekolahYuScreen(),
                  ),
                );
              },
            ),
          ]),
          _buildCategorySection(context, 'Sosial dan Ekonomi', [
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.receipt_long_outlined,
              nama: 'Pajak-Yu',
              deskripsi: 'Cek dan bayar tagihan pajak Anda',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PajakYuScreen(),
                  ),
                );
              },
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.storefront_outlined,
              nama: 'Pasar-Yu',
              deskripsi: 'Cek harga pangan di pasar terdekat',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasarYuScreen(),
                  ),
                );
              },
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.work_outline,
              nama: 'Kerja-Yu',
              deskripsi: 'Informasi lowongan pekerjaan',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KerjaYuScreen()),
              ),
            ),
          ]),
          _buildCategorySection(context, 'Pariwisata & Keagamaan', [
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.beach_access_outlined,
              nama: 'Plesir-Yu',
              deskripsi: 'Temukan destinasi wisata menarik',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlesirYuScreen(),
                  ),
                );
              },
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.mosque_outlined,
              nama: 'Ibadah-Yu',
              deskripsi: 'Cari lokasi tempat ibadah terdekat',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IbadahYuScreen(),
                  ),
                );
              },
            ),
          ]),
          _buildCategorySection(context, 'Layanan Publik Lainnya', [
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.badge_outlined,
              nama: 'Adminduk-Yu',
              deskripsi: 'Urus dokumen kependudukan Anda',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdmindukScreen(),
                  ),
                );
              },
            ),
            // PERUBAHAN: Menambahkan onTap ke Renbang-Yu
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.construction_outlined,
              nama: 'Renbang-Yu',
              deskripsi: 'Partisipasi dalam rencana pembangunan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RenbangYuScreen(),
                  ),
                );
              },
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.description_outlined,
              nama: 'Izin-Yu',
              deskripsi: 'Pengajuan perizinan jadi lebih mudah',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IzinYuScreen()),
                );
              },
            ),
            _buildLayananItem(
              context,
              theme: theme,
              icon: Icons.wifi_outlined,
              nama: 'WiFi-Yu',
              deskripsi: 'Temukan titik WiFi publik gratis',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WifiYuScreen()),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Cari Layanan di Reang',
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

  Widget _buildLayananItem(
    BuildContext context, {
    required ThemeData theme,
    required IconData icon,
    required String nama,
    required String deskripsi,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          title: Text(nama),
          subtitle: Text(deskripsi, style: TextStyle(color: theme.hintColor)),
          onTap: onTap,
        ),
        Divider(color: theme.dividerColor, height: 1),
      ],
    );
  }
}
