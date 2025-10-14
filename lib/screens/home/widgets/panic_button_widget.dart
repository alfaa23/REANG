import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:reang_app/screens/home/panic_hold_screen.dart'; // <-- PENAMBAHAN: Import layar baru
// import 'package:reang_app/services/api_service.dart'; // Aktifkan jika sudah siap
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  String? _PMI;
  String? _nomorAmbulans;
  // --- PENAMBAHAN: Variabel untuk nomor baru ---
  String? _nomorPolisi;
  String? _nomorPemadam;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    // Menggunakan kurva easeOut untuk animasi yang lebih halus saat muncul
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _fetchEmergencyNumbers();
  }

  Future<void> _fetchEmergencyNumbers() async {
    try {
      // Ganti bagian ini dengan panggilan ApiService Anda
      // final data = await ApiService().fetchEmergencyContacts();
      // _nomorDarurat = data['darurat'];
      // _nomorAmbulans = data['ambulans'];
      await Future.delayed(const Duration(seconds: 2));
      _PMI = "085133468780";
      _nomorAmbulans = "119";
      // --- PENAMBAHAN: Mengisi nomor untuk layanan baru ---
      _nomorPolisi = "110";
      _nomorPemadam = "113";
    } catch (e) {
      // Handle error jika gagal mengambil data
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

  // --- PERUBAHAN: Fungsi panggilan langsung ini tidak lagi diperlukan di sini ---
  // Fungsi ini sekarang ditangani oleh PanicHoldScreen
  // Future<void> _makePhoneCall(String? phoneNumber) async { ... }

  // --- PENAMBAHAN: Fungsi baru untuk menavigasi ke layar konfirmasi ---
  void _navigateToHoldScreen(PanicService service) {
    if (service.phoneNumber.isEmpty) {
      showToast('Nomor tidak tersedia', context: context);

      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PanicHoldScreen(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // --- PENAMBAHAN: Tombol Pemadam Kebakaran ---
          _buildOption(
            -230.0, // Posisi paling atas
            'Pemadam',
            Icons.local_fire_department_outlined,
            () => _navigateToHoldScreen(
              PanicService(
                name: 'Panggilan Pemadam Kebakaran',
                phoneNumber: _nomorPemadam ?? '113',
                info:
                    'Fitur ini akan menghubungkan Anda ke layanan Pemadam Kebakaran. Pastikan Anda gunakan dalam kondisi darurat saja.',
              ),
            ),
          ),
          // --- PENAMBAHAN: Tombol Polisi ---
          _buildOption(
            -175.0, // Posisi kedua
            'Polisi',
            Icons.local_police_outlined,
            () => _navigateToHoldScreen(
              PanicService(
                name: 'Panggilan Polisi',
                phoneNumber: _nomorPolisi ?? '110',
                info:
                    'Fitur ini akan menghubungkan Anda ke layanan Polisi. Gunakan dengan bijak.',
              ),
            ),
          ),
          _buildOption(
            -120.0, // Jarak disesuaikan untuk tombol yang lebih kecil
            'Ambulans',
            FontAwesomeIcons.ambulance,
            // --- PERUBAHAN: Panggil fungsi navigasi ---
            () => _navigateToHoldScreen(
              PanicService(
                name: 'Panggilan Ambulans',
                phoneNumber: _nomorAmbulans ?? '119',
                info:
                    'Fitur ini akan menghubungkan Anda ke layanan darurat Ambulans. Pastikan Anda gunakan dalam kondisi darurat saja.',
              ),
            ),
          ),
          _buildOption(
            -65.0, // Jarak disesuaikan untuk tombol yang lebih kecil
            'PMI',
            Icons.local_hospital_outlined,
            // --- PERUBAHAN: Panggil fungsi navigasi ---
            () => _navigateToHoldScreen(
              PanicService(
                name: 'Panggilan Darurat',
                phoneNumber: _PMI ?? '085133468780',
                info:
                    'Fitur ini akan menghubungkan Anda ke layanan darurat terpusat. Gunakan dengan bijak.',
              ),
            ),
          ),
          SizedBox(
            width: 50, // PERUBAHAN: Ukuran tombol diubah menjadi 50
            height: 50, // PERUBAHAN: Ukuran tombol diubah menjadi 50
            child: Material(
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              elevation: 4.0,
              child: InkWell(
                onTap: _isLoading ? null : _toggleMenu,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  // --- PERUBAHAN: Dekorasi dibuat dinamis ---
                  decoration: BoxDecoration(
                    color: _isOpen ? Colors.red : Colors.transparent,
                    image: _isOpen
                        ? null // Hilangkan gambar saat menu terbuka
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
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
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

  Widget _buildOption(
    double yOffset,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(label),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).cardColor,
              child: Icon(icon, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
