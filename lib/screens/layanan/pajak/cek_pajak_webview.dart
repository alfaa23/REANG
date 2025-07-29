import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Widget ini hanya berisi konten WebView untuk Cek Pajak.
/// Dibuat terpisah agar bisa "lazy load" (dimuat saat dibutuhkan).
class CekPajakWebView extends StatefulWidget {
  const CekPajakWebView({super.key});

  @override
  State<CekPajakWebView> createState() => _CekPajakWebViewState();
}

class _CekPajakWebViewState extends State<CekPajakWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            if (request.url.startsWith(
              'https://cekpajak.indramayukab.go.id/',
            )) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://cekpajak.indramayukab.go.id/portlet.php'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
