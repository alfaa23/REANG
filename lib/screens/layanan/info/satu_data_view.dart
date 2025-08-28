import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SatuDataView extends StatefulWidget {
  final Function(WebViewController) onControllerCreated;

  const SatuDataView({super.key, required this.onControllerCreated});

  @override
  State<SatuDataView> createState() => _SatuDataViewState();
}

class _SatuDataViewState extends State<SatuDataView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  final String _url = 'https://1data.indramayukab.go.id/';

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
          onWebResourceError: (error) => setState(() {
            _isLoading = false;
            _hasError = true;
          }),
        ),
      )
      ..loadRequest(Uri.parse(_url));

    widget.onControllerCreated(_controller);
  }

  @override
  Widget build(BuildContext context) {
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
