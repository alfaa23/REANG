import 'package:flutter/material.dart';
// --- TAMBAHAN: Import file form yang baru ---
import 'package:reang_app/screens/layanan/renbang/form_usulan_screen.dart';

class UsulanPembangunanView extends StatefulWidget {
  const UsulanPembangunanView({super.key});

  @override
  State<UsulanPembangunanView> createState() => _UsulanPembangunanViewState();
}

class _UsulanPembangunanViewState extends State<UsulanPembangunanView> {
  static const _usulanList = [
    {
      'title': 'Pembangunan Jembatan Penghubung',
      'category': 'Infrastruktur',
      'description':
          'Usulan pembangunan jembatan untuk menghubungkan desa A dan B',
      'user': 'Budi Santoso',
      'time': '2 hari lalu',
      'likes': 45,
      'status': 'Dalam Review',
      'statusColor': Color(0xFFFFA500),
    },
    {
      'title': 'Renovasi Pasar Tradisional',
      'category': 'Ekonomi',
      'description':
          'Perbaikan fasilitas pasar untuk meningkatkan kenyamanan pedagang',
      'user': 'Siti Aminah',
      'time': '5 hari lalu',
      'likes': 32,
      'status': 'Disetujui',
      'statusColor': Color(0xFF4CAF50),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Usulan Masyarakat',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              // --- PERUBAHAN: Aksi tombol diubah ---
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormUsulanScreen(),
                  ),
                );
              },
              // ------------------------------------
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah Usulan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _usulanList.length,
            itemBuilder: (_, idx) => _UsulanCard(data: _usulanList[idx]),
          ),
        ),
      ],
    );
  }
}

class _UsulanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _UsulanCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data['title'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (data['statusColor'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['status'],
                    style: TextStyle(
                      color: data['statusColor'] as Color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                data['category'],
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['description'],
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: theme.hintColor),
                const SizedBox(width: 6),
                Text(
                  '${data['user']} • ${data['time']}',
                  style: TextStyle(fontSize: 13, color: theme.hintColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 16,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${data['likes']}',
                  style: TextStyle(fontSize: 13, color: theme.hintColor),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment_outlined, size: 16, color: theme.hintColor),
                const SizedBox(width: 4),
                Text(
                  'Komentar',
                  style: TextStyle(fontSize: 13, color: theme.hintColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
