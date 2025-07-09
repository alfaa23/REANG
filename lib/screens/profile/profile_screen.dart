import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Dummy data
  final String _name = 'Abdee';
  final String _role = 'Warga';
  final String _avatarUrl =
      'https://i.pinimg.com/564x/eb/43/44/eb4344d5f4d31dadd4efa0cf12b70bf3.jpg';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // PERUBAHAN: Widget tidak lagi memiliki Scaffold atau AppBar sendiri
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Profile Header
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
                backgroundImage: NetworkImage(_avatarUrl),
              ),
              const SizedBox(height: 12),
              Text(
                _name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _role,
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
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Pengaturan Section
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
        // Lainnya Section
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
        // Logout Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
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
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

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
