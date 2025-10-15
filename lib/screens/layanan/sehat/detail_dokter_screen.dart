import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider; // <-- PERBAIKAN DI SINI
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/models/dokter_model.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/screens/layanan/sehat/chat_screen.dart';
import 'package:reang_app/services/api_service.dart';

class DetailDokterScreen extends StatefulWidget {
  final DokterModel dokter;
  const DetailDokterScreen({super.key, required this.dokter});

  @override
  State<DetailDokterScreen> createState() => _DetailDokterScreenState();
}

class _DetailDokterScreenState extends State<DetailDokterScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.network(
                    widget.dokter.fotoUrl ?? '',
                    headers: const {'ngrok-skip-browser-warning': 'true'},
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 240,
                      width: double.infinity,
                      color: theme.colorScheme.surface,
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOnlineStatus(theme),
                        const SizedBox(height: 12),
                        Text(
                          widget.dokter.nama,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.dokter.fitur,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoChip(
                          theme,
                          Icons.work_outline,
                          widget.dokter.masaKerja,
                        ),
                        const SizedBox(height: 24),
                        _buildDetailRow(
                          theme,
                          Icons.school_outlined,
                          'Alumnus',
                          widget.dokter.pendidikan,
                        ),
                        _buildDetailRow(
                          theme,
                          Icons.local_hospital_outlined,
                          'Praktik di',
                          widget.dokter.puskesmas.nama,
                        ),
                        _buildDetailRow(
                          theme,
                          Icons.phone_outlined,
                          'Nomor Telepon',
                          widget.dokter.nomer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
        child: ElevatedButton(
          onPressed: authProvider.role == 'dokter'
              ? null
              : () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  if (FirebaseAuth.instance.currentUser == null) {
                    try {
                      final laravelToken = authProvider.token;
                      if (laravelToken == null) {
                        throw Exception("Token Laravel tidak ditemukan.");
                      }

                      final firebaseToken = await ApiService().getFirebaseToken(
                        laravelToken,
                      );
                      await FirebaseAuth.instance.signInWithCustomToken(
                        firebaseToken,
                      );
                    } catch (e) {
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal terhubung ke server chat.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }
                  }

                  if (mounted) {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(recipient: widget.dokter),
                      ),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('Chat'),
        ),
      ),
    );
  }

  Widget _buildOnlineStatus(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: Colors.green, size: 10),
          const SizedBox(width: 6),
          Text(
            'Online',
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.green.shade200
                  : Colors.green.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.hintColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
