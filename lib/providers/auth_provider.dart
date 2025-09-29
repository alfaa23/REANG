import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reang_app/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;

  // --- PENAMBAHAN: Inisialisasi Secure Storage ---
  final _storage = const FlutterSecureStorage();

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _user != null;

  // --- FUNGSI DIPERBARUI: Menyimpan sesi login ke FlutterSecureStorage ---
  Future<void> _saveUserSession() async {
    if (_user != null && _token != null) {
      await _storage.write(key: 'user_token', value: _token!);
      // Simpan data user sebagai string JSON yang aman
      await _storage.write(
        key: 'user_data',
        value: json.encode(_user!.toMap()),
      );
    }
  }

  // --- FUNGSI DIPERBARUI: Memuat sesi login dari FlutterSecureStorage ---
  Future<void> loadUserFromStorage() async {
    final token = await _storage.read(key: 'user_token');
    final userDataString = await _storage.read(key: 'user_data');

    if (token != null && userDataString != null) {
      final userDataMap = json.decode(userDataString) as Map<String, dynamic>;
      _user = UserModel.fromMap(userDataMap);
      _token = token;
      notifyListeners();
    }
  }

  // --- Fungsi setUser sekarang otomatis menyimpan sesi dengan aman ---
  void setUser(UserModel user, String token) {
    _user = user;
    _token = token;
    _saveUserSession(); // Simpan setiap kali user login/di-set
    notifyListeners();
  }

  // --- PERBAIKAN: Fungsi logout sekarang menghapus sesi dari penyimpanan aman ---
  Future<void> logout() async {
    _user = null;
    _token = null;
    // Hapus data dari FlutterSecureStorage
    await _storage.delete(key: 'user_token');
    await _storage.delete(key: 'user_data');
    notifyListeners();
  }
}
