import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/providers/theme_provider.dart';
import 'package:reang_app/services/api_service.dart'; // Import API

import 'kelola_produk_view.dart';
import 'umkm_analytics_dashboard.dart';
import 'pengaturan_toko_view.dart';
import 'kelola_pesanan_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reang_app/screens/ecomerce/admin/admin_umkm_chat_list_screen.dart'; // Pastikan path benar

class HomeAdminUmkmScreen extends StatefulWidget {
  const HomeAdminUmkmScreen({super.key});

  @override
  State<HomeAdminUmkmScreen> createState() => _HomeAdminUmkmScreenState();
}

class _HomeAdminUmkmScreenState extends State<HomeAdminUmkmScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State untuk notifikasi
  int _notificationCount = 0;
  bool _isOpeningChat = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController dengan 5 tab
    _tabController = TabController(length: 5, vsync: this);

    // Panggil fungsi hitung notifikasi saat halaman dibuka
    _fetchNotificationCount();
  }

  // Fungsi mengambil jumlah pesanan yang butuh perhatian (Konfirmasi + Dikemas/COD)
  Future<void> _fetchNotificationCount() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn && auth.user?.idToko != null) {
        try {
          final counts = await _apiService.fetchOrderCounts(
            token: auth.token!,
            idToko: auth.user!.idToko!,
          );

          if (mounted) {
            setState(() {
              // HITUNG: Menunggu Konfirmasi + Diproses (Siap Dikemas/COD)
              int waiting = counts['menunggu_konfirmasi'] ?? 0;
              int processing = counts['diproses'] ?? 0;

              _notificationCount = waiting + processing;
            });
          }
        } catch (e) {
          debugPrint("Gagal load notif home: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    final Color cardColor = isDarkMode
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Toko Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // 1. TOMBOL CHAT ADMIN (BARU)
          _buildAdminChatButton(context),

          // 2. TOMBOL REFRESH (LAMA)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotificationCount,
            tooltip: 'Segarkan Notifikasi',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          TabBar(
            controller: _tabController,
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            indicatorSize: TabBarIndicatorSize.label,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            tabs: [
              const Tab(text: 'Profil Toko'),

              // [MODIFIKASI TAB PESANAN]
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pesanan'),
                    if (_notificationCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _notificationCount.toString(),
                          style: TextStyle(
                            color: theme.colorScheme.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Tab(text: 'Analitik'),
              const Tab(text: 'Produk'),
              const Tab(text: 'Pengaturan Toko'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStoreProfileTab(theme, cardColor),
                const KelolaPesananScreen(),
                const UMKMAnalyticsDashboardContent(),
                const KelolaProdukView(),
                const PengaturanTokoView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Tombol Chat Admin ---
  Widget _buildAdminChatButton(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final theme = Theme.of(context);

    if (!auth.isLoggedIn || auth.user == null) {
      return const SizedBox.shrink(); // Sembunyikan jika belum login
    }

    final myId = auth.user!.id.toString();

    // Stream Badge Notifikasi
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: myId)
          .where('isUmkmChat', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        int unreadTotal = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            // FILTER: Hanya hitung chat dari PELANGGAN
            // Artinya: userId (Pembeli) != myId (Saya/Admin)
            final chatUserId = data['userId'].toString();
            if (chatUserId == myId) {
              continue; // Skip chat belanja saya sendiri
            }

            final unreadMap = data['unreadCount'] as Map<String, dynamic>?;
            if (unreadMap != null) {
              unreadTotal += (unreadMap[myId] as int? ?? 0);
            }
          }
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: _isOpeningChat
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme
                            .colorScheme
                            .onPrimary, // Warna putih di AppBar
                      ),
                    )
                  : const Icon(Icons.chat_bubble_outline),
              tooltip: 'Chat Pelanggan',
              onPressed: _isOpeningChat
                  ? null
                  : () async {
                      setState(() => _isOpeningChat = true);
                      try {
                        // 1. Tukar Token / Pastikan Login Firebase
                        await auth.ensureFirebaseLoggedIn();

                        // 2. Buka Halaman List Chat Admin
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminUmkmChatListScreen(),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal membuka chat: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isOpeningChat = false);
                        }
                      }
                    },
            ),
            // Badge Merah
            if (unreadTotal > 0 && !_isOpeningChat)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      unreadTotal > 99 ? '99+' : unreadTotal.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // --- Widget untuk Tab Profil Toko ---
  Widget _buildStoreProfileTab(ThemeData theme, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 16.0,
              ),
              child: Column(
                children: [
                  // Gambar Profil
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.secondaryContainer
                              .withOpacity(0.3),
                        ),
                        child: Center(
                          child: Text(
                            '120 x 120',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nama Toko
                  Text(
                    'tokofashionmodern',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tombol Aksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProfileActionButton(
                        context,
                        title: 'Edit Profil',
                        isPrimary: true,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _buildProfileActionButton(
                        context,
                        title: 'Bagikan',
                        isPrimary: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Statistik
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(
                        context,
                        '156',
                        'produk',
                        theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        context,
                        '4.8 \u2605',
                        '2340 ulasan',
                        theme.colorScheme.onSurface,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 20),

                  // Detail Toko
                  Text(
                    'Toko Fashion Modern',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Kategori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Fashion & Lifestyle Store',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Lokasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Jakarta Selatan, Indonesia',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Trusted Seller
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        'Trusted Seller sejak 2020',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Deskripsi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Menyediakan fashion trendy berkualitas tinggi dengan harga terjangkau. Pengiriman cepat ke seluruh Indonesia 🚚',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Identitas Penjualan Toko
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Identitas Penjualan Toko',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildIdentityItem(
                        Icons.store,
                        'Nama Toko',
                        'Toko Fashion Modern',
                      ),
                      const SizedBox(height: 8),
                      _buildIdentityItem(
                        Icons.person,
                        'Nama Pemilik',
                        'Rizky Pratama',
                      ),
                      const SizedBox(height: 8),
                      _buildIdentityItem(
                        Icons.phone,
                        'Nomor Telepon',
                        '+62 812 3456 7890',
                      ),
                      const SizedBox(height: 8),
                      _buildIdentityItem(
                        Icons.email,
                        'Email Toko',
                        'fashionmodern@gmail.com',
                      ),
                      const SizedBox(height: 8),
                      _buildIdentityItem(
                        Icons.badge,
                        'Nomor Izin Usaha',
                        'SIUP-0912382',
                      ),
                      const SizedBox(height: 8),
                      _buildIdentityItem(
                        Icons.location_city,
                        'Alamat Lengkap',
                        'Jl. Raya Kemang No. 45, Jakarta Selatan',
                      ),
                      const SizedBox(height: 8),
                      _buildIdentityItem(
                        Icons.date_range,
                        'Tahun Berdiri',
                        '2020',
                      ),
                      const SizedBox(height: 8),
                      _buildIdentityItem(
                        Icons.local_shipping,
                        'Layanan Pengiriman',
                        'JNE, J&T, SiCepat, AnterAja',
                      ),
                      const SizedBox(height: 8),
                      _buildIdentityItem(
                        Icons.payment,
                        'Metode Pembayaran',
                        'Transfer Bank, E-Wallet, COD',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildProfileActionButton(
    BuildContext context, {
    required String title,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: isPrimary
            ? OutlinedButton.styleFrom(
                backgroundColor: theme.colorScheme.onSurface,
                foregroundColor: theme.colorScheme.surface,
                side: BorderSide(color: theme.colorScheme.onSurface),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            : OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.onSurfaceVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
