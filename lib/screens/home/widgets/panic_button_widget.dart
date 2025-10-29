import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:reang_app/models/panic_kontak_model.dart';
import 'package:reang_app/screens/home/panic_detail_screen.dart';
import 'package:reang_app/screens/home/panic_list_screen.dart';
import 'package:reang_app/services/api_service.dart';

// Kelas helper untuk tombol menu (disederhanakan)
class PanicMenuData {
  final String label;
  final String kategori; // Kunci untuk filtering
  final IconData icon;

  PanicMenuData({
    required this.label,
    required this.kategori,
    required this.icon,
  });
}

class PanicButtonWidget extends StatefulWidget {
  const PanicButtonWidget({super.key});

  @override
  State<PanicButtonWidget> createState() => _PanicButtonWidgetState();
}

class _PanicButtonWidgetState extends State<PanicButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isOpen = false;
  bool _isLoading = true;

  // --- DATA KONTROL ---
  final ApiService _apiService = ApiService();
  List<PanicKontakModel> _allContacts = []; // Menyimpan semua data dari API
  List<PanicMenuData> _menuItems =
      []; // Menyimpan daftar tombol yang akan dibuat

  // --- Posisi Y dihitung otomatis ---
  final double _yOffsetStart = -65.0; // Posisi tombol terdekat (paling bawah)
  final double _yOffsetSpacing = -55.0; // Jarak antar tombol

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _fetchEmergencyNumbers();
  }

  Future<void> _fetchEmergencyNumbers() async {
    try {
      _allContacts = await _apiService.fetchPanicContacts();

      final Map<String, PanicMenuData> categories = {};

      // Ambil kategori unik dari API
      for (var contact in _allContacts) {
        if (!categories.containsKey(contact.kategori)) {
          categories[contact.kategori] = PanicMenuData(
            label: contact.kategori,
            kategori: contact.kategori,
            icon: contact.icon,
          );
        }
      }

      // --- PERBAIKAN: URUTKAN TOMBOL SECARA MANUAL ---

      // 1. Tentukan urutan yang Anda inginkan (dari PALING BAWAH ke PALING ATAS)
      //    Sesuaikan string ini agar sama persis dengan 'kategori' dari API
      const desiredOrder = ['PMI', 'BPBD', 'Ambulans', 'Polisi', 'Pemadam'];

      // 2. Ambil list dari map (ini yang urutannya masih acak)
      List<PanicMenuData> menuItemsUnsorted = categories.values.toList();

      // 3. Urutkan list tersebut berdasarkan 'desiredOrder'
      menuItemsUnsorted.sort((a, b) {
        int indexA = desiredOrder.indexOf(a.kategori);
        int indexB = desiredOrder.indexOf(b.kategori);

        // Jika kategori tidak ditemukan di desiredOrder, letakkan di akhir
        if (indexA == -1) indexA = 999;
        if (indexB == -1) indexB = 999;

        // Bandingkan posisinya
        return indexA.compareTo(indexB);
      });

      // 4. Simpan list yang SUDAH TERURUT ke state
      _menuItems = menuItemsUnsorted;
    } catch (e) {
      if (mounted) {
        showToast(
          'Gagal memuat kontak darurat: ${e.toString()}',
          context: context,
          backgroundColor: Colors.red,
          position: StyledToastPosition.bottom,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  // --- FUNGSI PINTAR UNTUK NAVIGASI ---
  void _onServiceTapped(String kategori) {
    // 1. Filter daftar kontak berdasarkan kategori yang diklik
    final filteredContacts = _allContacts
        .where((contact) => contact.kategori == kategori)
        .toList();

    // 2. Tentukan tujuan navigasi
    if (filteredContacts.isEmpty) {
      showToast('Nomor untuk $kategori tidak tersedia', context: context);
      return;
    }

    if (filteredContacts.length == 1) {
      // --- KASUS 1: HANYA SATU NOMOR (Polisi, Ambulans, dll.) ---
      final contact = filteredContacts.first;
      final service = PanicService(
        name: contact.name,
        phoneNumber: contact.nomer,
        info:
            'Fitur ini akan menghubungkan Anda ke ${contact.name}. Gunakan dengan bijak.',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PanicHoldScreen(service: service),
        ),
      );
    } else {
      // --- KASUS 2: LEBIH DARI SATU NOMOR (Pemadam) ---
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PanicListScreen(contacts: filteredContacts, title: kategori),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Hitung tinggi yang dibutuhkan secara dinamis
    final double requiredHeight = 65.0 + (_menuItems.length * 60.0);

    return SizedBox(
      width: 250,
      height: requiredHeight > 250 ? requiredHeight : 250,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // --- Tombol Opsi yang Dibuat Otomatis ---
          // Loop melalui list _menuItems yang sudah terurut
          ..._menuItems.asMap().entries.map((entry) {
            int index = entry.key; // 0, 1, 2, 3, 4
            PanicMenuData item = entry.value; // PMI, BPBD, Ambulans, ...
            return _buildOption(
              // Hitung Y-Offset secara dinamis
              // index 0 (PMI) -> -65.0
              // index 4 (Pemadam) -> -285.0
              _yOffsetStart + (_yOffsetSpacing * index),
              item.label,
              item.icon,
              () => _onServiceTapped(item.kategori),
            );
          }).toList(),

          // --- Tombol Utama (Panic Button) ---
          SizedBox(
            width: 50,
            height: 50,
            child: Material(
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              elevation: 4.0,
              // Latar belakang kontras (sesuai logika Anda)
              color: isDarkMode ? Colors.white : Colors.grey[850],
              child: InkWell(
                onTap: _isLoading ? null : _toggleMenu,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: _isOpen ? Colors.red : Colors.transparent,
                    image: _isOpen
                        ? null
                        : const DecorationImage(
                            image: AssetImage('assets/icons/darurat.webp'),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(child: child, scale: animation);
                      },
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                // Teks di tombol utama (close) warnanya putih
                                // jadi loading ini juga harus putih agar terlihat
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            )
                          : _isOpen
                          ? const Icon(
                              Icons.close,
                              key: ValueKey('close_icon'),
                              color: Colors.white,
                              size: 26,
                            )
                          : Container(key: const ValueKey('empty_container')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Tampilan Tombol Opsi (Tidak Berubah, sudah benar) ---
  Widget _buildOption(
    double yOffset,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Logika warna kontras yang Anda inginkan
    final contrastBackgroundColor = isDarkMode
        ? Colors.white
        : Colors.grey[850];
    final contrastTextColor = isDarkMode ? Colors.black87 : Colors.white;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value * yOffset),
          child: Opacity(opacity: _animation.value, child: child),
        );
      },
      child: InkWell(
        onTap: () {
          _toggleMenu();
          onPressed();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: contrastBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(label, style: TextStyle(color: contrastTextColor)),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 22,
              backgroundColor: contrastBackgroundColor,
              child: Icon(icon, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
