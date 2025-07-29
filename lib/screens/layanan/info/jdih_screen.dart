import 'package:flutter/material.dart';
import 'package:reang_app/models/jdih_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:reang_app/screens/layanan/info/detail_jdih_screen.dart';

class JdihScreen extends StatefulWidget {
  const JdihScreen({super.key});

  @override
  State<JdihScreen> createState() => _JdihScreenState();
}

class _JdihScreenState extends State<JdihScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<PeraturanHukum>> _jdihFuture;

  List<PeraturanHukum> _allPeraturan = [];
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = ['Semua', 'Perbup', 'Perda', 'Perdes'];

  @override
  void initState() {
    super.initState();
    _jdihFuture = _apiService.fetchJdih();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PeraturanHukum>>(
      future: _jdihFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          _allPeraturan = snapshot.data!;

          List<PeraturanHukum> displayedPeraturan = _allPeraturan;

          // Filter kategori
          if (_selectedFilter != 0) {
            String filterText = _filters[_selectedFilter].toLowerCase();
            displayedPeraturan = displayedPeraturan
                .where((p) => p.singkatanJenis.toLowerCase() == filterText)
                .toList();
          }

          // Filter pencarian
          if (_searchQuery.isNotEmpty) {
            displayedPeraturan = displayedPeraturan
                .where(
                  (p) => p.judul.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();
          }

          final String searchHint = _selectedFilter == 0
              ? 'Cari semua peraturan...'
              : 'Cari di ${_filters[_selectedFilter]}...';

          return _buildContentView(context, displayedPeraturan, searchHint);
        }
        return const Center(child: Text('Tidak ada dokumen tersedia.'));
      },
    );
  }

  Widget _buildContentView(
    BuildContext context,
    List<PeraturanHukum> peraturanList,
    String searchHint,
  ) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 16),
        Text(
          'Peraturan Perundang-undangan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Temukan dan akses dokumen hukum resmi Kabupaten Indramayu',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (c, i) => const SizedBox(width: 8),
            itemBuilder: (c, i) {
              final selected = i == _selectedFilter;
              return ChoiceChip(
                label: Text(_filters[i]),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    _selectedFilter = i;
                  });
                },
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                showCheckmark: false,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ...peraturanList
            .map((item) => _PeraturanCard(peraturan: item))
            .toList(),
      ],
    );
  }
}

class _PeraturanCard extends StatelessWidget {
  final PeraturanHukum peraturan;
  const _PeraturanCard({required this.peraturan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailJdihScreen(peraturan: peraturan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    peraturan.icon,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      peraturan.jenis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'No. ${peraturan.nomor} Tahun ${peraturan.tahun}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: peraturan.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      peraturan.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: peraturan.statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                peraturan.judul,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  fontSize: 16,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• Instansi: ${peraturan.pemrakarsa}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  Text(
                    "• Ditetapkan: ${peraturan.tanggalPenetapan}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  Text(
                    "• Penandatangan: ${peraturan.penandatangan}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
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
                        Icons.verified_outlined,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Dokumen Resmi',
                        style: TextStyle(fontSize: 14, color: theme.hintColor),
                      ),
                    ],
                  ),
                  Text(
                    'Detail ›',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
