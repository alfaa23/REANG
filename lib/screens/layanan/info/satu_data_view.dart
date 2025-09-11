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
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError =
                    false; // Reset status error setiap kali mencoba memuat
              });
            }
          },
          onPageFinished: (url) {
            // Cek jika masih loading, berarti terjadi timeout atau error lain
            if (mounted && !_hasError) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            // Hanya tampilkan error jika halaman utama yang gagal dimuat,
            // bukan aset seperti gambar atau iklan.
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              }
            }
          },
          // --- TAMBAHAN: Menangkap error HTTP dari server ---
          onHttpError: (HttpResponseError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          // ---------------------------------------------------
        ),
      )
      ..loadRequest(Uri.parse(_url));

    widget.onControllerCreated(_controller);
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    // Memuat ulang request dari awal untuk penanganan error yang lebih baik
    _controller.loadRequest(Uri.parse(_url));
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
              onPressed: _retryLoading,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
