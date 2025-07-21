import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UpdateHargaPanganScreen extends StatefulWidget {
  const UpdateHargaPanganScreen({super.key});

  @override
  State<UpdateHargaPanganScreen> createState() =>
      _UpdateHargaPanganScreenState();
}

class _UpdateHargaPanganScreenState extends State<UpdateHargaPanganScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          // Hanya menampilkan progress bar saat loading
          onProgress: (progress) {
            if (mounted) {
              setState(() => _loadingProgress = progress);
            }
          },
          // Mencegah pengguna keluar dari halaman dashboard
          onNavigationRequest: (request) {
            if (request.url.startsWith('https://dashboard.jabarprov.go.id/')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://dashboard.jabarprov.go.id/id/dashboard-static/pangan',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Harga Pangan'),
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
