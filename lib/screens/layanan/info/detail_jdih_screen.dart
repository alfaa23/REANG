import 'package:flutter/material.dart';
import 'package:reang_app/models/jdih_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DetailJdihScreen extends StatefulWidget {
  final PeraturanHukum peraturan;
  const DetailJdihScreen({super.key, required this.peraturan});

  @override
  State<DetailJdihScreen> createState() => _DetailJdihScreenState();
}

class _DetailJdihScreenState extends State<DetailJdihScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    final String url =
        'https://jdih.indramayukab.go.id/jdih/detail/${widget.peraturan.singkatanJenis}/${widget.peraturan.id}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => setState(() => _loadingProgress = progress),
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.peraturan.jenis,
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Ini untuk membuat teks menjadi tebal
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
