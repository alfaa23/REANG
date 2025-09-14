import 'package:flutter/material.dart';
import 'package:reang_app/models/renbang_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:reang_app/screens/layanan/renbang/detail_renbang_screen.dart';
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

  // --- PERUBAHAN: State untuk lazy load ---
  bool _isUsulanInitiated = false;
  bool _isProgressInitiated = false;

  // --- PERBAIKAN: Menggunakan Future yang nullable untuk menghindari LateError ---
  Future<List<RenbangModel>>? _rencanaFuture;
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _rencanaFuture = ApiService().fetchRencanaPembangunan();
  }

  void _reloadData() {
    setState(() {
      // Saat refresh, reset juga filter ke "Semua"
      _selectedFilter = 0;
      _rencanaFuture = ApiService().fetchRencanaPembangunan();
    });
  }

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
                  _buildRencanaSection(),
                  // --- PERUBAHAN: Menerapkan lazy load ---
                  if (_isUsulanInitiated)
                    const UsulanPembangunanView()
                  else
                    Container(),
                  if (_isProgressInitiated)
                    const ProgressPembangunanView()
                  else
                    Container(),
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
            onTap: () => setState(() {
              _selectedMain = i;
              // --- PERUBAHAN: Set flag lazy load saat tab diklik pertama kali ---
              if (i == 1 && !_isUsulanInitiated) {
                _isUsulanInitiated = true;
              }
              if (i == 2 && !_isProgressInitiated) {
                _isProgressInitiated = true;
              }
            }),
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

  Widget _buildRencanaSection() {
    return FutureBuilder<List<RenbangModel>>(
      future: _rencanaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorView(context);
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada rencana pembangunan.'));
        }

        final allProjects = snapshot.data!;
        // --- PERUBAHAN: Filter dibuat dinamis dari data API ---
        final uniqueFilters = allProjects.map((p) => p.fitur).toSet().toList();
        final List<String> dynamicFilters = ['Semua', ...uniqueFilters];

        final filteredProjects = _selectedFilter == 0
            ? allProjects
            : allProjects
                  .where((p) => p.fitur == dynamicFilters[_selectedFilter])
                  .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rencana Pembangunan Indramayu',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFilterTabs(dynamicFilters),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredProjects.length,
                itemBuilder: (_, idx) {
                  return _RencanaProjectCard(project: filteredProjects[idx]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterTabs(List<String> filters) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(filters.length, (i) {
        final sel = i == _selectedFilter;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (i < filters.length) {
                setState(() => _selectedFilter = i);
              }
            },
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
                  filters[i],
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

  Widget _buildErrorView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: theme.hintColor, size: 64),
          const SizedBox(height: 16),
          Text(
            'Gagal Memuat Data',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Maaf, terjadi kesalahan. Periksa koneksi internet Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.hintColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _reloadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _RencanaProjectCard extends StatelessWidget {
  final RenbangModel project;
  const _RencanaProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: theme.cardColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailRenbangScreen(projectData: project),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PERUBAHAN: Header sekarang hanya berisi Image.network ---
            Image.network(
              project.gambar,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) {
                // Fallback jika gambar gagal, tampilkan header berwarna
                return Container(
                  height: 180,
                  color: project.headerColor,
                  alignment: Alignment.center,
                  child: Text(
                    project.fitur,
                    style: const TextStyle(color: Colors.white70, fontSize: 24),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.judul,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.fitur,
                    style: TextStyle(color: theme.hintColor, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.summary,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.business, size: 14, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text(
                        'Pemerintah Indramayu',
                        style: TextStyle(color: theme.hintColor, fontSize: 13),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: theme.hintColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                project.alamat,
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ],
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
