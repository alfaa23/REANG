import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FormLaporanScreen extends StatefulWidget {
  const FormLaporanScreen({Key? key}) : super(key: key);

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen> {
  final _jenisController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();

  final List<String> _kategoriList = [
    'Kebersihan',
    'Keamanan',
    'Infrastruktur',
    'Layanan Publik',
    'Lalu Lintas',
    'Lainnya',
  ];
  String? _selectedKategori;

  File? _pickedImage;
  // PERBAIKAN: Tambahkan variabel untuk mencegah panggilan ganda
  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    // Jika proses memilih gambar sudah berjalan, hentikan fungsi
    if (_isPickingImage) return;

    try {
      // Tandai bahwa proses dimulai
      setState(() {
        _isPickingImage = true;
      });

      final picker = ImagePicker();
      final XFile? img = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (img != null) {
        setState(() {
          _pickedImage = File(img.path);
        });
      }
    } finally {
      // Pastikan untuk selalu menandai bahwa proses telah selesai
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _jenisController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // PERBAIKAN: Dekorasi untuk box luar dengan shadow
    final boxDecoration = BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );

    // PERBAIKAN: Dekorasi untuk input field di dalam box (dibuat transparan)
    final inputDecoration = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.transparent,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      // PERUBAHAN: Menambahkan hintStyle agar lebih samar
      hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.5)),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Form Laporan Aduan'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Silakan isi form berikut untuk mengirimkan aduan',
            style: TextStyle(fontSize: 14, color: theme.hintColor),
          ),
          const SizedBox(height: 24),

          // Judul Laporan
          Text('Judul Laporan', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: boxDecoration,
            child: TextField(
              controller: _jenisController,
              decoration: inputDecoration.copyWith(
                hintText: 'Contoh: Jalan Rusak, Sampah Menumpuk',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Kategori
          Text('Kategori', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: boxDecoration,
            child: DropdownMenu<String>(
              initialSelection: _selectedKategori,
              onSelected: (String? value) {
                setState(() {
                  _selectedKategori = value;
                });
              },
              expandedInsets: EdgeInsets.zero,
              hintText: 'Pilih kategori',
              inputDecorationTheme: InputDecorationTheme(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                // PERUBAHAN: Menambahkan hintStyle agar lebih samar
                hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.5)),
              ),
              dropdownMenuEntries: _kategoriList.map<DropdownMenuEntry<String>>(
                (String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                },
              ).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Lokasi Kejadian
          Text('Lokasi Kejadian', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: boxDecoration,
            child: TextField(
              controller: _lokasiController,
              maxLines: 3,
              decoration: inputDecoration.copyWith(
                hintText: 'Masukkan alamat atau lokasi kejadian',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upload Foto
          Text('Upload Foto', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: boxDecoration, // Menggunakan box decoration yang sama
              child: Center(
                child: _pickedImage == null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 32,
                            color: theme.hintColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Klik untuk upload Gambar\nPNG, JPG hingga 10MB',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _pickedImage!,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Deskripsi Laporan
          Text('Deskripsi Laporan', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: boxDecoration,
            child: TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: inputDecoration.copyWith(
                hintText: 'Masukan deskripsi laporan dan berikan detail lokasi',
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Kirim Laporan
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // TODO: handle submit
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kirim Laporan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
