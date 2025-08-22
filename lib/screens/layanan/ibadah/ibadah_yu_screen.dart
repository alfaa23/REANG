import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/ibadah/event_keagamaan_view.dart';
import 'package:reang_app/screens/layanan/ibadah/waktu_ibadah_view.dart';

class IbadahYuScreen extends StatefulWidget {
  const IbadahYuScreen({super.key});

  @override
  State<IbadahYuScreen> createState() => _IbadahYuScreenState();
}

class _IbadahYuScreenState extends State<IbadahYuScreen> {
  int _selectedTab = 0;
  bool _isEventInitiated = false;
  bool _isWaktuInitiated = false;

  final List<String> _tabs = ["Tempat Ibadah", "Event", "Waktu Ibadah"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset:
          false, // Prevents content from moving when keyboard appears
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ibadah-Yu",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Platform layanan keagamaan digital",
              style: TextStyle(color: theme.hintColor, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final i = entry.key;
                final label = entry.value;
                final sel = i == _selectedTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = i;
                        if (i == 1 && !_isEventInitiated) {
                          _isEventInitiated = true;
                        }
                        if (i == 2 && !_isWaktuInitiated) {
                          _isWaktuInitiated = true;
                        }
                      });
                    },
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
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
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
                const _TempatIbadahView(),
                if (_isEventInitiated)
                  const EventKeagamaanView()
                else
                  Container(),
                if (_isWaktuInitiated) const WaktuIbadahView() else Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- KONTEN TAB "TEMPAT IBADAH" ---
class _TempatIbadahView extends StatefulWidget {
  const _TempatIbadahView();

  @override
  State<_TempatIbadahView> createState() => _TempatIbadahViewState();
}

class _TempatIbadahViewState extends State<_TempatIbadahView> {
  int _selectedAgama = 0;
  // PERBAIKAN: Tipe data diubah dari List<String> menjadi List<Map<String, String>>
  final List<Map<String, String>> _agamaFilters = [
    {"nama": "Semua", "jenis": "Tempat Ibadah"},
    {"nama": "Islam", "jenis": "Masjid"},
    {"nama": "Kristen", "jenis": "Gereja"},
    {"nama": "Buddha", "jenis": "Vihara"},
    {"nama": "Hindu", "jenis": "Pura"},
  ];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allTempatIbadah = [
    {
      'nama': 'Masjid Agung Indramayu',
      'alamat': 'Jl. Jenderal Sudirman No. 12, Indramayu',
      'agama': 'Islam',
    },
    {
      'nama': 'Gereja Kristen Pasundan',
      'alamat': 'Jl. Kartini No. 5, Indramayu',
      'agama': 'Kristen',
    },
    {
      'nama': 'Vihara Dharma Rahayu',
      'alamat': 'Jl. Cimanuk No. 150, Indramayu',
      'agama': 'Buddha',
    },
    {
      'nama': 'Masjid Jami Al-Istiqomah',
      'alamat': 'Jl. Raya Jatibarang No. 201, Jatibarang',
      'agama': 'Islam',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _unfocusGlobal() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Logika filter diterapkan di sini
    List<Map<String, dynamic>> filteredList = _allTempatIbadah;
    if (_selectedAgama != 0) {
      filteredList = _allTempatIbadah
          .where(
            (item) => item['agama'] == _agamaFilters[_selectedAgama]['nama'],
          )
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList
          .where(
            (item) =>
                item['nama'].toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                item['alamat'].toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return GestureDetector(
      onTap: _unfocusGlobal,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            "Cari Tempat Ibadah Terdekat",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _IbadahCard(
                title: "Masjid Terdekat",
                emoji: "🕌",
                color: Colors.green,
              ),
              _IbadahCard(
                title: "Gereja Terdekat",
                emoji: "⛪",
                color: Colors.blue,
              ),
              _IbadahCard(
                title: "Vihara Terdekat",
                emoji: "🏛️",
                color: Colors.orange,
              ),
              _IbadahCard(
                title: "Pura Terdekat",
                emoji: "🛕",
                color: Colors.pink,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              focusNode: _searchFocus,
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Cari berdasarkan nama atau lokasi...",
                prefixIcon: Icon(Icons.search, color: theme.hintColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _agamaFilters.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (c, i) {
                return ChoiceChip(
                  // PERBAIKAN: Mengakses kunci 'nama' dari map
                  label: Text(_agamaFilters[i]['nama']!),
                  selected: _selectedAgama == i,
                  onSelected: (selected) {
                    _unfocusGlobal();
                    if (selected) setState(() => _selectedAgama = i);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // PERBAIKAN: Menampilkan daftar hasil filter atau pesan alternatif
          if (filteredList.isNotEmpty)
            ...filteredList.map(
              (data) => _MasjidCard(
                data: data,
                onTap: () {
                  _unfocusGlobal();
                },
              ),
            )
          else
            _buildEmptyState(theme),
        ],
      ),
    );
  }

  // PENAMBAHAN BARU: Widget untuk menampilkan pesan saat data kosong
  Widget _buildEmptyState(ThemeData theme) {
    String title;
    String subtitle;

    if (_searchQuery.isNotEmpty) {
      // Jika kosong karena pencarian
      title = 'Maaf, pencarianmu tidak ada';
      subtitle = 'Coba cek ulang penulisan atau\ngunakan kata kunci lainnya.';
    } else {
      // Jika kosong karena filter
      // PERBAIKAN: Mengakses kunci 'jenis' dari map
      final jenis = _agamaFilters[_selectedAgama]['jenis'];
      title = 'Data $jenis Belum Tersedia';
      subtitle =
          'Saat ini data untuk $jenis di Indramayu\nbelum terdaftar di sistem kami.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _IbadahCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  const _IbadahCard({
    required this.title,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      child: Text(
        "$emoji\n$title",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _MasjidCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _MasjidCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.mosque,
                    size: 64,
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(
                      0.5,
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
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data['agama'],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['nama'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['alamat'],
                    style: TextStyle(color: theme.hintColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "Lihat Lokasi", // PERBAIKAN: Teks diubah
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
