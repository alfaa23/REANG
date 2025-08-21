import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // PENAMBAHAN BARU: Untuk keluar dari aplikasi
import 'package:fluttertoast/fluttertoast.dart'; // PENAMBAHAN BARU: Untuk notifikasi toast
import 'package:reang_app/screens/layanan/ibadah/ibadah_yu_screen.dart';
import 'package:reang_app/screens/layanan/semua_layanan_screen.dart';
import 'package:reang_app/screens/layanan/sehat/sehat_yu_screen.dart';
import 'package:reang_app/screens/layanan/dumas/dumas_yu_screen.dart';
import 'package:reang_app/screens/layanan/info/info_yu_screen.dart';
import 'package:reang_app/screens/layanan/plesir/plesir_yu_screen.dart';
import 'package:reang_app/screens/layanan/sekolah/sekolah_yu_screen.dart';
import 'package:reang_app/screens/layanan/pasar/pasar_yu_screen.dart';
import 'package:reang_app/screens/search/search_screen.dart'; // PENAMBAHAN BARU: Import halaman pencarian

// PENAMBAHAN BARU: Import widget banner dan rekomendasi
import 'package:reang_app/screens/home/widgets/info_banner_widget.dart';
import 'package:reang_app/screens/home/widgets/rekomendasi_fitur_widget.dart';
import 'package:reang_app/screens/home/widgets/rekomendasi_berita_widget.dart';

final List<String> imgList = [
  'assets/banner.png',
  'assets/banner_2.png',
  'assets/banner_3.png',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  late Timer _timer;
  int _current = 0;
  static const int _initialPage = 3000;

  // PERUBAHAN: Variabel untuk logika keluar diubah menjadi boolean
  bool _isExitPressed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _initialPage,
      // PERBAIKAN: Nilai viewportFraction diubah agar gambar slider lebih lebar
      viewportFraction: 0.95,
    );
    _current = _initialPage % imgList.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_pageController.hasClients && _pageController.page != null) {
        int nextPage = _pageController.page!.round() + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // PERUBAHAN: Logika keluar di dalam PopScope diperbarui
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (_isExitPressed) {
          // Jika ini adalah tekanan kedua, keluar dari aplikasi.
          SystemNavigator.pop();
        } else {
          // Jika ini adalah tekanan pertama, set flag, tampilkan notifikasi, dan mulai timer reset.
          setState(() {
            _isExitPressed = true;
          });

          Fluttertoast.showToast(
            msg: "Tekan sekali lagi untuk keluar",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            // PERUBAHAN: Warna diubah menjadi abu-abu solid
            backgroundColor: Colors.grey.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          // PERBAIKAN: Tambahkan timer untuk mereset status setelah 7 detik
          Future.delayed(const Duration(seconds: 7), () {
            if (mounted) {
              setState(() {
                _isExitPressed = false;
              });
            }
          });
        }
      },
      child: Material(
        color: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              SizedBox(
                height: 230,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: null,
                  onPageChanged: (index) {
                    setState(() {
                      _current = index % imgList.length;
                    });
                  },
                  itemBuilder: (context, index) {
                    final realIndex = index % imgList.length;
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double scale = 1.0;
                        if (_pageController.hasClients) {
                          double page =
                              _pageController.page ?? _initialPage.toDouble();
                          double value = (page - index).abs();
                          scale = max(0.85, 1 - value * 0.3);
                        }
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Container(
                        // PERBAIKAN: Margin diperkecil agar slider lebih lebar
                        margin: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12.0),
                          ),
                          child: Image.asset(
                            imgList[realIndex],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Text('Gagal memuat gambar'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imgList.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDarkMode ? Colors.white : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    // Navigasi ke SearchScreen saat di-tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor, // Dibuat putih/gelap sesuai tema
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: theme.iconTheme.color?.withAlpha(178),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cari Layanan di Reang',
                          style: TextStyle(
                            color: theme.hintColor.withOpacity(0.4),
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // PENAMBAHAN BARU: Atur jarak vertikal antara search bar dan menu ikon di sini
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                  children: [
                    _MenuItem(
                      assetIcon: 'assets/icons/dumas_yu.png',
                      label: 'Dumas-yu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DumasYuHomeScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      assetIcon: 'assets/icons/info_yu.png',
                      label: 'Info-yu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InfoYuScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      assetIcon: 'assets/icons/sehat_yu.png',
                      label: 'Sehat-yu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SehatYuScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      assetIcon: 'assets/icons/sekolah_yu.png',
                      label: 'Sekolah-yu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SekolahYuScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      assetIcon: 'assets/icons/ibadah_yu.png',
                      label: 'Ibadah-yu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const IbadahYuScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      assetIcon: 'assets/icons/plesir_yu.png',
                      label: 'Plesir-yu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlesirYuScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      assetIcon: 'assets/icons/pasar_yu.png',
                      label: 'Pasar-yu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PasarYuScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.grid_view,
                      label: 'Semua',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SemuaLayananScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // =============================================================
              // PENAMBAHAN BARU: Memanggil widget banner dan rekomendasi
              // =============================================================
              const SizedBox(height: 10),
              const RekomendasiFiturWidget(),
              const SizedBox(height: 32),
              const InfoBannerWidget(),
              const SizedBox(height: 32),
              const RekomendasiBeritaWidget(),

              // =============================================================
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String? assetIcon;
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({this.assetIcon, this.icon, required this.label, this.onTap})
    : assert(
        assetIcon != null || icon != null,
        'Either assetIcon or icon must be provided',
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // KOMENTAR: Ubah nilai width dan height di bawah ini untuk menyesuaikan ukuran lingkaran
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              // KOMENTAR: Ubah warna latar belakang lingkaran di sini
              color: const Color.fromARGB(255, 229, 236, 251),
              shape: BoxShape.circle,
            ),
            child: assetIcon != null
                ? Padding(
                    // KOMENTAR: Ubah nilai padding di bawah ini untuk menyesuaikan ukuran gambar di dalam lingkaran
                    padding: const EdgeInsets.all(5.0),
                    child: Image.asset(assetIcon!, fit: BoxFit.contain),
                  )
                : Icon(icon, color: Colors.blue.shade800, size: 35),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
