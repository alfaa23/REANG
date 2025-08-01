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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Cari berdasarkan nama atau lokasi...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  if (selected) setState(() => _selectedAgama = i);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        _EventCard(
          icon: Icons.mosque,
          title: "Kajian Tafsir Al-Quran",
          subtitle: "Masjid Al-Ikhlas",
          label: "Kajian",
          status: "Akan Datang",
          color: Colors.green,
          date: "Senin, 15 Januari 2024",
          time: "19:30",
          desc: "Kajian rutin setiap Senin malam tentang tafsir Al-Quran",
          isUpcoming: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DetailEventScreen()),
          ),
        ),
        _EventCard(
          icon: Icons.church,
          title: "Kebaktian Minggu Pagi",
          subtitle: "GKI Salemba",
          label: "Ibadah",
          status: "Akan Datang",
          color: Colors.blue,
          date: "Minggu, 14 Januari 2024",
          time: "08:00",
          desc: "Kebaktian minggu pagi dengan tema Kasih Kristus",
          isUpcoming: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DetailEventScreen()),
          ),
        ),
      ],
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
    // PERBAIKAN: Variabel theme sekarang digunakan di seluruh widget
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
