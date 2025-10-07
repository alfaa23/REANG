import 'package:flutter/material.dart';
import 'package:reang_app/models/dokter_model.dart';
import 'package:reang_app/screens/layanan/sehat/chat_screen.dart';

class DetailDokterScreen extends StatelessWidget {
  final DokterModel dokter;
  const DetailDokterScreen({super.key, required this.dokter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // HEADER: FOTO + BACK
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // --- PERUBAHAN DI SINI: Menampilkan foto dari URL ---
                  Image.network(
                    dokter.fotoUrl ?? '',
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

                  // Tombol back
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

              // Kartu info dokter
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
                          dokter.nama,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dokter.fitur,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // --- PERUBAHAN DI SINI: Menambahkan info Masa Kerja ---
                        _buildInfoChip(
                          theme,
                          Icons.work_outline,
                          dokter.masaKerja,
                        ),
                        const SizedBox(height: 24),
                        _buildDetailRow(
                          theme,
                          Icons.school_outlined,
                          'Alumnus',
                          dokter.pendidikan,
                        ),
                        _buildDetailRow(
                          theme,
                          Icons.local_hospital_outlined,
                          'Praktik di',
                          dokter.puskesmas.nama,
                        ),
                        _buildDetailRow(
                          theme,
                          Icons.phone_outlined,
                          'Nomor Telepon',
                          dokter.nomer,
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
      // Tombol Chat
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
        child: ElevatedButton(
          onPressed: () {
            final doctorMap = {
              'nama': dokter.nama,
              'spesialis': dokter.fitur,
              'foto_url': dokter.fotoUrl,
            };
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(doctorData: doctorMap),
              ),
            );
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

  // ... (sisa kode helper tidak berubah, tapi _buildInfoChip ditambahkan kembali)

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

  // --- WIDGET INI DITAMBAHKAN KEMBALI ---
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
