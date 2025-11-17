// Lokasi: lib/screens/ecomerce/admin/form_produk_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reang_app/models/produk_model.dart';
import 'package:reang_app/models/produk_varian_model.dart'; // <-- Impor model varian
import 'package:reang_app/providers/auth_provider.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';

class FormProdukScreen extends StatefulWidget {
  final ProdukModel? produk; // Jika null = Mode Tambah, Jika diisi = Mode Edit

  const FormProdukScreen({super.key, this.produk});

  @override
  State<FormProdukScreen> createState() => _FormProdukScreenState();
}

class _FormProdukScreenState extends State<FormProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _spesifikasiController;

  // State
  String? _selectedFitur;
  XFile? _pickedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  bool _isEditMode = false;

  List<ProdukVarianModel> _varians = [];
  final List<GlobalKey<FormState>> _varianFormKeys = [];

  final List<String> _kategoriList = [
    'Fashion',
    'Kuliner',
    'Elektronik',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.produk != null;

    _namaController = TextEditingController(text: widget.produk?.nama ?? '');
    _deskripsiController = TextEditingController(
      text: widget.produk?.deskripsi ?? '',
    );
    _spesifikasiController = TextEditingController(
      text: widget.produk?.spesifikasi ?? '',
    );
    _selectedFitur = widget.produk?.fitur;
    _existingImageUrl = widget.produk?.foto;

    if (_isEditMode && widget.produk!.varians.isNotEmpty) {
      _varians = List.from(widget.produk!.varians);
    } else {
      _varians = [
        ProdukVarianModel(idProduk: 0, namaVarian: '', harga: 0, stok: 0),
      ];
    }

    _varians.forEach((_) => _varianFormKeys.add(GlobalKey<FormState>()));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _spesifikasiController.dispose();
    super.dispose();
  }

  // --- Fungsi Toast (Sesuai Preferensi Anda) ---
  void _showToast(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    showToast(
      message,
      context: context,
      position: StyledToastPosition.bottom,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      animDuration: const Duration(milliseconds: 150),
      duration: const Duration(seconds: 2),
      borderRadius: BorderRadius.circular(25),
      textStyle: const TextStyle(color: Colors.white),
      curve: Curves.fastOutSlowIn,
      backgroundColor: isError
          ? theme.colorScheme.error
          : Colors.black.withOpacity(0.8),
    );
  }

  // --- Fungsi Ambil Gambar ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImage = image;
          _existingImageUrl = null;
        });
      }
    } catch (e) {
      _showToast("Gagal mengambil gambar: $e", isError: true);
    }
  }

  // [BARU] Fungsi untuk menambah Varian baru
  void _addVarian() {
    setState(() {
      _varians.add(
        ProdukVarianModel(
          idProduk: widget.produk?.id ?? 0,
          namaVarian: '',
          harga: 0,
          stok: 0,
        ),
      );
      _varianFormKeys.add(GlobalKey<FormState>());
    });
  }

  // [BARU] Fungsi untuk menghapus Varian
  void _removeVarian(int index) {
    if (_varians.length > 1) {
      setState(() {
        _varians.removeAt(index);
        _varianFormKeys.removeAt(index);
      });
    } else {
      _showToast("Minimal harus ada 1 varian produk.", isError: true);
    }
  }

  // [BARU] Helper untuk format Rupiah
  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // --- Fungsi Simpan (Tambah/Edit) ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showToast("Harap isi semua field wajib (*)", isError: true);
      return;
    }

    bool allVariansValid = true;
    for (var key in _varianFormKeys) {
      if (!key.currentState!.validate()) {
        allVariansValid = false;
      }
    }
    if (!allVariansValid) {
      _showToast(
        "Harap isi semua data varian (nama, harga, stok)",
        isError: true,
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    // [PERBAIKAN ERROR DI SINI]
    // Cek apakah user sudah login DAN punya idToko
    if (auth.token == null ||
        auth.user?.idToko == null ||
        auth.user?.idToko == 0) {
      _showToast(
        "Error: Sesi tidak valid atau Anda belum terdaftar sebagai toko.",
        isError: true,
      );
      return;
    }
    // [SELESAI PERBAIKAN]

    setState(() => _isLoading = true);

    try {
      ProdukModel dataProduk = ProdukModel(
        id: widget.produk?.id ?? 0,
        idToko: auth.user!.idToko!, // <-- Sekarang ini aman karena sudah dicek
        nama: _namaController.text,
        deskripsi: _deskripsiController.text,
        spesifikasi: _spesifikasiController.text,
        fitur: _selectedFitur,
        foto: _existingImageUrl,
        varians: _varians,
      );

      if (_isEditMode) {
        // --- PROSES UPDATE ---
        await _apiService.updateProduk(
          token: auth.token!,
          produkId: widget.produk!.id,
          dataProduk: dataProduk,
          varians: _varians,
          fotoBaru: _pickedImage,
          hapusFoto: (_existingImageUrl == null && _pickedImage == null),
        );
        _showToast("Produk berhasil diperbarui!");
      } else {
        // --- PROSES CREATE ---
        await _apiService.createProduk(
          token: auth.token!,
          dataProduk: dataProduk,
          varians: _varians,
          foto: _pickedImage,
        );
        _showToast("Produk berhasil ditambahkan!");
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showToast(e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Produk' : 'Tambah Produk Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(theme),
              const SizedBox(height: 24),

              Text("Nama Produk*", style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  hintText: 'Misal: Kaos Polos Premium',
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Nama produk tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),

              Text("Kategori", style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFitur,
                hint: const Text('Pilih Kategori'),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _kategoriList.map((String kategori) {
                  return DropdownMenuItem<String>(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _selectedFitur = newValue);
                },
              ),
              const SizedBox(height: 16),

              Text("Deskripsi", style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  hintText: 'Jelaskan produk Anda...',
                ),
                maxLines: 5,
                minLines: 3,
              ),
              const SizedBox(height: 16),

              Text(
                "Spesifikasi (Opsional)",
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _spesifikasiController,
                decoration: const InputDecoration(
                  hintText: 'Pisahkan dengan koma, misal: Bahan Katun, Adem',
                ),
              ),
              const SizedBox(height: 24),

              Text(
                "Varian Produk",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Tambahkan varian seperti ukuran atau warna. Jika produk Anda tidak memiliki varian, isi 1 saja.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _varians.length,
                itemBuilder: (context, index) {
                  return _buildVarianCard(theme, index);
                },
              ),

              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Tambah Varian Lain'),
                onPressed: _addVarian,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(_isEditMode ? 'Update Produk' : 'Simpan Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVarianCard(ThemeData theme, int index) {
    final varian = _varians[index];

    final namaController = TextEditingController(text: varian.namaVarian);
    final hargaController = TextEditingController(
      text: varian.harga > 0 ? varian.harga.toString() : '',
    );
    final stokController = TextEditingController(
      text: varian.stok > 0 ? varian.stok.toString() : '',
    );

    namaController.addListener(() {
      _varians[index] = ProdukVarianModel(
        id: varian.id,
        idProduk: varian.idProduk,
        namaVarian: namaController.text,
        harga: varian.harga,
        stok: varian.stok,
      );
    });
    hargaController.addListener(() {
      _varians[index] = ProdukVarianModel(
        id: varian.id,
        idProduk: varian.idProduk,
        namaVarian: varian.namaVarian,
        harga: int.tryParse(hargaController.text) ?? 0,
        stok: varian.stok,
      );
    });
    stokController.addListener(() {
      _varians[index] = ProdukVarianModel(
        id: varian.id,
        idProduk: varian.idProduk,
        namaVarian: varian.namaVarian,
        harga: varian.harga,
        stok: int.tryParse(stokController.text) ?? 0,
      );
    });

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _varianFormKeys[index],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Varian ${index + 1}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_varians.length > 1)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () => _removeVarian(index),
                    ),
                ],
              ),
              const Divider(),

              Text("Nama Varian*", style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  hintText: 'Misal: Merah, Ukuran L',
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Harga (Rp)*", style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: hargaController,
                          decoration: const InputDecoration(
                            hintText: 'Misal: 50000',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) =>
                              (value == null ||
                                  value.isEmpty ||
                                  int.tryParse(value) == 0)
                              ? 'Harga > 0'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Stok*", style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: stokController,
                          decoration: const InputDecoration(
                            hintText: 'Misal: 10',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Wajib diisi'
                              : null,
                        ),
                      ],
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

  Widget _buildImagePicker(ThemeData theme) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: _pickedImage != null
                ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                : (_existingImageUrl != null
                      ? Image.network(
                          _existingImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Icon(
                            Icons.broken_image,
                            color: theme.hintColor,
                            size: 40,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: theme.hintColor,
                            size: 50,
                          ),
                        )),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Material(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.edit,
                    color: theme.colorScheme.onPrimary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          if (_existingImageUrl != null || _pickedImage != null)
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _pickedImage = null;
                      _existingImageUrl = null;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.onError,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
