import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart'; // <-- TAMBAHAN: Import yang diperlukan
import 'package:reang_app/screens/main_screen.dart'; // <-- TAMBAHAN: Import yang diperlukan

class KonsultasiPasienScreen extends StatelessWidget {
  const KonsultasiPasienScreen({super.key});

  // Data dummy untuk tampilan
  final List<Map<String, dynamic>> _chats = const [
    {
      'nama': 'Ahmad Rizki',
      'pesanTerakhir':
          'Dok, saya masih merasa pusing dan mual sejak kemarin...',
      'waktu': '10:30',
      'jumlahBelumDibaca': 2,
    },
    {
      'nama': 'Siti Nurhaliza',
      'pesanTerakhir': 'Terima kasih dok atas penjelasannya',
      'waktu': '08:45',
      'jumlahBelumDibaca': 0,
    },
    {
      'nama': 'Budi Santoso',
      'pesanTerakhir': 'Dok, obatnya sudah habis. Apakah perlu kontrol lagi?',
      'waktu': 'Kemarin',
      'jumlahBelumDibaca': 1,
    },
    {
      'nama': 'Maya Sari',
      'pesanTerakhir': 'Baik dok, saya akan coba dulu sarannya',
      'waktu': 'Kemarin',
      'jumlahBelumDibaca': 0,
    },
    {
      'nama': 'Andi Wijaya',
      'pesanTerakhir': 'Dok, saya merasa sesak napas sejak tadi malam',
      'waktu': '2 hari lalu',
      'jumlahBelumDibaca': 3,
    },
  ];

  String getInitials(String name) {
    List<String> names = name.split(' ');
    String initials = '';
    int numWords = names.length > 1 ? 2 : 1;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }

  // --- TAMBAHAN: Fungsi untuk menampilkan dialog konfirmasi ---
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
          content: const Text('Anda akan keluar dari akun dokter ini.'),
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
                Navigator.of(ctx).pop(); // Tutup dialog

                await authProvider.logout(); // Panggil fungsi logout

                Fluttertoast.showToast(msg: "Anda telah keluar.");

                if (!context.mounted) return;
                // Arahkan kembali ke alur utama, yang akan dimulai dari SplashScreen
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Konsultasi Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            // --- PERUBAHAN: Memanggil dialog konfirmasi ---
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _chats.length,
        separatorBuilder: (context, index) =>
            const Divider(indent: 80, height: 1),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          final hasUnread = chat['jumlahBelumDibaca'] > 0;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            leading: CircleAvatar(
              radius: 28,
              child: Text(
                getInitials(chat['nama']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              chat['nama'],
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              chat['pesanTerakhir'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                color: hasUnread
                    ? Theme.of(context).colorScheme.onSurface
                    : null,
              ),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chat['waktu'],
                  style: TextStyle(
                    fontSize: 12,
                    color: hasUnread
                        ? Colors.green
                        : Theme.of(context).hintColor,
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat['jumlahBelumDibaca'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 24, height: 24),
              ],
            ),
            onTap: () {
              // TODO: Navigasi ke halaman chat detail untuk pasien ini
            },
          );
        },
      ),
    );
  }
}
