import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/ibadah/ibadah_yu_screen.dart';
import 'package:reang_app/screens/layanan/semua_layanan_screen.dart';
import 'package:reang_app/screens/layanan/sehat/sehat_yu_screen.dart';
import 'package:reang_app/screens/layanan/dumas/dumas_yu_screen.dart';
import 'package:reang_app/screens/layanan/info/info_yu_screen.dart';
import 'package:reang_app/screens/layanan/plesir/plesir_yu_screen.dart';
import 'package:reang_app/screens/layanan/sekolah/sekolah_yu_screen.dart';
import 'package:reang_app/screens/layanan/pasar/pasar_yu_screen.dart';

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
    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.9,
    );
    _current = _initialPage % imgList.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
                    assetIcon: 'assets/icons/dumas_yu.webp',
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
                    assetIcon: 'assets/icons/info_yu.webp',
                    label: 'Info-yu',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InfoYuScreen()),
                      );
                    },
                  ),
                  _MenuItem(
                    assetIcon: 'assets/icons/sehat_yu.webp',
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
                    assetIcon: 'assets/icons/sekolah_yu.webp',
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
                    assetIcon: 'assets/icons/ibadah_yu.webp',
                    label: 'Ibadah-yu',
                    imagePadding: const EdgeInsets.all(0.0),
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
                    assetIcon: 'assets/icons/plesir_yu.webp',
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
                    assetIcon: 'assets/icons/pasar_yu.webp',
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
            const SizedBox(height: 24),
          ],
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
  final EdgeInsets? imagePadding;

  const _MenuItem({
    this.assetIcon,
    this.icon,
    required this.label,
    this.onTap,
    this.imagePadding,
  }) : assert(
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
            // PERBAIKAN: Ukuran lingkaran diperkecil
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: assetIcon != null
                ? Padding(
                    padding: imagePadding ?? const EdgeInsets.all(1.5),
                    child: Image.asset(assetIcon!, fit: BoxFit.contain),
                  )
                : Icon(icon, color: theme.colorScheme.primary, size: 35),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              // PERBAIKAN: Menggunakan fontWeight.w600 untuk efek "semi-bold"
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
