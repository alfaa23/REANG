import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/ibadah/ibadah_yu_screen.dart';
import 'package:reang_app/screens/layanan/semua_layanan_screen.dart';
import 'package:reang_app/screens/layanan/sehat/sehat_yu_screen.dart';
import 'package:reang_app/screens/layanan/dumas/dumas_yu_screen.dart';
import 'package:reang_app/screens/layanan/info/info_yu_screen.dart';
import 'package:reang_app/screens/layanan/plesir/plesir_yu_screen.dart';

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

  @override
  void initState() {
    super.initState();
    // Inisialisasi PageController dengan viewportFraction
    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.9,
    );
    // Perbaiki inisialisasi current page
    _current = _initialPage % imgList.length;

    // Mulai auto-scroll setelah frame pertama digambar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
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

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 230,
              child: PageView.builder(
                controller: _pageController,
                itemCount: null, // Infinite scroll
                onPageChanged: (int index) {
                  setState(() {
                    _current = index % imgList.length;
                  });
                },
                itemBuilder: (context, index) {
                  final int realIndex = index % imgList.length;
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
                      margin: const EdgeInsets.symmetric(horizontal: 6.0),
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
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    128,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: theme.iconTheme.color?.withAlpha(178),
                    ),
                    hintText: 'Cari Layanan di Reang',
                    hintStyle: TextStyle(color: theme.hintColor),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
                children: [
                  // PERUBAHAN: Menambahkan onTap ke item Dumas-yu
                  _MenuItem(
                    icon: Icons.campaign_outlined,
                    label: 'Dumas-yu',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DumasYuHomeScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.info_outline,
                    label: 'Info-yu',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoYuScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.health_and_safety_outlined,
                    label: 'Sehat-yu',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SehatYuScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(icon: Icons.school_outlined, label: 'Sekolah-yu'),
                  _MenuItem(
                    icon: Icons.mosque_outlined,
                    label: 'Ibadah-yu',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IbadahYuScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.beach_access_outlined,
                    label: 'Plesir-yu',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlesirYuScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(icon: Icons.work_outline, label: 'Kerja-yu'),
                  _MenuItem(
                    icon: Icons.grid_view,
                    label: 'Semua',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SemuaLayananScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.label, this.onTap});

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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 35),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
