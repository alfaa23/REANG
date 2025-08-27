import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:reang_app/models/lokasi_peta_model.dart'; // Import model yang baru dibuat
import 'package:url_launcher/url_launcher.dart';

class PetaScreen extends StatefulWidget {
  // Halaman ini akan menerima daftar lokasi yang ingin ditampilkan
  final List<LokasiPeta> daftarLokasi;
  final String judulHalaman;

  const PetaScreen({
    super.key,
    required this.daftarLokasi,
    required this.judulHalaman,
  });

  @override
  State<PetaScreen> createState() => _PetaScreenState();
}

class _PetaScreenState extends State<PetaScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _currentAddress = "Mencari alamat...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled)
          throw Exception('Layanan lokasi tidak diaktifkan.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _getAddressFromLatLng(position);

      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
        _mapController.move(_currentPosition!, 15.0);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal mendapatkan lokasi. Pastikan GPS dan izin aktif.',
          ),
        ),
      );
    }
  }

  // PERBAIKAN: Logika untuk merangkai alamat dibuat lebih lengkap
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final Placemark p = placemarks.first;
        // Cek apakah p.street adalah Plus Code (berisi '+')
        final bool isPlusCode = p.street?.contains('+') ?? false;

        // Merangkai alamat dari beberapa bagian agar lebih lengkap
        final addressParts = [
          // Hanya tambahkan street jika BUKAN Plus Code
          if (!isPlusCode) p.street,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
        ];
        // Menghapus bagian yang kosong dan menggabungkannya
        final String fullAddress = addressParts
            .where((part) => part != null && part.isNotEmpty)
            .join(', ');

        setState(() {
          _currentAddress = fullAddress.isNotEmpty
              ? fullAddress
              : "Alamat tidak ditemukan";
        });
      } else {
        setState(() {
          _currentAddress = "Alamat tidak ditemukan";
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _currentAddress = "Gagal mendapatkan alamat");
    }
  }

  Future<void> _launchMapsUrl(double lat, double lng) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showDetailDialog(LokasiPeta tempat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Image.network(
                tempat.fotoUrl ?? '',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        tempat.icon ?? Icons.location_pin,
                        color: tempat.warna ?? Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tempat.nama,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tempat.alamat,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _launchMapsUrl(
                          tempat.lokasi.latitude,
                          tempat.lokasi.longitude,
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.directions_outlined),
                      label: const Text('Lihat Rute'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = widget.daftarLokasi.map((tempat) {
      return Marker(
        point: tempat.lokasi,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showDetailDialog(tempat),
          child: Container(
            decoration: BoxDecoration(
              color: tempat.warna ?? Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              tempat.icon ?? Icons.location_pin,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.daftarLokasi.isNotEmpty
                  ? widget.daftarLokasi.first.lokasi
                  : LatLng(-6.3269, 108.3245), // Default ke Indramayu
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.reang_app',
              ),
              MarkerLayer(markers: markers),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue.shade700,
                        size: 35,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          _buildCustomAppBar(context),
          Positioned(
            bottom: 20,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    _currentAddress,
                    style: const TextStyle(color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
