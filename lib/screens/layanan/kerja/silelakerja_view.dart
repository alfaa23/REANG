import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SilelakerjaView extends StatefulWidget {
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
  bool _isWebViewInitialized = false;

  final String _url = 'https://silelakerjayu.indramayukab.go.id/';

  Timer? _loadTimeoutTimer;
  static const Duration _loadTimeout = Duration(seconds: 10);
  static const Duration _errorDebounce = Duration(milliseconds: 600);

  // untuk mencegah munculnya error karena gangguan singkat
  bool _errorDebounceActive = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _isWebViewInitialized = true;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // mulai loading -> tampilkan spinner
            _cancelLoadTimeout();
            setState(() {
              _isLoading = true;
              // jangan hapus _hasError di sini agar flicker kecil tidak memunculkan error
            });
            _startLoadTimeout();
          },
          onPageFinished: (url) {
            // selesai load -> batalkan timeout dan sembunyikan spinner & error
            _cancelLoadTimeout();
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          },
          onWebResourceError: (error) {
            // hanya tangani error untuk main frame agar resource kecil tidak memicu alt
            if (error.isForMainFrame == true) {
              _cancelLoadTimeout();

              // debounce singkat agar tidak sensitif
              if (_errorDebounceActive) return;

              _errorDebounceActive = true;
              Future.delayed(_errorDebounce, () {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                  });
                }
                // reset debounce flag
                Future.delayed(const Duration(milliseconds: 100), () {
                  _errorDebounceActive = false;
                });
              });
            }
          },
        ),
      );

    // mulai load awal
    _safeLoad(_url);

    widget.onWebViewCreated?.call(_controller);
  }

  /// load dengan try/catch dan timeout handling
  Future<void> _safeLoad(String url) async {
    try {
      // set loading state
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      _startLoadTimeout();
      await _controller.loadRequest(Uri.parse(url));
      // loadRequest sendiri tidak selalu melempar error ketika no network,
      // maka timeout dan onWebResourceError jadi backup
    } catch (e) {
      _cancelLoadTimeout();
      // jika exception runtime (jarang terjadi), tampilkan error setelah debounce
      if (_errorDebounceActive) return;
      _errorDebounceActive = true;
      Future.delayed(_errorDebounce, () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
        Future.delayed(const Duration(milliseconds: 100), () {
          _errorDebounceActive = false;
        });
      });
    }
  }

  void _startLoadTimeout() {
    _cancelLoadTimeout();
    _loadTimeoutTimer = Timer(_loadTimeout, () {
      if (mounted && _isLoading) {
        // anggap gagal setelah timeout
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    });
  }

  void _cancelLoadTimeout() {
    if (_loadTimeoutTimer?.isActive ?? false) {
      _loadTimeoutTimer?.cancel();
    }
  }

  Future<void> _onRetryPressed() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // coba load ulang
    await _safeLoad(_url);

    // jika setelah percobaan masih error, beri feedback
    if (mounted && _hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat. Periksa koneksi Anda.')),
      );
    }
  }

  @override
  void dispose() {
    _cancelLoadTimeout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // kalau ada error -> tampilkan alt view (tidak sensitif karena ada debounce + timeout)
    if (_hasError) {
      return _buildErrorView(context);
    }

    // kalau belum inisialisasi WebView dan tidak sedang loading -> tampilkan alt
    if (!_isWebViewInitialized && !_isLoading) {
      return _buildErrorView(context);
    }

    // default: tampilkan WebView dengan overlay loading
    return Stack(
      children: [
        if (_isWebViewInitialized)
          WebViewWidget(controller: _controller)
        else
          const SizedBox.shrink(),

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
            Icon(Icons.cloud_off, color: theme.hintColor, size: 72),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat halaman.\nPeriksa koneksi internet Anda lalu coba lagi.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onRetryPressed,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
