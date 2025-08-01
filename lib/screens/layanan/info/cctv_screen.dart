import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Widget ini hanya berisi konten WebView untuk CCTV.
/// Dibuat terpisah agar bisa "lazy load" (dimuat saat dibutuhkan).
class CctvView extends StatefulWidget {
  const CctvView({super.key});

  @override
  State<CctvView> createState() => _CctvViewState();
}

class _CctvViewState extends State<CctvView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            if (request.url.startsWith('https://cctv.indramayukab.go.id/')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://cctv.indramayukab.go.id/'));
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
