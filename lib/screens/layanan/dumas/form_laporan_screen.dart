import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/screens/layanan/dumas/dumas_yu_screen.dart';
import 'package:reang_app/services/api_service.dart';

class FormLaporanScreen extends StatefulWidget {
  // --- PENAMBAHAN: Parameter untuk menerima gambar dari alur kamera ---
  final File? initialImage;

  const FormLaporanScreen({Key? key, this.initialImage}) : super(key: key);

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _jenisController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();

  List<String> _kategoriList = [];
  bool _isKategoriLoading = true;
  String? _selectedKategori;

  File? _pickedImage;
  bool _isPickingImage = false;
  bool _isStatementChecked = false;
  bool _isSubmitting = false;

  // --- TAMBAHAN: FocusNodes untuk tiap TextField agar bisa di-unfocus dengan akurat ---
  final FocusNode _jenisFocus = FocusNode();
  final FocusNode _lokasiFocus = FocusNode();
  final FocusNode _deskripsiFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // --- PENAMBAHAN: Set gambar awal jika ada ---
    if (widget.initialImage != null) {
      _pickedImage = widget.initialImage;
    }
    // Memuat daftar kategori saat halaman dibuka
    _fetchKategori();
  }

  // --- FUNGSI BARU: Mengambil kategori di latar belakang ---
  Future<void> _fetchKategori() async {
    try {
      final kategori = await _apiService.fetchDumasKategori();
      if (mounted) {
        setState(() {
          _kategoriList = kategori;
          _isKategoriLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isKategoriLoading = false; // Hentikan loading meskipun error
        });
        showToast(
          "Gagal memuat daftar kategori.",
          context: context,
          position: StyledToastPosition.bottom,
          animation: StyledToastAnimation.scale,
          reverseAnimation: StyledToastAnimation.fade,
          animDuration: const Duration(milliseconds: 150),
          duration: const Duration(seconds: 2),
          borderRadius: BorderRadius.circular(25),
          textStyle: const TextStyle(color: Colors.white),
          curve: Curves.fastOutSlowIn,
        );
      }
    }
  }

  // Helper: unfocus global (tutup keyboard)
  void _unfocusGlobal() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // Helper untuk un/focus hanya jika ketukan di luar widget fokus
  void _handleTapDown(TapDownDetails details) {
    final focused = FocusManager.instance.primaryFocus;
    if (focused != null && focused.context != null) {
      try {
        final renderObject = focused.context!.findRenderObject();
        if (renderObject is RenderBox && renderObject.hasSize) {
          final box = renderObject;
          final topLeft = box.localToGlobal(Offset.zero);
          final rect = topLeft & box.size;
          if (!rect.contains(details.globalPosition)) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        } else {
          // fallback: unfocus
          FocusManager.instance.primaryFocus?.unfocus();
        }
      } catch (_) {
        // fallback safety
        FocusManager.instance.primaryFocus?.unfocus();
      }
    } else {
      // tidak ada yang fokus -> panggil unfocus (safety)
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    try {
      // Pastikan keyboard tertutup sebelum membuka picker
      _unfocusGlobal();

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
    // Pastikan keyboard tertutup saat menampilkan dialog
    _unfocusGlobal();

    if (_jenisController.text.isEmpty ||
        _selectedKategori == null ||
        _lokasiController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _pickedImage == null) {
      showToast(
        "Harap lengkapi semua kolom yang wajib diisi.",
        context: context,
        backgroundColor: Colors.red,
        position: StyledToastPosition.bottom,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        animDuration: const Duration(milliseconds: 150),
        duration: const Duration(seconds: 2),
        borderRadius: BorderRadius.circular(25),
        textStyle: const TextStyle(color: Colors.white),
        curve: Curves.fastOutSlowIn,
      );
      return;
    }

    if (!_isStatementChecked) {
      showToast(
        "Anda harus menyetujui pernyataan pertanggungjawaban.",
        context: context,
        backgroundColor: Colors.red,
        position: StyledToastPosition.bottom,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        animDuration: const Duration(milliseconds: 150),
        duration: const Duration(seconds: 2),
        borderRadius: BorderRadius.circular(25),
        textStyle: const TextStyle(color: Colors.white),
        curve: Curves.fastOutSlowIn,
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
              onPressed: () => Navigator.of(context).pop(),
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

  Future<void> _performSubmit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn || authProvider.token == null) {
      showToast(
        "Sesi Anda telah berakhir, silakan login kembali.",
        context: context,
        position: StyledToastPosition.bottom,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        animDuration: const Duration(milliseconds: 150),
        duration: const Duration(seconds: 2),
        borderRadius: BorderRadius.circular(25),
        textStyle: const TextStyle(color: Colors.white),
        curve: Curves.fastOutSlowIn,
      );
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      final Map<String, String> data = {
        'jenis_laporan': _jenisController.text,
        'nama_kategori': _selectedKategori!,
        'lokasi_laporan': _lokasiController.text,
        'deskripsi': _deskripsiController.text,
        'pernyataan': _isStatementChecked
            ? 'Saya menyatakan bahwa laporan yang saya berikan adalah benar dan dapat dipertanggungjawabkan.'
            : '',
      };

      await _apiService.postDumas(
        data: data,
        image: _pickedImage,
        token: authProvider.token!,
      );

      showToast(
        "Laporan berhasil dikirim!",
        context: context,
        backgroundColor: Colors.green,
        position: StyledToastPosition.bottom,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        animDuration: const Duration(milliseconds: 150),
        duration: const Duration(seconds: 2),
        borderRadius: BorderRadius.circular(25),
        textStyle: const TextStyle(color: Colors.white),
        curve: Curves.fastOutSlowIn,
      );

      _unfocusGlobal();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const DumasYuHomeScreen(bukaLaporanSaya: true),
        ),
        (Route<dynamic> route) => route.isFirst,
      );
    } catch (e) {
      showToast(
        "Gagal mengirim laporan: ${e.toString()}",
        context: context,
        backgroundColor: Colors.red,
        position: StyledToastPosition.bottom,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        animDuration: const Duration(milliseconds: 150),
        duration: const Duration(seconds: 2),
        borderRadius: BorderRadius.circular(25),
        textStyle: const TextStyle(color: Colors.white),
        curve: Curves.fastOutSlowIn,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _jenisController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();

    _jenisFocus.dispose();
    _lokasiFocus.dispose();
    _deskripsiFocus.dispose();

    super.dispose();
  }

  @override
  void deactivate() {
    _unfocusGlobal();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        title: const Text('Form Laporan Aduan'),
        centerTitle: false,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _handleTapDown,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Silakan isi form berikut untuk mengirimkan aduan',
                style: TextStyle(
                  fontSize: 15,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Text('Judul Laporan', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                decoration: boxDecoration,
                child: TextField(
                  focusNode: _jenisFocus,
                  controller: _jenisController,
                  autofocus: false,
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
                    _unfocusGlobal();
                    setState(() {
                      _selectedKategori = value;
                    });
                  },
                  expandedInsets: EdgeInsets.zero,
                  hintText: _isKategoriLoading
                      ? 'Memuat kategori...'
                      : 'Pilih kategori',
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
                    hintStyle: TextStyle(
                      color: theme.hintColor.withOpacity(0.5),
                    ),
                  ),
                  dropdownMenuEntries: _kategoriList
                      .map<DropdownMenuEntry<String>>(
                        (String value) => DropdownMenuEntry<String>(
                          value: value,
                          label: value,
                        ),
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
                  focusNode: _lokasiFocus,
                  controller: _lokasiController,
                  maxLines: 3,
                  autofocus: false,
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
                  focusNode: _deskripsiFocus,
                  controller: _deskripsiController,
                  maxLines: 4,
                  autofocus: false,
                  decoration: inputDecoration.copyWith(
                    hintText:
                        'Masukan deskripsi laporan dan berikan detail lokasi',
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
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
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
                  onPressed: _isSubmitting ? null : _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Kirim Laporan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
