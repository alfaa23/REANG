import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/pajak/cek_pajak_webview.dart';

class PajakYuScreen extends StatefulWidget {
  const PajakYuScreen({super.key});
  @override
  State<PajakYuScreen> createState() => _PajakYuScreenState();
}

class _PajakYuScreenState extends State<PajakYuScreen> {
  int _selectedTab = 0; // 0=Info Pajak, 1=Cek Pajak
  bool _isWebViewInitiated = false;

  final List<Map<String, dynamic>> _articles = const [
    {
      'category': 'Pajak Kendaraan',
      'timeAgo': '2 jam lalu',
      'title': 'Cara Mudah Bayar Pajak Kendaraan Online',
      'description':
          'Kini membayar pajak kendaraan tahunan bisa dilakukan dari rumah melalui aplikasi resmi Samsat digital.',
      'author': 'Bapenda Indramayu',
    },
    {
      'category': 'Pajak Bumi & Bangunan',
      'timeAgo': '4 jam lalu',
      'title': 'Jatuh Tempo Pembayaran PBB Semakin Dekat',
      'description':
          'Wajib pajak diimbau segera melunasi PBB sebelum jatuh tempo untuk menghindari denda keterlambatan.',
      'author': 'Bapenda Indramayu',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pajak‑Yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Informasi dan pengecekan pajak daerah Indramayu',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Info Pajak', 'Cek Pajak'].asMap().entries.map((e) {
                final i = e.key;
                final label = e.value;
                final sel = i == _selectedTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedTab = i;
                      if (i == 1 && !_isWebViewInitiated) {
                        _isWebViewInitiated = true;
                      }
                    }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            color: sel
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildInfoPajakView(theme),
                _isWebViewInitiated ? const CekPajakWebView() : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPajakView(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Informasi Seputar Pajak',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ketahui jenis pajak yang berlaku di daerah Anda dan cara mengurusnya.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        ),
        const SizedBox(height: 16),
        ..._articles.map((a) => _ArticleCard(data: a)).toList(),
      ],
    );
  }
}

/// Kartu artikel pajak
class _ArticleCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ArticleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header dengan tinggi 180
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  data['category'],
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['timeAgo'],
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          // Body dengan deskripsi max 3 baris
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data['description'],
                  maxLines: 3, // Diubah dari 2 menjadi 3 baris
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.hintColor),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: theme.hintColor),
                    const SizedBox(width: 6),
                    Text(
                      data['author'],
                      style: TextStyle(fontSize: 13, color: theme.hintColor),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Baca selengkapnya ›'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
