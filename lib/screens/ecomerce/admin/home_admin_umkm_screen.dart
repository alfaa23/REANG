import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/providers/theme_provider.dart';
import 'package:reang_app/screens/main_screen.dart'; // Untuk navigasi saat logout

class HomeAdminUmkmScreen extends StatefulWidget {
  const HomeAdminUmkmScreen({super.key});

  @override
  State<HomeAdminUmkmScreen> createState() => _HomeAdminUmkmScreenState();
}

class _HomeAdminUmkmScreenState extends State<HomeAdminUmkmScreen> {
  // Fungsi untuk dialog logout
  void _showLogoutConfirmationDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Keluar Akun'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun admin?',
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );
  }

  // --- FUNGSI BARU UNTUK MENCEGAT TOMBOL KEMBALI ---
  Future<bool> _onWillPop() async {
    final theme = Theme.of(context);
    // Tampilkan dialog konfirmasi kustom
    bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.exit_to_app, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Keluar Aplikasi?'),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(false), // 'false' = JANGAN KELUAR
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.of(ctx).pop(true), // 'true' = YA, KELUAR
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
    // Jika user menekan "Keluar", `shouldExit` akan true, dan aplikasi akan ditutup.
    // Jika user menekan "Batal" atau di luar dialog, `shouldExit` akan false/null.
    return shouldExit ?? false;
  }
  // --- AKHIR FUNGSI BARU ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final admin = Provider.of<AuthProvider>(context, listen: false).admin;

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

    // --- BUNGKUS SCAFFOLD DENGAN WillPopScope ---
    return WillPopScope(
      onWillPop: _onWillPop, // Panggil fungsi pencegat
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin UMKM',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // Hapus tombol kembali otomatis
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Keluar',
              onPressed: () => _showLogoutConfirmationDialog(context),
            ),
          ],
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
      ),
    );
  }

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
