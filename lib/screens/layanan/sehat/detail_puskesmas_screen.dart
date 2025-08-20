import 'package:flutter/material.dart';
import 'package:reang_app/screens/layanan/sehat/detail_dokter_screen.dart';

class DetailPuskesmasScreen extends StatefulWidget {
  final Map<String, dynamic> puskesmasData;
  const DetailPuskesmasScreen({super.key, required this.puskesmasData});

  @override
  State<DetailPuskesmasScreen> createState() => _DetailPuskesmasScreenState();
}

class _DetailPuskesmasScreenState extends State<DetailPuskesmasScreen> {
  // Data dummy untuk semua dokter yang ada di puskesmas ini
  final List<Map<String, dynamic>> _allDoctors = const [
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
    {'nama': 'Amelia, S.Gz', 'spesialis': 'Ahli Gizi', 'pasienHariIni': 10},
    {'nama': 'Siti Aminah, Amd.Keb', 'spesialis': 'Bidan', 'pasienHariIni': 15},
  ];

  // Daftar kategori filter
  final List<String> _categories = [
    'Semua',
    'Dokter Umum',
    'Dokter Gigi',
    'Bidan',
    'Ahli Gizi',
    'Kesehatan Lingkungan', // Contoh spesialis lain
  ];
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Logika untuk memfilter dokter berdasarkan kategori yang dipilih
    final List<Map<String, dynamic>> filteredDoctors;
    if (_selectedCategoryIndex == 0) {
      filteredDoctors = _allDoctors; // Tampilkan semua jika 'Semua' dipilih
    } else {
      final selectedCategory = _categories[_selectedCategoryIndex];
      filteredDoctors = _allDoctors
          .where((doctor) => doctor['spesialis'] == selectedCategory)
          .toList();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                      '${_allDoctors.length} total dokter',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCategoryChips(theme),
              ],
            ),
          ),
          // PERUBAHAN: Padding ditambahkan di sini agar ada jarak antara filter dan kartu pertama
          const SizedBox(height: 8),
          if (filteredDoctors.isEmpty)
            _buildEmptyDoctorView(theme)
          else
            ...filteredDoctors.map((doctor) => _DokterCard(data: doctor)),

          const SizedBox(height: 16),
          _buildInfoPuskesmas(theme),
        ],
      ),
    );
  }

  // Widget baru untuk filter chips yang bisa di-scroll
  Widget _buildCategoryChips(ThemeData theme) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _categories[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget baru untuk tampilan alternatif jika dokter tidak ditemukan
  Widget _buildEmptyDoctorView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.person_off_outlined, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text('Dokter tidak ditemukan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Saat ini tidak ada dokter dengan spesialisasi "${_categories[_selectedCategoryIndex]}" yang tersedia.',
              style: TextStyle(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
          ],
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
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailDokterScreen(data: data),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
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
                        // PERBAIKAN: Mengganti Chip dengan Container agar lebih kecil
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            data['spesialis'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Colors.green.shade200
                                  : Colors.green.shade800,
                              fontWeight: FontWeight.w600,
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
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Konsultasi ›',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
