import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class FormUsulanScreen extends StatefulWidget {
  const FormUsulanScreen({Key? key}) : super(key: key);

  @override
  State<FormUsulanScreen> createState() => _FormUsulanScreenState();
}

class _FormUsulanScreenState extends State<FormUsulanScreen> {
  final _judulController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();

  final List<String> _kategoriList = [
    'Infrastruktur',
    'Pendidikan',
    'Kesehatan',
    'Ekonomi',
    'Sosial',
    'Lainnya',
  ];
  String? _selectedKategori;

  @override
  void dispose() {
    _judulController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // --- FUNGSI BARU: Menampilkan dialog konfirmasi ---
  void _showConfirmationDialog() {
    // Validasi sederhana sebelum menampilkan dialog
    if (_judulController.text.isEmpty ||
        _selectedKategori == null ||
        _deskripsiController.text.isEmpty) {
      // --- PERUBAHAN: Menggunakan Toast untuk notifikasi error ---
      showToast(
        "Harap lengkapi semua kolom yang wajib diisi.",
        context: context, // wajib di versi baru
        alignment: Alignment.bottomCenter, // posisi bawah
        backgroundColor: Colors.red,
        textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
        duration: const Duration(seconds: 2), // pengganti LENGTH_SHORT
        animation: StyledToastAnimation.slideFromBottom,
        reverseAnimation: StyledToastAnimation.fade,
      );

      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Usulan'),
          content: const Text(
            'Pastikan data yang Anda masukkan sudah benar. Kirim usulan ini?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            ElevatedButton(
              child: const Text('Kirim'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _performSubmit(); // Lanjutkan proses pengiriman
              },
            ),
          ],
        );
      },
    );
  }

  // --- FUNGSI BARU: Logika setelah konfirmasi ---
  void _performSubmit() {
    // TODO: Tambahkan logika untuk mengirim data ke API di sini

    // Tampilkan notifikasi toast, bukan snackbar
    showToast(
      "Usulan berhasil dikirim!",
      context: context, // wajib di versi baru
      alignment: Alignment.bottomCenter, // pengganti gravity
      backgroundColor: Colors.green,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
      duration: const Duration(seconds: 2), // pengganti Toast.LENGTH_SHORT
      animation: StyledToastAnimation.slideFromBottom,
      reverseAnimation: StyledToastAnimation.fade,
    );

    // Kembali ke halaman sebelumnya
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // --- TAMBAHAN: Mendeteksi mode tema saat ini ---
    final isDarkMode = theme.brightness == Brightness.dark;

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
        title: const Text('Form Tambah Usulan'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Sampaikan ide dan usulan Anda untuk pembangunan Indramayu yang lebih baik.',
            // --- PERUBAHAN: Warna teks disesuaikan ---
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Text('Judul Usulan', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: boxDecoration,
            child: TextField(
              controller: _judulController,
              decoration: inputDecoration.copyWith(
                hintText: 'Contoh: Perbaikan Jembatan Desa Sukra',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Kategori Pembangunan', style: theme.textTheme.titleMedium),
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
              hintText: 'Pilih kategori usulan',
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
          Text('Lokasi Usulan', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: boxDecoration,
            child: TextField(
              controller: _lokasiController,
              maxLines: 2,
              decoration: inputDecoration.copyWith(
                hintText: 'Contoh: Jalan Raya Pantura, Desa Sukra',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Deskripsi Lengkap', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: boxDecoration,
            child: TextField(
              controller: _deskripsiController,
              maxLines: 5,
              decoration: inputDecoration.copyWith(
                hintText: 'Jelaskan secara rinci mengenai usulan Anda...',
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _showConfirmationDialog, // Memanggil dialog konfirmasi
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kirim Usulan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
