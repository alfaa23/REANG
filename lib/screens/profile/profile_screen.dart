import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/providers/theme_provider.dart';
import 'package:reang_app/screens/main_screen.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:reang_app/screens/auth/login_screen.dart';

// --- IMPORT BARU UNTUK NOTIFIKASI ---
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:app_settings/app_settings.dart';
// ----------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationEnabled = false;

  @override
  void initState() {
    super.initState();
    // Cek status izin saat ini saat halaman dibuka
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    // Hanya cek jika user sudah login
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) return;

    final status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        _notificationEnabled = status.isGranted;
      });
    }
  }

  // --- LOGIKA BARU SAAT TOGGLE DI-KLIK ---
  Future<void> _handleNotificationToggle(bool value) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      showToast(
        "Harap login terlebih dahulu untuk mengaktifkan notifikasi.",
        context: context,
        backgroundColor: Colors.orange,
        position: StyledToastPosition.bottom,
        animation: StyledToastAnimation.scale, // efek "pop"
        reverseAnimation: StyledToastAnimation.fade, // pas hilang fade out
        animDuration: const Duration(milliseconds: 150), // animasi cepat
        duration: const Duration(seconds: 2), // tampil 2 detik
        borderRadius: BorderRadius.circular(25),
        textStyle: const TextStyle(color: Colors.white),
        curve: Curves.fastOutSlowIn,
      );
      return; // Jangan lakukan apa-apa jika belum login
    }

    if (value == true) {
      // --- LOGIKA UNTUK MENGAKTIFKAN NOTIFIKASI ---
      final status = await Permission.notification.request();

      if (status.isGranted) {
        // Izin diberikan, daftarkan token
        await _registerFcmToken(authProvider.token!);
        if (mounted) {
          setState(() => _notificationEnabled = true);
          showToast(
            "Notifikasi berhasil diaktifkan.",
            context: context,
            backgroundColor: Colors.green,
            position: StyledToastPosition.bottom,
            animation: StyledToastAnimation.scale, // efek "pop"
            reverseAnimation: StyledToastAnimation.fade, // pas hilang fade out
            animDuration: const Duration(milliseconds: 150), // animasi cepat
            duration: const Duration(seconds: 2), // tampil 2 detik
            borderRadius: BorderRadius.circular(25),
            textStyle: const TextStyle(color: Colors.white),
            curve: Curves.fastOutSlowIn,
          );
        }
      } else if (status.isPermanentlyDenied) {
        // Izin diblokir permanen, minta user buka pengaturan HP
        _showOpenSettingsDialog();
      } else {
        // Izin ditolak (Don't Allow)
        if (mounted) {
          showToast(
            "Anda menolak izin notifikasi.",
            context: context,
            backgroundColor: Colors.red,
            position: StyledToastPosition.bottom,
            animation: StyledToastAnimation.scale, // efek "pop"
            reverseAnimation: StyledToastAnimation.fade, // pas hilang fade out
            animDuration: const Duration(milliseconds: 150), // animasi cepat
            duration: const Duration(seconds: 2), // tampil 2 detik
            borderRadius: BorderRadius.circular(25),
            textStyle: const TextStyle(color: Colors.white),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    } else {
      // --- LOGIKA UNTUK MEMATIKAN NOTIFIKASI ---
      // (Memerlukan API baru di Laravel untuk menghapus token)
      // Untuk saat ini, kita hanya menonaktifkan toggle dan memberi tahu user
      if (mounted) {
        setState(() => _notificationEnabled = false);
        showToast(
          "Notifikasi dinonaktifkan dari aplikasi.",
          context: context,
          backgroundColor: Colors.grey,
          position: StyledToastPosition.bottom,
          animation: StyledToastAnimation.scale, // efek "pop"
          reverseAnimation: StyledToastAnimation.fade, // pas hilang fade out
          animDuration: const Duration(milliseconds: 150), // animasi cepat
          duration: const Duration(seconds: 2), // tampil 2 detik
          borderRadius: BorderRadius.circular(25),
          textStyle: const TextStyle(color: Colors.white),
          curve: Curves.fastOutSlowIn,
        );
        // Buka pengaturan agar user bisa mematikan secara manual
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      }
    }
  }

  // Fungsi untuk mengirim token ke Laravel (dipindah dari AuthProvider)
  Future<void> _registerFcmToken(String laravelToken) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;
      await ApiService().sendFcmToken(fcmToken, laravelToken);
      debugPrint("FCM Token berhasil dikirim ke Laravel.");
    } catch (e) {
      debugPrint("Gagal mengirim FCM Token ke Laravel: $e");
    }
  }

  // Dialog untuk membuka pengaturan HP
  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Dibutuhkan'),
        content: const Text(
          'Anda telah memblokir notifikasi. Harap aktifkan izin notifikasi di Pengaturan HP Anda untuk melanjutkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppSettings.openAppSettings(
                type: AppSettingsType.notification,
              ); // Buka pengaturan notif HP
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

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

                if (!context.mounted) return;
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

    final Widget actionButton;

    if (authProvider.isLoggedIn) {
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
      actionButton = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.login),
        label: const Text('Masuk'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(popOnSuccess: true),
            ),
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
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
                        position: StyledToastPosition.bottom,
                        animation: StyledToastAnimation.scale, // efek "pop"
                        reverseAnimation:
                            StyledToastAnimation.fade, // pas hilang fade out
                        animDuration: const Duration(
                          milliseconds: 150,
                        ), // animasi cepat
                        duration: const Duration(seconds: 2), // tampil 2 detik
                        borderRadius: BorderRadius.circular(25),
                        textStyle: const TextStyle(color: Colors.white),
                        curve: Curves.fastOutSlowIn,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

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
              SwitchListTile(
                title: Text('Mode Gelap', style: theme.textTheme.bodyLarge),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  final provider = Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  );
                  provider.toggleTheme(value);
                },
                secondary: Icon(
                  Icons.dark_mode_outlined,
                  color: theme.colorScheme.primary,
                ),
                activeColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
              Divider(color: theme.dividerColor, height: 1),
              // --- TOMBOL NOTIFIKASI BARU ---
              SwitchListTile(
                title: Text(
                  'Notifikasi Chat',
                  style: theme.textTheme.bodyLarge,
                ),
                value: _notificationEnabled,
                onChanged: _handleNotificationToggle,
                secondary: Icon(
                  _notificationEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off_outlined,
                  color: theme.colorScheme.primary,
                ),
                activeColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

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

        SizedBox(width: double.infinity, child: actionButton),
        const SizedBox(height: 25),
      ],
    );
  }
}

// Widget helper tidak berubah
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
