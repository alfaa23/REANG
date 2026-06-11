import 'package:flutter/material.dart';
// Silakan sesuaikan lokasi import di bawah ini dengan struktur foldermu
import 'provider_profile_admin_mitra_screen.dart';
import 'kelola_tiket_dan_pesanan.dart';
import 'analitik_admin_mitra.dart';
import 'provider_settings_screen.dart'; // Menambahkan import file pengaturan baru

class HomeAdminPlesirScreen extends StatelessWidget {
  const HomeAdminPlesirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Pengelola Wisata'),
          backgroundColor: const Color(
            0xFF005691,
          ), // Mengubah menjadi Biru menyesuaikan profil & kelola
          foregroundColor: Colors.white,
          bottom: const TabBar(
            // Diubah menjadi true agar teks panjang seperti 'Kelola Tiket & Pesanan'
            // memiliki ruang yang cukup dan tidak terpotong/saling menumpuk
            isScrollable: true,
            tabAlignment:
                TabAlignment.start, // Memulai susunan tab dari kiri agar rapi
            labelColor: Color.fromARGB(
              255,
              15,
              15,
              15,
            ), // Warna teks aktif menjadi putih agar kontras dengan latar biru
            unselectedLabelColor: Colors.white70, // Warna teks tidak aktif
            indicatorColor: Colors.white, // Garis bawah indikator menjadi putih
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            tabs: [
              Tab(text: 'Profil'),
              Tab(text: 'Kelola Tiket & Pesanan'),
              Tab(text: 'Analitik'), // Mengganti 'Events' menjadi 'Analitik'
              Tab(text: 'Setting'), // Mengganti 'Analytics' menjadi 'Setting'
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // MENAMPILKAN PROFIL ADMIN: Memanggil class dari file terpisah
            ProviderProfileScreen(),

            // MENAMPILKAN HALAMAN KELOLA: Memanggil class dari file terpisah tanpa mengubah kodenya
            ManageEventScreen(),

            // MENAMPILKAN HALAMAN ANALITIK: Memanggil class dari file terpisah
            ProviderAnalyticsScreen(),

            // MENAMPILKAN HALAMAN PENGATURAN: Memanggil class dari file provider_settings_screen.dart
            ProviderSettingsScreen(),
          ],
        ),
      ),
    );
  }
}
