import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/providers/theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  final FocusNode _fullNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Inisialisasi data dari provider.
    // listen: false di initState
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fullNameController = TextEditingController(
      text: authProvider.user?.name ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fullNameFocus.dispose();
    super.dispose();
  }

  /// Menangani penutupan keyboard sebelum kembali
  void _onBackPress() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  /// Menangani penutupan keyboard sebelum menyimpan
  void _onSave() {
    FocusScope.of(context).unfocus();
    // TODO: Tambahkan logika untuk menyimpan data
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final apiService = ApiService();
    // apiService.updateProfile(
    //   token: authProvider.token,
    //   newName: _fullNameController.text,
    // );

    // Tampilkan notifikasi (contoh)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profil berhasil disimpan (simulasi)"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Ambil username dari email (contoh, karena tidak ada di UserModel)
    final String username = user?.email.split('@').first ?? 'guest';

    return GestureDetector(
      // --- GOAL 2: Menutup keyboard saat mengetuk area kosong ---
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // Set warna AppBar agar sesuai dengan tema (terang/gelap)
        appBar: AppBar(
          backgroundColor: themeProvider.isDarkMode
              ? const Color(0xFF1F1F1F)
              : theme.appBarTheme.backgroundColor,
          elevation: 0,
          // --- GOAL 2: Menangani tombol kembali ---
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBackPress,
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: false,
          actions: [
            // --- GOAL 2: Menangani tombol simpan ---
            TextButton(
              onPressed: _onSave,
              child: Text(
                'Save',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            _buildAvatarSection(theme),
            const SizedBox(height: 32),
            Text(
              'Personal Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildEditableField(
              theme: theme,
              label: 'Full Name',
              controller: _fullNameController,
              focusNode: _fullNameFocus,
            ),
            const SizedBox(height: 24),
            _buildLockedField(theme: theme, label: 'Username', value: username),
            const SizedBox(height: 24),
            _buildLockedField(
              theme: theme,
              label: 'E-mail',
              value: user?.email ?? 'Tidak ada email',
            ),
            const SizedBox(height: 24),
            _buildPhoneField(
              theme: theme,
              label: 'Phone Number',
              value: user?.phone ?? 'Belum ada nomor HP',
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk bagian Avatar
  Widget _buildAvatarSection(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.person,
            size: 60,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            // TODO: Tambahkan logika ganti foto
          },
          icon: Icon(
            Icons.edit_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          label: Text(
            'Change Photo',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Widget untuk field yang bisa diedit (Full Name)
  Widget _buildEditableField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            // Menggunakan UnderlineInputBorder seperti di gambar
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget untuk field yang tidak bisa diedit (Username, E-mail)
  Widget _buildLockedField({
    required ThemeData theme,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ),
            Icon(
              Icons.lock_outline,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget untuk field Nomor HP (dengan status verifikasi)
  Widget _buildPhoneField({
    required ThemeData theme,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            // Status "Unverified" seperti di gambar
            Text(
              'Unverified',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Ikon pensil untuk mengedit
            Icon(
              Icons.edit_outlined,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ],
    );
  }
}
