import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

// Model sederhana untuk data tempat ibadah
class TempatIbadah {
  final String nama;
  final String alamat;
  final LatLng lokasi;
  final IconData icon;
  final Color warna;

  TempatIbadah({
    required this.nama,
    required this.alamat,
    required this.lokasi,
    required this.icon,
    required this.warna,
  });
}

class PetaIbadahScreen extends StatefulWidget {
  const PetaIbadahScreen({super.key});

  @override
  State<PetaIbadahScreen> createState() => _PetaIbadahScreenState();
}

class _PetaIbadahScreenState extends State<PetaIbadahScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _currentAddress = "Mencari alamat...";

  // Data contoh menggunakan model yang baru
  final List<TempatIbadah> _listTempatIbadah = [
    TempatIbadah(
      nama: 'Masjid Agung Indramayu',
      alamat: 'Jl. Letjend Suprapto, Paoman',
      lokasi: LatLng(-6.3269, 108.3245),
      icon: Icons.mosque,
      warna: Colors.green,
    ),
    TempatIbadah(
      nama: 'Masjid Islamic Center',
      alamat: 'Jl. Gatot Subroto, Pekandangan',
      lokasi: LatLng(-6.3450, 108.3230),
      icon: Icons.mosque,
      warna: Colors.green,
    ),
    TempatIbadah(
      nama: 'RSUD Indramayu',
      alamat: 'Jl. Murahnara, Sindang',
      lokasi: LatLng(-6.3205, 108.3271),
      icon: Icons.local_hospital,
      warna: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // 1. Cek apakah layanan lokasi aktif, tampilkan dialog bawaan jika tidak
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool enabled = await Geolocator.openLocationSettings();
        if (!enabled) throw Exception();
      }

      // 2. Cek dan minta izin lokasi, dialog bawaan OS
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception();
        }
      }

      // 3. Dapatkan posisi saat ini
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
    } catch (_) {
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

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _currentAddress = placemarks.isNotEmpty
            ? "${placemarks.first.street}, ${placemarks.first.subLocality}, ${placemarks.first.locality}"
            : "Alamat tidak ditemukan";
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _currentAddress = "Gagal mendapatkan alamat");
    }
  }

  Future<void> _launchMapsUrl(double lat, double lng) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showDetailDialog(TempatIbadah tempat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(0),
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(tempat.icon, color: tempat.warna, size: 28),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = _listTempatIbadah.map((tempat) {
      return Marker(
        point: tempat.lokasi,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showDetailDialog(tempat),
          child: Container(
            decoration: BoxDecoration(
              color: tempat.warna,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(tempat.icon, color: Colors.white, size: 24),
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
              initialCenter: LatLng(-6.3269, 108.3245),
              initialZoom: 15.0,
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
            nonRotatedChildren: const [RichAttributionWidget(attributions: [])],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          _buildCustomAppBar(context),
          Positioned(
            bottom: 110,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black54),
            ),
          ),
          _buildCustomBottomSheet(),
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
              // Tombol Back
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
              // Kontainer alamat yang diperpanjang
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
              // Ikon menu dihapus
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF2D3748),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[300]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'titik lokasi tempat ibadah di indramayu',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
