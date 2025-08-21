import 'dart:async';
import 'package:flutter/material.dart';

final List<String> imgList = [
  'assets/coba.jpg',
  'assets/banner_2.png',
  'assets/banner_3.png',
];

class InfoBannerWidget extends StatefulWidget {
  const InfoBannerWidget({super.key});

  @override
  State<InfoBannerWidget> createState() => _InfoBannerWidgetState();
}

class _InfoBannerWidgetState extends State<InfoBannerWidget> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Lebih rendah untuk menambah gap antar banner (tweak ini jika ingin lebih/kurang)
    _pageController = PageController(
      viewportFraction: 0.9, // 90% dari lebar layar
      initialPage: _currentPage,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 13), (timer) {
      if (_pageController.hasClients && imgList.isNotEmpty) {
        int nextPage = (_currentPage + 1) % imgList.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
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
    final int itemCount = imgList.isNotEmpty ? imgList.length : 1;

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            itemCount: itemCount,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final String? imagePath = imgList.isNotEmpty
                  ? imgList[index]
                  : null;

              // Animated scaling berdasarkan posisi page untuk menonjolkan page tengah
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  try {
                    if (_pageController.hasClients &&
                        _pageController.position.haveDimensions) {
                      double page =
                          _pageController.page ??
                          _pageController.initialPage.toDouble();
                      double diff = (page - index).abs();
                      // scale range: 0.82 .. 1.0  (ubah 0.18 untuk lebih/kurang kontras)
                      scale = (1 - (diff * 0.18)).clamp(0.82, 1.0);
                    } else {
                      // saat belum lay out, gunakan default bergantung index
                      scale = (index == _currentPage) ? 1.0 : 0.9;
                    }
                  } catch (_) {
                    scale = (index == _currentPage) ? 1.0 : 0.9;
                  }

                  return Transform.scale(scale: scale, child: child);
                },
                child: _buildImageCard(imagePath),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (imgList.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imgList.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildImageCard(String? imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 0.0,
      ), // tetap seperti permintaanmu
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath != null)
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            )
          else
            _placeholder(),
          // ringan overlay agar foto seragam tampilannya
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.06),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
      ),
    );
  }
}
