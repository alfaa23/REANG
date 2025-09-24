import 'package:flutter/material.dart';
import 'dart:async';
import 'package:reang_app/models/dumas_model.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:reang_app/screens/layanan/dumas/form_laporan_screen.dart';
import 'package:reang_app/screens/layanan/dumas/detail_laporan_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:reang_app/screens/auth/login_screen.dart'; // Import LoginScreen

class DumasYuHomeScreen extends StatefulWidget {
  final bool bukaLaporanSaya;

  const DumasYuHomeScreen({Key? key, this.bukaLaporanSaya = false})
    : super(key: key);

  @override
  DumasYuHomeScreenState createState() => DumasYuHomeScreenState();
}

class DumasYuHomeScreenState extends State<DumasYuHomeScreen> {
  late bool isBerandaSelected;
  // --- PERBAIKAN: Menambahkan kembali flag untuk lazy load ---
  bool _isLaporanSayaInitiated = false;

  @override
  void initState() {
    super.initState();
    isBerandaSelected = !widget.bukaLaporanSaya;
    // Jika halaman dibuka langsung ke 'Laporan Saya', inisialisasi langsung
    if (widget.bukaLaporanSaya) {
      _isLaporanSayaInitiated = true;
    }
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dumas-yu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Layanan Pengaduan Masyarakat',
              style: TextStyle(color: theme.hintColor, fontSize: 13),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // --- PERBAIKAN: Padding diubah agar posisi tombol lebih seimbang ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isBerandaSelected = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isBerandaSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '🏠 Beranda',
                          style: TextStyle(
                            color: isBerandaSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    // --- PERBAIKAN: Menambahkan logika untuk mengaktifkan lazy load ---
                    onTap: () {
                      setState(() {
                        isBerandaSelected = false;
                        if (!_isLaporanSayaInitiated) {
                          _isLaporanSayaInitiated = true;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isBerandaSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '🗒️ Laporan Saya',
                          style: TextStyle(
                            color: !isBerandaSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return IndexedStack(
                  index: isBerandaSelected ? 0 : 1,
                  children: [
                    const _BerandaDumasView(),
                    // --- PERBAIKAN: Menggunakan kondisi untuk lazy load ---
                    if (_isLaporanSayaInitiated)
                      _LaporanSayaView(key: ValueKey(auth.isLoggedIn))
                    else
                      Container(), // Tampilkan container kosong sebelum diinisialisasi
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================
// Tampilan Beranda (Laporan Terbaru dari API)
// ===============================================
class _BerandaDumasView extends StatefulWidget {
  const _BerandaDumasView();

  @override
  State<_BerandaDumasView> createState() => _BerandaDumasViewState();
}

class _BerandaDumasViewState extends State<_BerandaDumasView> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<DumasModel> _dumasList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  // --- PERBAIKAN: Menambahkan state untuk error ---
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _dumasList = [];
      _currentPage = 1;
      _hasMore = true;
      _hasError = false; // Reset status error
    });
    try {
      final response = await _apiService.fetchDumasPaginated(
        page: _currentPage,
        token: null,
      );
      if (mounted) {
        setState(() {
          _dumasList = response.data;
          _hasMore = response.hasMorePages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true; // Set status error jika gagal
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    try {
      final response = await _apiService.fetchDumasPaginated(
        page: _currentPage,
        token: null,
      );
      if (mounted) {
        setState(() {
          _dumasList.addAll(response.data);
          _hasMore = response.hasMorePages;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- PERBAIKAN: Tampilkan error view jika ada error dan list kosong ---
    if (_hasError && _dumasList.isEmpty) {
      return _ErrorView(onRetry: _loadInitialData);
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(child: _buildBerandaHeader(theme)),
                if (_dumasList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(
                      theme,
                      'Belum ada laporan terbaru dari masyarakat.',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == _dumasList.length) {
                        return _isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                      final dumas = _dumasList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _ReportCard(data: dumas),
                      );
                    }, childCount: _dumasList.length + (_hasMore ? 1 : 0)),
                  ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.feed_outlined, size: 80, color: theme.hintColor),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Laporan',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(color: theme.hintColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBerandaHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang di Dumas-Yu',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Platform pengaduan masyarakat untuk meningkatkan kualitas pelayanan publik dan infrastruktur kota',
                  style: TextStyle(fontSize: 14, color: theme.hintColor),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF08519),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      if (authProvider.isLoggedIn) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FormLaporanScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadInitialData();
                        }
                      } else {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LoginScreen(popOnSuccess: true),
                          ),
                        );
                        if (result == true && mounted) {
                          _loadInitialData();
                        }
                      }
                    },
                    child: const Text(
                      '+ Buat Laporan Baru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Laporan Terbaru',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _LaporanSayaView extends StatefulWidget {
  const _LaporanSayaView({super.key});

  @override
  State<_LaporanSayaView> createState() => _LaporanSayaViewState();
}

class _LaporanSayaViewState extends State<_LaporanSayaView> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<DumasModel> _myDumasList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  // --- PERBAIKAN: Menambahkan state untuk error ---
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _myDumasList = [];
      _currentPage = 1;
      _hasMore = true;
      _hasError = false; // Reset status error
    });

    try {
      final response = await _apiService.fetchDumasPaginated(
        page: _currentPage,
        token: authProvider.token!,
        userId: authProvider.user!.id,
      );
      if (mounted) {
        setState(() {
          _myDumasList = response.data;
          _hasMore = response.hasMorePages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true; // Set status error jika gagal
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_isLoadingMore || !_hasMore || !authProvider.isLoggedIn) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final response = await _apiService.fetchDumasPaginated(
        page: _currentPage,
        token: authProvider.token!,
        userId: authProvider.user!.id,
      );
      if (mounted) {
        setState(() {
          _myDumasList.addAll(response.data);
          _hasMore = response.hasMorePages;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      return _buildLoginPrompt(theme);
    }

    // --- PERBAIKAN: Tampilkan error view jika ada error dan list kosong ---
    if (_hasError && _myDumasList.isEmpty) {
      return _ErrorView(onRetry: _loadInitialData);
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myDumasList.isEmpty
          ? _buildEmptyState(theme, 'Anda belum memiliki laporan.', true)
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _myDumasList.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _myDumasList.length) {
                  return _isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }
                final dumas = _myDumasList[index];
                return _ReportCard(
                  data: dumas,
                  isMyReport: true, // Beri tanda ini laporan milik user
                );
              },
            ),
    );
  }

  Widget _buildLoginPrompt(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login_outlined, size: 80, color: theme.hintColor),
            const SizedBox(height: 16),
            Text('Login Dibutuhkan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Silakan login terlebih dahulu untuk melihat daftar laporan yang telah Anda buat.',
              style: TextStyle(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(popOnSuccess: true),
                  ),
                );
                if (result == true) {
                  _loadInitialData();
                }
              },
              child: const Text('Login Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message, bool showButton) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_off_outlined,
                      size: 80,
                      color: theme.hintColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Laporan',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(color: theme.hintColor),
                      textAlign: TextAlign.center,
                    ),
                    if (showButton) ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          if (authProvider.isLoggedIn) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FormLaporanScreen(),
                              ),
                            );
                            if (result == true) {
                              _loadInitialData();
                            }
                          } else {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreen(popOnSuccess: true),
                              ),
                            );
                            if (result == true) {
                              _loadInitialData();
                            }
                          }
                        },
                        child: const Text('Buat Laporan'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- PERBAIKAN: Widget baru yang bisa digunakan ulang untuk menampilkan error ---
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 80, color: theme.hintColor),
            const SizedBox(height: 16),
            Text('Gagal Memuat Data', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Terjadi kesalahan. Periksa koneksi internet Anda dan coba lagi.',
              style: TextStyle(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final DumasModel data;
  final bool isMyReport;

  const _ReportCard({required this.data, this.isMyReport = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailLaporanScreen(dumasId: data.id, isMyReport: isMyReport),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              child:
                  (data.buktiLaporan != null && data.buktiLaporan!.isNotEmpty)
                  ? Image.network(
                      data.buktiLaporan!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: theme.hintColor,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.newspaper_outlined,
                        size: 48,
                        color: theme.hintColor,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.kategoriLaporan.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: data.statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: data.statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.jenisLaporan,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${data.lokasiLaporan} • ${timeago.format(data.createdAt, locale: 'id')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
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
