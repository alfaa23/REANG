import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WifiYuScreen extends StatefulWidget {
  const WifiYuScreen({super.key});

  @override
  State<WifiYuScreen> createState() => _WifiYuScreenState();
}

class _WifiYuScreenState extends State<WifiYuScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    const String mapUrl =
        'https://www.google.com/maps/d/viewer?mid=1BuVIj-BvR50hRePa9qCC2iwGdRRQCuE&femb=1&ll=-6.439125615711617%2C108.1571115134699&z=11';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() => _loadingProgress = progress);
            }
          },
          // Mencegah pengguna keluar dari halaman peta
          onNavigationRequest: (request) {
            if (request.url.startsWith('https://www.google.com/maps/')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(mapUrl));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // Header dibuat sesuai contoh, dengan warna dari tema
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wifi-Yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Informasi titik - titik lokasi wifi',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
        // Menampilkan progress bar saat halaman dimuat
        bottom: _loadingProgress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(value: _loadingProgress / 100),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
