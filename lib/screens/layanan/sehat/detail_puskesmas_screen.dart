import 'package:flutter/material.dart';

// Dummy class untuk placeholder, ganti dengan model dokter Anda nanti
class Dokter {
  final String nama;
  final String spesialis;
  final int pasienHariIni;
  Dokter({
    required this.nama,
    required this.spesialis,
    required this.pasienHariIni,
  });
}

class DetailPuskesmasScreen extends StatefulWidget {
  final Map<String, dynamic> puskesmasData;
  const DetailPuskesmasScreen({super.key, required this.puskesmasData});

  @override
  State<DetailPuskesmasScreen> createState() => _DetailPuskesmasScreenState();
}

class _DetailPuskesmasScreenState extends State<DetailPuskesmasScreen> {
  // Data dummy untuk daftar dokter
  final List<Map<String, dynamic>> _doctorList = const [
    {
      'nama': 'dr. Sarah Wijaya',
      'spesialis': 'Dokter Umum',
      'pasienHariIni': 12,
    },
    {'nama': 'dr. Abdul', 'spesialis': 'Dokter Umum', 'pasienHariIni': 8},
    {
      'nama': 'dr. Budi Santoso',
      'spesialis': 'Dokter Gigi',
      'pasienHariIni': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // PERBAIKAN: Menghapus warna header agar mengikuti tema default
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.puskesmasData['nama'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Konsultasi Dokter',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Dokter',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_doctorList.length} dokter tersedia',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdownFilter(theme),
              ],
            ),
          ),
          // Daftar Dokter
          ..._doctorList.map((doctor) => _DokterCard(data: doctor)).toList(),

          // Informasi Puskesmas
          _buildInfoPuskesmas(theme),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'Semua Spesialis',
          isExpanded: true,
          icon: const Icon(Icons.unfold_more),
          items: ['Semua Spesialis', 'Dokter Umum', 'Dokter Gigi'].map((
            String value,
          ) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildInfoPuskesmas(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Puskesmas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                theme,
                Icons.access_time_outlined,
                'Jam Operasional',
                [
                  'Senin - Jumat: 08:00 - 16:00',
                  'Sabtu: 08:00 - 12:00',
                  'Minggu: Tutup',
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(theme, Icons.location_on_outlined, 'Alamat', [
                widget.puskesmasData['alamat'],
              ]),
              const SizedBox(height: 12),
              _buildInfoRow(theme, Icons.phone_outlined, 'Kontak', [
                'Telepon: (0234) 123-4567',
                'WhatsApp: +62 812-3456-7890',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String title,
    List<String> lines,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.hintColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              ...lines.map(
                (line) => Text(
                  line,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget untuk kartu Dokter
class _DokterCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DokterCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Foto Dokter (placeholder)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, size: 40, color: theme.hintColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['nama'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data['spesialis'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 14,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pasien hari ini: ${data['pasienHariIni']}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Lihat Detail'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Konsultasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
