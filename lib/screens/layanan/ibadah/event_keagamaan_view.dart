import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/ibadah/detail_event_screen.dart';

class EventKeagamaanView extends StatefulWidget {
  const EventKeagamaanView({super.key});

  @override
  State<EventKeagamaanView> createState() => _EventKeagamaanViewState();
}

class _EventKeagamaanViewState extends State<EventKeagamaanView> {
  int _selectedAgama = 0;
  final List<String> _agamaFilters = [
    "Semua",
    "Islam",
    "Kristen",
    "Buddha",
    "Hindu",
  ];

  // PENAMBAHAN BARU: State untuk search bar
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';

  // PENAMBAHAN BARU: Data dummy untuk event
  final List<Map<String, dynamic>> _allEvents = [
    {
      'icon': Icons.mosque,
      'title': "Kajian Tafsir Al-Quran",
      'subtitle': "Masjid Al-Ikhlas",
      'label': "Kajian",
      'status': "Akan Datang",
      'color': Colors.green,
      'date': "Senin, 25 Agustus 2025",
      'time': "19:30",
      'desc': "Kajian rutin setiap Senin malam tentang tafsir Al-Quran",
      'isUpcoming': true,
      'agama': 'Islam',
    },
    {
      'icon': Icons.church,
      'title': "Kebaktian Minggu Pagi",
      'subtitle': "GKI Salemba",
      'label': "Ibadah",
      'status': "Akan Datang",
      'color': Colors.blue,
      'date': "Minggu, 24 Agustus 2025",
      'time': "08:00",
      'desc': "Kebaktian minggu pagi dengan tema Kasih Kristus",
      'isUpcoming': true,
      'agama': 'Kristen',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // PENAMBAHAN BARU: Helper untuk unfocus global
  void _unfocusGlobal() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // PERBAIKAN: Logika filter dan search diterapkan di sini
    List<Map<String, dynamic>> filteredEvents = _allEvents;
    if (_selectedAgama != 0) {
      filteredEvents = _allEvents
          .where((event) => event['agama'] == _agamaFilters[_selectedAgama])
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredEvents = filteredEvents
          .where(
            (event) =>
                (event['title'] as String).toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (event['subtitle'] as String).toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // PERBAIKAN: Menggunakan GestureDetector dengan logika dari KerjaYuScreen
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        final focused = FocusManager.instance.primaryFocus;
        if (focused != null && focused.context != null) {
          try {
            final renderObject = focused.context!.findRenderObject();
            if (renderObject is RenderBox) {
              final box = renderObject;
              final topLeft = box.localToGlobal(Offset.zero);
              final rect = topLeft & box.size;
              // Jika ketukan DI LUAR widget yang sedang fokus -> unfocus
              if (!rect.contains(details.globalPosition)) {
                _unfocusGlobal();
              }
            } else {
              _unfocusGlobal();
            }
          } catch (_) {
            _unfocusGlobal();
          }
        } else {
          _unfocusGlobal();
        }
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 8),
          // PERBAIKAN: Tampilan search bar diubah
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
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _agamaFilters.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (c, i) {
                return ChoiceChip(
                  label: Text(_agamaFilters[i]),
                  selected: _selectedAgama == i,
                  onSelected: (selected) {
                    _unfocusGlobal(); // Unfocus saat filter dipilih
                    if (selected) setState(() => _selectedAgama = i);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // PERBAIKAN: Menampilkan hasil filter atau pesan alternatif
          if (filteredEvents.isNotEmpty)
            ...filteredEvents.map(
              (eventData) => _EventCard(
                icon: eventData['icon'],
                title: eventData['title'],
                subtitle: eventData['subtitle'],
                label: eventData['label'],
                status: eventData['status'],
                color: eventData['color'],
                date: eventData['date'],
                time: eventData['time'],
                desc: eventData['desc'],
                isUpcoming: eventData['isUpcoming'],
                onTap: () {
                  _unfocusGlobal(); // Unfocus sebelum pindah halaman
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DetailEventScreen(),
                    ),
                  );
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
      title = 'Maaf, event tidak ditemukan';
      subtitle = 'Coba cek ulang penulisan atau\ngunakan kata kunci lainnya.';
    } else {
      // Jika kosong karena filter
      final jenis = _agamaFilters[_selectedAgama];
      title = 'Event $jenis Belum Tersedia';
      subtitle =
          'Saat ini belum ada jadwal event untuk\nkategori $jenis yang terdaftar.';
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

class _EventCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, label, status, date, time, desc;
  final Color color;
  final bool isUpcoming;
  final VoidCallback? onTap;

  const _EventCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.status,
    required this.color,
    required this.date,
    required this.time,
    required this.desc,
    required this.isUpcoming,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              trailing: Chip(
                label: Text(status),
                backgroundColor: isUpcoming
                    ? Colors.green.withOpacity(0.2)
                    : theme.colorScheme.surfaceContainerHighest,
                labelStyle: TextStyle(
                  color: isUpcoming
                      ? Colors.green.shade800
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              height: 120,
              width: double.infinity,
              color: color,
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 6),
                      Text(date, style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 16, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text(time, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
