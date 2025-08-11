import 'package:flutter/material.dart';

// Model sederhana untuk data notifikasi
class Notifikasi {
  final String pengirim;
  final String judul;
  final String waktu;
  bool dibaca;

  Notifikasi({
    required this.pengirim,
    required this.judul,
    required this.waktu,
    this.dibaca = false,
  });
}

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  // Data dummy untuk daftar notifikasi
  final List<Notifikasi> _notifikasiList = [
    Notifikasi(
      pengirim: 'BMKG - Pusat',
      judul:
          'UPDATE Peringatan Dini Cuaca Wilayah Jabodetabek tgl 10 Agustus 2025 pkl. 22:15 WIB berpotensi terja...',
      waktu: '11 jam yang lalu',
    ),
    Notifikasi(
      pengirim: 'BMKG - Pusat',
      judul:
          'UPDATE Peringatan Dini Cuaca Wilayah Jabodetabek tgl 10 Agustus 2025 pkl. 21:25 WIB berpotensi terja...',
      waktu: '12 jam yang lalu',
    ),
    Notifikasi(
      pengirim: 'BMKG - Pusat',
      judul:
          'UPDATE Peringatan Dini Cuaca Wilayah Jabodetabek tgl 10 Agustus 2025 pkl. 20:35 WIB berpotensi terja...',
      waktu: '13 jam yang lalu',
      dibaca: true, // Contoh notifikasi yang sudah dibaca
    ),
  ];

  // Fungsi untuk menandai semua notifikasi sebagai sudah dibaca
  void _tandaiSemuaDibaca() {
    setState(() {
      for (var notif in _notifikasiList) {
        notif.dibaca = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua notifikasi ditandai sudah dibaca')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Tombol titik tiga (popup menu)
          if (_notifikasiList.isNotEmpty) // Hanya tampilkan jika ada notifikasi
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'tandai_semua') {
                  _tandaiSemuaDibaca();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'tandai_semua',
                  child: Text('Tandai semua sudah dibaca'),
                ),
              ],
            ),
        ],
      ),
      // PERBAIKAN: Menampilkan alternatif jika daftar notifikasi kosong
      body: _notifikasiList.isEmpty
          ? _buildEmptyView(theme)
          : ListView.separated(
              itemCount: _notifikasiList.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _NotificationCard(notifikasi: _notifikasiList[index]);
              },
            ),
    );
  }

  // Widget untuk tampilan alternatif saat tidak ada notifikasi
  Widget _buildEmptyView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: theme.hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Anda belum memiliki notifikasi',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Semua pemberitahuan penting akan muncul di sini.',
            style: TextStyle(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Widget untuk satu kartu notifikasi
class _NotificationCard extends StatelessWidget {
  final Notifikasi notifikasi;
  const _NotificationCard({required this.notifikasi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Latar belakang berubah jika notifikasi belum dibaca
    final cardColor = notifikasi.dibaca
        ? theme.scaffoldBackgroundColor
        : theme.colorScheme.primary.withOpacity(0.08);

    return Material(
      color: cardColor,
      child: InkWell(
        onTap: () {
          // TODO: Aksi saat notifikasi diklik (misal: buka halaman detail)
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                // Ganti dengan logo pengirim jika ada
                backgroundImage: AssetImage('assets/logos/bmkg.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notifikasi.pengirim,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(notifikasi.judul, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      notifikasi.waktu,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
