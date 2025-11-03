import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/providers/theme_provider.dart';
// Hapus import MainScreen jika logout tidak terjadi di sini
// import 'package:reang_app/screens/main_screen.dart';

class HomeAdminUmkmScreen extends StatefulWidget {
  const HomeAdminUmkmScreen({super.key});

  @override
  State<HomeAdminUmkmScreen> createState() => _HomeAdminUmkmScreenState();
}

class _HomeAdminUmkmScreenState extends State<HomeAdminUmkmScreen> {
  // --- FUNGSI _showLogoutConfirmationDialog DIHAPUS ---
  // --- FUNGSI _onWillPop DIHAPUS ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final admin = context.watch<AuthProvider>().admin;

    final bool isDarkMode = themeProvider.isDarkMode;
    final Color cardColor = isDarkMode
        ? theme.colorScheme.surfaceVariant
        : theme.colorScheme.surface;
    final Color contrastCardColor = isDarkMode
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.primary;
    final Color contrastOnCardColor = isDarkMode
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onPrimary;

    // --- PERBAIKAN 1: WillPopScope DIHAPUS DARI SINI ---
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin UMKM',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        // --- PERBAIKAN 2: 'actions' (tombol logout) DIHAPUS ---
        actions: null,

        // --- PERBAIKAN 3: 'automaticallyImplyLeading: false' DIHAPUS ---
        // Dengan menghapus 'actions' dan 'automaticallyImplyLeading',
        // panah kembali akan OTOMATIS MUNCUL.
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Selamat datang,',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            admin?.name ?? 'Admin',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ringkasan Toko',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                theme: theme,
                color: contrastCardColor,
                onColor: contrastOnCardColor,
                title: 'Pesanan Baru',
                value: '12', // TODO: Ganti dengan data asli
                icon: Icons.shopping_cart_checkout,
              ),
              _buildStatCard(
                theme: theme,
                color: cardColor,
                onColor: theme.colorScheme.onSurface,
                title: 'Total Produk',
                value: '78', // TODO: Ganti dengan data asli
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Aksi Utama',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPrimaryActionCard(
            theme: theme,
            color: cardColor,
            onColor: theme.colorScheme.onSurface,
            title: 'Cek Pesanan',
            subtitle: 'Lihat semua pesanan yang masuk',
            icon: Icons.receipt_long_outlined,
            onTap: () {
              // TODO: Navigasi ke halaman daftar pesanan
            },
          ),
          const SizedBox(height: 12),
          _buildPrimaryActionCard(
            theme: theme,
            color: cardColor,
            onColor: theme.colorScheme.onSurface,
            title: 'Tambah Produk Baru',
            subtitle: 'Tambahkan item baru ke toko Anda',
            icon: Icons.add_shopping_cart_outlined,
            onTap: () {
              // TODO: Navigasi ke halaman form tambah produk
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Pengaturan Lainnya',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.store_outlined),
                  title: const Text('Pengaturan Toko'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigasi ke pengaturan toko
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_outlined),
                  title: const Text('Manajemen Stok'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigasi ke manajemen stok
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // (Fungsi _buildStatCard tidak berubah)
  Widget _buildStatCard({
    required ThemeData theme,
    required Color color,
    required Color onColor,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: onColor.withOpacity(0.8)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: onColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(color: onColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // (Fungsi _buildPrimaryActionCard tidak berubah)
  Widget _buildPrimaryActionCard({
    required ThemeData theme,
    required Color color,
    required Color onColor,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: onColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: onColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: onColor.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
