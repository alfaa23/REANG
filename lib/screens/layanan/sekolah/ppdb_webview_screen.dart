import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Widget ini hanya berisi konten WebView untuk PPDB.
/// Dibuat terpisah agar bisa "lazy load" (dimuat saat dibutuhkan).
class PpdbWebView extends StatefulWidget {
  const PpdbWebView({super.key});

  @override
  State<PpdbWebView> createState() => _PpdbWebViewState();
}

class _PpdbWebViewState extends State<PpdbWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(
              'https://spmb-smp.disdik.indramayukab.go.id/',
            )) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://spmb-smp.disdik.indramayukab.go.id/'));
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
