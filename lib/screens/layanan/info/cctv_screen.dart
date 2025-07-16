import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CctvScreen extends StatefulWidget {
  const CctvScreen({super.key});

  @override
  State<CctvScreen> createState() => _CctvScreenState();
}

class _CctvScreenState extends State<CctvScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller untuk WebView
    _controller = WebViewController()
      // Mengaktifkan JavaScript yang penting untuk halaman CCTV
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          // Menampilkan loading indicator saat halaman mulai dimuat
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          // Menghilangkan loading indicator saat halaman selesai dimuat
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          // Mencegah pengguna keluar dari halaman CCTV
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://cctv.indramayukab.go.id/')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      // Memuat URL CCTV
      ..loadRequest(Uri.parse('https://cctv.indramayukab.go.id/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CCTV Indramayu')),
      // Menggunakan Stack untuk menumpuk WebView dengan loading indicator
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          // Tampilkan loading indicator jika halaman belum selesai dimuat
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
