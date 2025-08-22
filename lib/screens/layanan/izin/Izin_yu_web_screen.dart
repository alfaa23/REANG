import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IzinYuWebScreen extends StatefulWidget {
  const IzinYuWebScreen({super.key});

  @override
  State<IzinYuWebScreen> createState() => _IzinYuWebScreenState();
}

class _IzinYuWebScreenState extends State<IzinYuWebScreen> {
  int _selectedTabIndex = 0;

  // Controller dan State untuk WebView 1 (Simpan Ayu)
  late final WebViewController _simpanAyuController;
  int _simpanAyuLoadingProgress = 0;
  final String _simpanAyuUrl = 'https://simpan-ayu.indramayukab.go.id/';

  // Controller dan State untuk WebView 2 (MPP)
  WebViewController? _mppController; // Dibuat nullable untuk lazy load
  int _mppLoadingProgress = 0;
  final String _mppUrl = 'https://mpp.indramayukab.go.id/';
  bool _isMppInitiated = false; // Flag untuk lazy load

  @override
  void initState() {
    super.initState();
    _initializeSimpanAyuWebView();
  }

  void _initializeSimpanAyuWebView() {
    _simpanAyuController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _simpanAyuLoadingProgress = progress);
          },
          onPageStarted: (url) {
            if (mounted) setState(() => _simpanAyuLoadingProgress = 0);
          },
        ),
      )
      ..loadRequest(Uri.parse(_simpanAyuUrl));
  }

  void _initializeMppWebView() {
    _mppController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _mppLoadingProgress = progress);
          },
          onPageStarted: (url) {
            if (mounted) setState(() => _mppLoadingProgress = 0);
          },
        ),
      )
      ..loadRequest(Uri.parse(_mppUrl));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        final activeController = _selectedTabIndex == 0
            ? _simpanAyuController
            : _mppController;
        if (activeController != null && await activeController.canGoBack()) {
          await activeController.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Layanan Online',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Ajukan perizinan secara online',
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: _buildProgressBar(),
          ),
        ),
        body: Column(
          children: [
            _buildFilterTabs(context),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  WebViewWidget(controller: _simpanAyuController),
                  _isMppInitiated
                      ? WebViewWidget(controller: _mppController!)
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _selectedTabIndex == 0
        ? _simpanAyuLoadingProgress
        : _mppLoadingProgress;
    if (progress < 100) {
      return LinearProgressIndicator(value: progress / 100);
    }
    return const SizedBox.shrink();
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip(context, label: 'Simpan Ayu', index: 0),
          ),
          const SizedBox(width: 12),
          Expanded(child: _buildFilterChip(context, label: 'MPP', index: 1)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required int index,
  }) {
    final theme = Theme.of(context);
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          if (index == 1 && !_isMppInitiated) {
            _isMppInitiated = true;
            _initializeMppWebView();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
