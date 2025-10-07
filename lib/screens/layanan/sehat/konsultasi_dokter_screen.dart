import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:reang_app/models/puskesmas_model.dart';
import 'package:reang_app/screens/layanan/sehat/detail_puskesmas_screen.dart';
import 'package:reang_app/services/api_service.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;
  Debouncer({required this.milliseconds});
  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class KonsultasiDokterScreen extends StatefulWidget {
  const KonsultasiDokterScreen({super.key});

  @override
  State<KonsultasiDokterScreen> createState() => _KonsultasiDokterScreenState();
}

class _KonsultasiDokterScreenState extends State<KonsultasiDokterScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 700);

  bool _isFirstLoadRunning = true;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  int _page = 1;
  List<PuskesmasModel> _puskesmasList = [];
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
    _scrollController.addListener(_loadMore);
    _searchController.addListener(() {
      if (_searchController.text != _searchQuery) {
        _debouncer.run(() {
          setState(() {
            _searchQuery = _searchController.text;
            _puskesmasList = [];
            _page = 1;
            _hasNextPage = true;
          });
          _loadFirstPage();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMore);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isFirstLoadRunning = true;
      _errorMessage = null;
    });

    try {
      final res = _searchQuery.isEmpty
          ? await _apiService.fetchPuskesmasPaginated(page: 1)
          : await _apiService.searchPuskesmasPaginated(
              page: 1,
              query: _searchQuery,
            );
      setState(() {
        _page = 1;
        _puskesmasList = res['data'];
        _hasNextPage = res['last_page'] > _page;
      });
    } catch (err) {
      String friendlyMessage = 'Terjadi kesalahan.';
      if (err is DioException &&
          (err.type == DioExceptionType.connectionError ||
              err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.receiveTimeout ||
              err.type == DioExceptionType.sendTimeout)) {
        friendlyMessage = 'Gagal terhubung. Periksa koneksi internet Anda.';
      }
      setState(() {
        _errorMessage = friendlyMessage;
      });
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _loadMore() async {
    if (_hasNextPage &&
        !_isFirstLoadRunning &&
        !_isLoadMoreRunning &&
        _scrollController.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      _page += 1;
      try {
        final res = _searchQuery.isEmpty
            ? await _apiService.fetchPuskesmasPaginated(page: _page)
            : await _apiService.searchPuskesmasPaginated(
                page: _page,
                query: _searchQuery,
              );
        final List<PuskesmasModel> fetchedPuskesmas = res['data'];
        if (fetchedPuskesmas.isNotEmpty) {
          setState(() {
            _puskesmasList.addAll(fetchedPuskesmas);
            _hasNextPage = res['last_page'] > _page;
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        print("Gagal memuat halaman berikutnya: $err");
      }
      setState(() {
        _isLoadMoreRunning = false;
      });
    }
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
              'Konsultasi Dokter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Terhubung dengan dokter puskesmas',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isFirstLoadRunning) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(theme);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: _loadFirstPage,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari puskesmas',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Puskesmas Tersedia',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_puskesmasList.length} lokasi',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- PERUBAHAN TAMPILAN SAAT HASIL KOSONG ---
            if (_puskesmasList.isEmpty)
              SliverFillRemaining(child: _buildEmptySearchResultWidget(theme))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.separated(
                  itemCount: _puskesmasList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _PuskesmasCard(puskesmas: _puskesmasList[index]);
                  },
                ),
              ),

            if (_isLoadMoreRunning)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 80, color: theme.hintColor),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFirstPage,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BARU UNTUK HASIL PENCARIAN KOSONG ---
  Widget _buildEmptySearchResultWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: theme.hintColor),
            const SizedBox(height: 24),
            Text(
              'Puskesmas tidak ditemukan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Maaf, kami tidak dapat menemukan puskesmas dengan kata kunci "${_searchController.text}". Silakan coba kata kunci lain.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PuskesmasCard extends StatelessWidget {
  // ... (Kode _PuskesmasCard tidak berubah)
  final PuskesmasModel puskesmas;
  const _PuskesmasCard({required this.puskesmas});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              puskesmas.nama,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              puskesmas.alamat,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              theme,
              Icons.access_time_outlined,
              'Buka: ${puskesmas.jam}',
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              theme,
              Icons.person_outline,
              (puskesmas.dokterTersedia != null &&
                      puskesmas.dokterTersedia! > 0)
                  ? '${puskesmas.dokterTersedia} Dokter tersedia'
                  : 'Dokter tidak tersedia',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailPuskesmasScreen(puskesmas: puskesmas),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cari Dokter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.hintColor),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
