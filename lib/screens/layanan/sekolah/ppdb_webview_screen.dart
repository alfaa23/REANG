import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PpdbWebviewScreen extends StatefulWidget {
  const PpdbWebviewScreen({super.key});

  @override
  State<PpdbWebviewScreen> createState() => _PpdbWebviewScreenState();
}

class _PpdbWebviewScreenState extends State<PpdbWebviewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() => _loadingProgress = progress);
            }
          },
          // Mencegah pengguna keluar dari halaman PPDB
          onNavigationRequest: (request) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('PPDB Indramayu'),
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
