import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reang_app/models/user_model.dart';
import 'package:reang_app/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;

  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService();

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _user != null;

  /// Mencoba login otomatis saat aplikasi dibuka (DIPERBARUI).
  Future<void> tryAutoLogin() async {
    // 1. Baca token DAN data user dari penyimpanan
    final storedToken = await _storage.read(key: 'user_token');
    final userDataString = await _storage.read(key: 'user_data');

    if (storedToken == null || userDataString == null) {
      // Jika salah satunya tidak ada, tidak bisa melanjutkan.
      return;
    }

    // 2. Validasi token ke server menggunakan fungsi baru
    final bool tokenIsValid = await _apiService.isTokenValid(storedToken);

    if (tokenIsValid) {
      // 3. Jika token VALID, gunakan data user dari storage untuk login
      print("Token masih valid. Memuat sesi user dari storage...");
      final userDataMap = json.decode(userDataString) as Map<String, dynamic>;
      _user = UserModel.fromMap(userDataMap);
      _token = storedToken;
      print("Auto-login berhasil untuk user: ${_user?.name}");
    } else {
      // 4. Jika token TIDAK VALID, panggil logout untuk bersih-bersih
      print("Token kadaluwarsa. Melakukan logout...");
      await logout();
    }

    // 5. Beri tahu UI bahwa ada perubahan status
    notifyListeners();
  }

  /// Menyimpan sesi user ke penyimpanan yang aman.
  Future<void> _saveUserSession() async {
    if (_user != null && _token != null) {
      await _storage.write(key: 'user_token', value: _token!);
      await _storage.write(
        key: 'user_data',
        value: json.encode(_user!.toMap()),
      );
    }
  }

  /// Mengatur dan menyimpan data user setelah login/registrasi.
  Future<void> setUser(UserModel user, String token) async {
    _user = user;
    _token = token;
    await _saveUserSession();
    notifyListeners();
  }

  /// Membersihkan sesi user dan data dari penyimpanan.
  Future<void> logout() async {
    _user = null;
    _token = null;
    await _storage.delete(key: 'user_token');
    await _storage.delete(key: 'user_data');
    notifyListeners();
  }
}
