import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/renbang/usulan_pembangunan_view.dart';
import 'package:reang_app/screens/layanan/renbang/progress_pembangunan_view.dart';

class RenbangYuScreen extends StatefulWidget {
  const RenbangYuScreen({super.key});
  @override
  State<RenbangYuScreen> createState() => _RenbangYuScreenState();
}

class _RenbangYuScreenState extends State<RenbangYuScreen> {
  int _selectedMain = 0;
  final List<String> _mainTabs = ['Rencana', 'Usulan', 'Progress'];

  // --- KODE DARI RENCANA_PEMBANGUNAN_VIEW DIPINDAHKAN KE SINI ---
  int _selectedFilter = 0;

  final List<String> _filters = const [
    'Semua',
    'Infrastruktur',
    'Pendidikan',
    'Kesehatan',
  ];

  final List<Map<String, dynamic>> _projects = const [
    {
      'title': 'Jalan Tol Indramayu',
      'subtitle': 'Pembangunan Jalan Tol Indramayu',
      'category': 'Infrastruktur',
      'description':
          'Pembangunan jalan tol sepanjang 25 km untuk meningkatkan konektivitas dan perekonomian daerah Indramayu',
      'department': 'Dinas PU Indramayu',
      'location': 'Indramayu, Jawa Barat',
      'headerColor': Color(0xFFFF6B6B),
    },
    {
      'title': 'Rumah Sakit Baru',
      'subtitle': 'Pembangunan RS Indramayu Baru',
      'category': 'Kesehatan',
      'description':
          'Pembangunan rumah sakit modern dengan kapasitas 300 tempat tidur dan fasilitas medis terlengkap',
      'department': 'Dinas Kesehatan',
      'location': 'Kec. Indramayu',
      'headerColor': Color(0xFF4ECDC4),
    },
    {
      'title': 'Sekolah Vokasi',
      'subtitle': 'Sekolah Vokasi Maritim',
      'category': 'Pendidikan',
      'description':
          'Pembangunan sekolah vokasi maritim untuk mengembangkan SDM sektor kelautan dan perikanan',
      'department': 'Dinas Pendidikan',
      'location': 'Kec. Patrol',
      'headerColor': Color(0xFF1A535C),
    },
  ];
  // ----------------------------------------------------------------

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
              'Renbang–Yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Rencana pembangunan Indramayu',
              style: TextStyle(color: theme.hintColor, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildMainTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: _selectedMain,
                children: [
                  // --- PERUBAHAN: Memanggil fungsi internal, bukan view terpisah ---
                  _buildRencanaSection(),
                  const UsulanPembangunanView(),
                  const ProgressPembangunanView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTabs() {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(_mainTabs.length, (i) {
        final sel = i == _selectedMain;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMain = i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _mainTabs[i],
                  style: TextStyle(
                    color: sel
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- FUNGSI BARU: Logika dan UI untuk tab "Rencana" ---
  Widget _buildRencanaSection() {
    final theme = Theme.of(context);
    final filtered = _selectedFilter == 0
        ? _projects
        : _projects
              .where(
                (p) => (p['category'] as String).toLowerCase().contains(
                  _filters[_selectedFilter].toLowerCase(),
                ),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rencana Pembangunan Indramayu',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildFilterTabs(),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (_, idx) {
              final p = filtered[idx];
              return _RencanaProjectCard(project: p);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(_filters.length, (i) {
        final sel = i == _selectedFilter;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _filters[i],
                  style: TextStyle(
                    fontSize: 13,
                    color: sel
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // --------------------------------------------------------
}

// --- WIDGET CARD UNTUK RENCANA JUGA DIPINDAHKAN KE SINI ---
class _RencanaProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  const _RencanaProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: theme.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: project['headerColor'] as Color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            alignment: Alignment.bottomLeft,
            child: Text(
              project['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project['subtitle'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  project['category'],
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 60),
                  child: Text(
                    project['description'],
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: theme.hintColor),
                    const SizedBox(width: 6),
                    Text(
                      project['department'],
                      style: TextStyle(color: theme.hintColor, fontSize: 13),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          project['location'],
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Lihat detail ›'),
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
