import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/providers/theme_provider.dart';
import 'package:reang_app/screens/main_screen.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

// --- TAMBAHAN: Import halaman LoginScreen untuk navigasi ---
import 'package:reang_app/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              const Text('Yakin ingin keluar?'),
            ],
          ),
          content: const Text(
            'Anda akan keluar dari akun ini dan kembali ke halaman utama.',
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tidak, tetap di sini'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await authProvider.logout();
                showToast(
                  "Anda telah keluar.",
                  context: context,
                  position: StyledToastPosition.bottom,
                  animation: StyledToastAnimation.scale,
                  reverseAnimation: StyledToastAnimation.fade,
                  animDuration: const Duration(milliseconds: 150),
                  duration: const Duration(seconds: 2),
                  borderRadius: BorderRadius.circular(25),
                  textStyle: const TextStyle(color: Colors.white),
                  curve: Curves.fastOutSlowIn,
                );

                // Cek mounted sebelum navigasi
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Ya, keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final String name = authProvider.user?.name ?? 'Pengunjung';
    final String role = authProvider.isLoggedIn && authProvider.user != null
        ? 'Warga'
        : 'Guest';
    const String avatarUrl =
        'https://i.pinimg.com/564x/eb/43/44/eb4344d5f4d31dadd4efa0cf12b70bf3.jpg';

    // --- PERUBAHAN UTAMA: Membuat tombol dinamis berdasarkan status login ---
    final Widget actionButton;

    if (authProvider.isLoggedIn) {
      // Tombol Keluar Akun (Merah) jika sudah login
      actionButton = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.exit_to_app),
        label: const Text('Keluar Akun'),
        onPressed: () => _showLogoutConfirmationDialog(context),
      );
    } else {
      // Tombol Masuk (Biru) jika belum login
      actionButton = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade800, // Warna biru
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.login), // Ikon login
        label: const Text('Masuk'), // Teks diubah
        onPressed: () {
          // Arahkan ke halaman login
          Navigator.push(
            context,
            MaterialPageRoute(
              // popOnSuccess true agar setelah login kembali ke halaman profil
              builder: (context) => const LoginScreen(popOnSuccess: true),
            ),
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Profile Header (tidak berubah)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(avatarUrl),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              Divider(height: 32, color: theme.dividerColor, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Ubah Profil',
                    onTap: () {
                      showToast(
                        "Fitur ini akan segera tersedia.",
                        context: context,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Pengaturan Section (tidak berubah)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengaturan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.dark_mode_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Mode Gelap', style: theme.textTheme.bodyLarge),
                  ),
                  Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      final provider = Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      );
                      provider.toggleTheme(value);
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Lainnya Section (tidak berubah)
        Container(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _ListTileItem(
                icon: Icons.policy_outlined,
                label: 'Kebijakan dan Ketentuan',
                onTap: () {},
              ),
              Divider(color: theme.dividerColor, height: 1, indent: 56),
              _ListTileItem(
                icon: Icons.help_outline,
                label: 'Pusat Bantuan',
                onTap: () {},
              ),
              Divider(color: theme.dividerColor, height: 1, indent: 56),
              _ListTileItem(
                icon: Icons.info_outline,
                label: 'Versi Aplikasi',
                trailing: Text('1.0.0', style: theme.textTheme.bodyMedium),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // --- PERUBAHAN: Menggunakan tombol dinamis yang sudah dibuat ---
        SizedBox(width: double.infinity, child: actionButton),
        const SizedBox(height: 25),
      ],
    );
  }
}

// Widget helper tidak berubah
// ...
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ListTileItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: theme.iconTheme.color?.withOpacity(0.7),
          ),
      onTap: onTap,
    );
  }
}
