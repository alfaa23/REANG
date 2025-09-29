import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reang_app/models/banner_model.dart';
import 'package:reang_app/screens/home/widgets/detail_banner_screen.dart';
import 'package:reang_app/services/api_service.dart';

class InfoBannerWidget extends StatefulWidget {
  const InfoBannerWidget({super.key});

  @override
  State<InfoBannerWidget> createState() => _InfoBannerWidgetState();
}

class _InfoBannerWidgetState extends State<InfoBannerWidget> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  late Future<List<BannerModel>> _bannerFuture;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95, initialPage: 0);
    _bannerFuture = ApiService().fetchBanner().then((banners) {
      if (mounted && banners.isNotEmpty) {
        _startAutoScroll(banners.length);
      }
      return banners;
    });
  }

  void _startAutoScroll(int itemCount) {
    _timer = Timer.periodic(const Duration(seconds: 9), (timer) {
      if (_pageController.hasClients && itemCount > 0) {
        int nextPage = (_currentPage + 1) % itemCount;
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
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerModel>>(
      future: _bannerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSliderPlaceholder(); // Tampilkan placeholder saat loading
        }
        if (snapshot.hasError) {
          return _buildSliderPlaceholder(
            isError: true,
            errorMessage: snapshot.error.toString(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Sembunyikan jika data kosong
        }

        final banners = snapshot.data!;

        return Column(
          children: [
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double scale = 1.0;
                      if (_pageController.position.haveDimensions) {
                        double page = _pageController.page!;
                        double diff = (page - index).abs();
                        scale = (1 - (diff * 0.18)).clamp(0.82, 1.0);
                      }
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailBannerScreen(bannerData: banner),
                          ),
                        );
                      },
                      child: _buildImageCard(banner.imageUrl),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (index) {
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
      },
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0),
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
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _placeholder(),
          ),
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

  Widget _buildSliderPlaceholder({bool isError = false, String? errorMessage}) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: isError
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Gagal memuat banner:\n$errorMessage',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
