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

  // Nomor ini nanti akan diambil dari API
  String? _nomorDarurat;
  String? _nomorAmbulans;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fetchEmergencyNumbers();
  }

  Future<void> _fetchEmergencyNumbers() async {
    // Simulasi pengambilan data dari API
    // Ganti bagian ini dengan panggilan ApiService Anda
    try {
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
    // Menggunakan Stack untuk menumpuk tombol-tombol
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Tombol Ambulans
          _buildOption(
            -130.0,
            'Ambulans',
            Icons.local_hospital_outlined,
            () => _makePhoneCall(_nomorAmbulans),
          ),
          // Tombol Panggilan Darurat
          _buildOption(
            -70.0,
            'Panggilan Darurat',
            Icons.phone_in_talk_outlined,
            () => _makePhoneCall(_nomorDarurat),
          ),
          // Tombol utama (Panic/Close)
          FloatingActionButton(
            elevation: 4,
            backgroundColor: Colors.red,
            onPressed: _isLoading ? null : _toggleMenu,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _animation,
                    color: Colors.white,
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
        onTap: onPressed,
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
