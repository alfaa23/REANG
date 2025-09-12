import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:reang_app/services/api_service.dart'; // Aktifkan jika sudah siap

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

  String? _nomorDarurat;
  String? _nomorAmbulans;

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
      _nomorDarurat = "112";
      _nomorAmbulans = "119";
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

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null) {
      Fluttertoast.showToast(msg: 'Nomor tidak tersedia');
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Tidak dapat melakukan panggilan';
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          _buildOption(
            -120.0, // Jarak disesuaikan untuk tombol yang lebih kecil
            'Ambulans',
            Icons.local_hospital_outlined,
            () => _makePhoneCall(_nomorAmbulans),
          ),
          _buildOption(
            -65.0, // Jarak disesuaikan untuk tombol yang lebih kecil
            'Panggilan Darurat',
            Icons.phone_in_talk_outlined,
            () => _makePhoneCall(_nomorDarurat),
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
