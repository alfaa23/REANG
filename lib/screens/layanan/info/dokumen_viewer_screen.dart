import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DokumenViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const DokumenViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<DokumenViewerScreen> createState() => _DokumenViewerScreenState();
}

class _DokumenViewerScreenState extends State<DokumenViewerScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => setState(() => _loadingProgress = progress),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
