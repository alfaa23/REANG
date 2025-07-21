import 'package:flutter/material.dart';

class RenbangYuScreen extends StatefulWidget {
  const RenbangYuScreen({super.key});
  @override
  State<RenbangYuScreen> createState() => _RenbangYuScreenState();
}

class _RenbangYuScreenState extends State<RenbangYuScreen> {
  int _selectedMain = 0; // 0=Rencana, 1=Usulan, 2=Progress
  int _selectedFilter = 0; // hanya untuk Rencana

  // --- Data hardcoded untuk "Rencana" ---
  final List<String> _mainTabs = ['Rencana', 'Usulan', 'Progress'];
  final List<String> _filters = [
    'Semua',
    'Infrastruktur',
    'Pendidikan',
    'Kesehatan',
  ];
  // PERUBAHAN: Data dikembalikan menjadi Map<String, dynamic>
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

  // --- Data hardcoded untuk "Usulan" ---
  static const _usulanList = [
    {
      'title': 'Pembangunan Jembatan Penghubung',
      'category': 'Infrastruktur',
      'description':
          'Usulan pembangunan jembatan untuk menghubungkan desa A dan B',
      'user': 'Budi Santoso',
      'time': '2 hari lalu',
      'likes': 45,
      'status': 'Dalam Review',
      'statusColor': Color(0xFFFFA500),
    },
    {
      'title': 'Renovasi Pasar Tradisional',
      'category': 'Ekonomi',
      'description':
          'Perbaikan fasilitas pasar untuk meningkatkan kenyamanan pedagang',
      'user': 'Siti Aminah',
      'time': '5 hari lalu',
      'likes': 32,
      'status': 'Disetujui',
      'statusColor': Color(0xFF4CAF50),
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
              'Renbang–Yu',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold, // Ini untuk membuat teks menjadi tebal
              ),
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
            // TAB UTAMA
            _buildMainTabs(),
            const SizedBox(height: 16),

            // KONTEN BERDASARKAN TAB
            Expanded(
              child: IndexedStack(
                index: _selectedMain,
                children: [
                  _buildRencanaSection(),
                  _buildUsulanSection(),
                  _buildProgressSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Segmented control Rencana / Usulan / Progress
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

  /// SECTION “Rencana” (filter + list proyek)
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
        // Judul
        Text(
          'Rencana Pembangunan Indramayu',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Filter kategori
        _buildFilterTabs(),

        const SizedBox(height: 16),
        // Daftar proyek
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

  /// Segmented control untuk kategori di Rencana
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

  /// SECTION “Usulan”
  Widget _buildUsulanSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + tombol
        Row(
          children: [
            Expanded(
              child: Text(
                'Usulan Masyarakat',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {}, // TODO: tambah usulan
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah Usulan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // List usulan
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _usulanList.length,
            itemBuilder: (_, idx) => _UsulanCard(data: _usulanList[idx]),
          ),
        ),
      ],
    );
  }

  /// SECTION “Progress” (placeholder)
  Widget _buildProgressSection() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: theme.hintColor),
          const SizedBox(height: 16),
          Text(
            "Halaman Progress Pembangunan",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Fitur ini sedang dalam pengembangan.",
            style: TextStyle(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

/// Card proyek di Rencana
class _RencanaProjectCard extends StatelessWidget {
  // PERUBAHAN: Menerima Map, bukan objek Project
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
          // Header warna
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
          // Body
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

/// Card per-usulan di Usulan
class _UsulanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _UsulanCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    data['title'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (data['statusColor'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['status'],
                    style: TextStyle(
                      color: data['statusColor'] as Color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Kategori
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                data['category'],
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Deskripsi
            Text(
              data['description'],
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // User + waktu
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: theme.hintColor),
                const SizedBox(width: 6),
                Text(
                  '${data['user']} • ${data['time']}',
                  style: TextStyle(fontSize: 13, color: theme.hintColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Likes + komentar
            Row(
              children: [
                Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 16,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${data['likes']}',
                  style: TextStyle(fontSize: 13, color: theme.hintColor),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment_outlined, size: 16, color: theme.hintColor),
                const SizedBox(width: 4),
                Text(
                  'Komentar',
                  style: TextStyle(fontSize: 13, color: theme.hintColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
