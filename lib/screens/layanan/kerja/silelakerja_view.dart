import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SilelakerjaView extends StatefulWidget {
  // Callback untuk mengirim controller ke parent
  final Function(WebViewController)? onWebViewCreated;

  const SilelakerjaView({super.key, this.onWebViewCreated});

  @override
  State<SilelakerjaView> createState() => _SilelakerjaViewState();
}

class _SilelakerjaViewState extends State<SilelakerjaView>
    with AutomaticKeepAliveClientMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  final String _url = 'https://silelakerjayu.indramayukab.go.id/';

  // Ini memberitahu Flutter untuk menjaga state widget ini tetap hidup.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() {
            _isLoading = true;
            _hasError = false;
          }),
          onPageFinished: (url) => setState(() => _isLoading = false),
          // PERBAIKAN: Menggunakan onWebResourceError yang sesuai dengan versi package Anda
          onWebResourceError: (error) => setState(() {
            _isLoading = false;
            _hasError = true;
          }),
        ),
      )
      ..loadRequest(Uri.parse(_url));

    // Kirim controller ke parent setelah dibuat
    widget.onWebViewCreated?.call(_controller);
  }

  @override
  Widget build(BuildContext context) {
    // Panggil super.build(context) yang merupakan syarat dari mixin
    super.build(context);

    if (_hasError) {
      return _buildErrorView(context);
    }
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: theme.hintColor, size: 64),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat halaman. Periksa koneksi internet Anda.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _controller.loadRequest(Uri.parse(_url)),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
