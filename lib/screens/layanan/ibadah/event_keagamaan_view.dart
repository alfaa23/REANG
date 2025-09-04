import 'package:flutter/material.dart';
import 'package:reang_app/models/event_keagamaan_model.dart';
import 'package:reang_app/services/api_service.dart';
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

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';

  late Future<List<EventKeagamaanModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _eventsFuture = ApiService().fetchEventKeagamaan();
    });
  }

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

    return GestureDetector(
      onTap: _unfocusGlobal,
      child: FutureBuilder<List<EventKeagamaanModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          // --- PERUBAHAN: Wrapper Column dipindahkan ke dalam kondisi sukses ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildFeedbackView(
              theme: theme,
              icon: Icons.cloud_off,
              title: 'Gagal Terhubung',
              subtitle: 'Periksa koneksi internet Anda dan coba lagi.',
              showRetryButton: true,
            );
          }

          final allEvents = snapshot.data ?? [];
          List<EventKeagamaanModel> filteredEvents = allEvents;

          if (_selectedAgama != 0) {
            filteredEvents = allEvents
                .where(
                  (event) => event.kategori == _agamaFilters[_selectedAgama],
                )
                .toList();
          }
          if (_searchQuery.isNotEmpty) {
            filteredEvents = filteredEvents
                .where(
                  (event) =>
                      event.judul.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      event.lokasi.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                )
                .toList();
          }

          final String searchHint = _selectedAgama == 0
              ? "Cari semua event..."
              : "Cari event ${_agamaFilters[_selectedAgama]}...";

          // Tampilan utama hanya dibangun jika ada data
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 8),
              _buildSearchBar(theme, searchHint),
              const SizedBox(height: 12),
              _buildFilterChips(),
              const SizedBox(height: 24),
              if (filteredEvents.isNotEmpty)
                ...filteredEvents.map(
                  (eventData) => _EventCard(
                    event: eventData,
                    onTap: () {
                      _unfocusGlobal();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailEventScreen(event: eventData),
                        ),
                      );
                    },
                  ),
                )
              else
                _buildFeedbackView(
                  theme: theme,
                  icon: Icons.search_off_rounded,
                  title: _searchQuery.isNotEmpty
                      ? 'Event tidak ditemukan'
                      : 'Belum Ada Event',
                  subtitle: _searchQuery.isNotEmpty
                      ? 'Maaf, coba perbaiki kata kunci pencarian Anda.'
                      : 'Saat ini belum ada event untuk kategori ${_agamaFilters[_selectedAgama]}.',
                ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET BARU: Menggabungkan empty state dan error state ---
  Widget _buildFeedbackView({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    bool showRetryButton = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.hintColor),
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
            if (showRetryButton) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, String hintText) {
    return Container(
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
          hintText: hintText,
          prefixIcon: Icon(Icons.search, color: theme.hintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
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
              _unfocusGlobal();
              if (selected) setState(() => _selectedAgama = i);
            },
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventKeagamaanModel event;
  final VoidCallback? onTap;

  const _EventCard({required this.event, this.onTap});

  String _stripHtml(String htmlText) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, ' ').replaceAll('&nbsp;', ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = event.isUpcoming ? "Akan Datang" : "Selesai";

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
                  event.icon,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                event.judul,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                event.lokasi,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              trailing: Chip(
                label: Text(status),
                backgroundColor: event.isUpcoming
                    ? Colors.green.withOpacity(0.2)
                    : theme.colorScheme.surfaceContainerHighest,
                labelStyle: TextStyle(
                  color: event.isUpcoming
                      ? Colors.green.shade800
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Image.network(
              event.foto,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 180,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stack) {
                return Container(
                  height: 180,
                  width: double.infinity,
                  color: event.color,
                  alignment: Alignment.center,
                  child: Text(
                    event.kategori,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
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
                      Text(
                        event.formattedDate,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 16, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text(
                        event.formattedTime,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _stripHtml(event.deskripsi),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
