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
  final List<String> _agamaFilters = [
    "Semua",
    "Islam",
    "Kristen",
    "Buddha",
    "Hindu",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
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
        const SizedBox(height: 8),
        // Search bar langsung di bawah gridview
        TextField(
          decoration: InputDecoration(
            hintText: "Cari berdasarkan nama atau lokasi...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        // Filter Agama sekarang bisa di-scroll ke samping
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
                  if (selected) setState(() => _selectedAgama = i);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        const _MasjidCard(),
      ],
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

// Widget baru untuk Kartu Masjid Gedhe
class _MasjidCard extends StatelessWidget {
  const _MasjidCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.purple),
                alignment: Alignment.center,
                child: const Text(
                  "Masjid Gedhe",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
                  child: const Text(
                    "6 jam lalu",
                    style: TextStyle(color: Colors.white, fontSize: 12),
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
                  "Masjid Gedhe Kauman",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Jl. Katedral No.7B, Jakarta Pusat",
                  style: TextStyle(color: theme.hintColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(width: 8),
                    Text("Admin Desa", style: theme.textTheme.bodyMedium),
                    const Spacer(),
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Yogyakarta",
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Lihat detail",
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
    );
  }
}
