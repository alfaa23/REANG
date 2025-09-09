import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reang_app/screens/layanan/dumas/dumas_yu_screen.dart';

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
  bool _isPickingImage = false;

  bool _isStatementChecked = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    try {
      setState(() => _isPickingImage = true);
      final picker = ImagePicker();
      final XFile? img = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (img != null) {
        setState(() => _pickedImage = File(img.path));
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showConfirmationDialog() {
    // Validasi input sebelum menampilkan dialog
    if (_jenisController.text.isEmpty ||
        _selectedKategori == null ||
        _lokasiController.text.isEmpty ||
        _deskripsiController.text.isEmpty) {
      // --- PERUBAHAN: Mengganti SnackBar dengan Toast ---
      Fluttertoast.showToast(
        msg: "Harap lengkapi semua kolom yang wajib diisi.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (!_isStatementChecked) {
      Fluttertoast.showToast(
        msg: "Anda harus menyetujui pernyataan pertanggungjawaban.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kirim Laporan?'),
          content: const Text(
            'Pastikan data yang Anda laporkan sudah benar dan dapat dipertanggungjawabkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Kirim'),
              onPressed: () {
                Navigator.of(context).pop();
                _performSubmit();
              },
            ),
          ],
        );
      },
    );
  }

  void _performSubmit() {
    // TODO: Tambahkan logika untuk mengirim data laporan ke API di sini

    Fluttertoast.showToast(
      msg: "Laporan berhasil dikirim!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    // Kembali ke halaman Dumas-Yu dan langsung buka tab "Laporan Saya"
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const DumasYuHomeScreen(bukaLaporanSaya: true),
      ),
      (Route<dynamic> route) => route.isFirst,
    );
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

    final inputDecoration = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.transparent,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
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
                hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.5)),
              ),
              dropdownMenuEntries: _kategoriList
                  .map<DropdownMenuEntry<String>>(
                    (String value) =>
                        DropdownMenuEntry<String>(value: value, label: value),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
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
          Text('Upload Foto', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: boxDecoration,
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
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _isStatementChecked,
            onChanged: (bool? value) {
              setState(() {
                _isStatementChecked = value ?? false;
              });
            },
            title: Text(
              'Saya menyatakan bahwa laporan yang saya berikan adalah benar dan dapat dipertanggungjawabkan.',
              style: TextStyle(fontSize: 13, color: theme.hintColor),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _showConfirmationDialog,
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
          // --- PERUBAHAN: Menambahkan spasi di bagian bawah ---
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
