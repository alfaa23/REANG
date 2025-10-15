import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reang_app/models/admin_model.dart';
import 'package:reang_app/models/user_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import Firebase Auth sudah tidak diperlukan di sini

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService();

  Object? _currentUser;
  String? _token;
  String? _role;

  bool get isLoggedIn => _token != null;
  String? get role => _role;
  UserModel? get user =>
      (_currentUser is UserModel) ? _currentUser as UserModel : null;
  AdminModel? get admin =>
      (_currentUser is AdminModel) ? _currentUser as AdminModel : null;
  String? get token => _token;

  // Fungsi login sekarang hanya mengurus Laravel
  Future<void> login(Object userObject, String laravelToken) async {
    _currentUser = userObject;
    _token = laravelToken;

    if (userObject is UserModel) {
      _role = userObject.role;
      await _storage.write(
        key: 'user_data',
        value: json.encode(userObject.toMap()),
      );
    } else if (userObject is AdminModel) {
      _role = userObject.role;
      await _storage.write(
        key: 'user_data',
        value: json.encode(userObject.toMap()),
      );
    }

    await _storage.write(key: 'user_token', value: laravelToken);
    await _storage.write(key: 'user_role', value: _role);

    // Bagian login ke Firebase dihapus dari sini
    notifyListeners();
  }

  // tryAutoLogin sekarang hanya mengurus Laravel
  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'user_token');
    final storedRole = await _storage.read(key: 'user_role');
    final userDataString = await _storage.read(key: 'user_data');

    if (storedToken == null || storedRole == null || userDataString == null) {
      await logout();
      return;
    }

    final bool tokenIsValid = await _apiService.isTokenValid(storedToken);

    if (tokenIsValid) {
      final userDataMap = json.decode(userDataString);
      if (storedRole == 'dokter') {
        _currentUser = AdminModel.fromMap(userDataMap);
      } else {
        _currentUser = UserModel.fromMap(userDataMap);
      }
      _role = storedRole;
      _token = storedToken;
      // Bagian auto-login ke Firebase dihapus dari sini
    } else {
      await logout();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      // 1. Coba logout dari Firebase terlebih dahulu
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
        debugPrint("Berhasil logout dari Firebase.");
      }
    } catch (e) {
      // Jika logout Firebase error, cukup catat errornya tapi jangan hentikan proses
      debugPrint("Error saat logout dari Firebase: $e");
    } finally {
      // 2. BLOK INI AKAN SELALU DIJALANKAN, baik logout Firebase berhasil maupun gagal
      // Hapus state dan data lokal Laravel
      _currentUser = null;
      _token = null;
      _role = null;
      await _storage.deleteAll();
      notifyListeners();
      debugPrint("Sesi lokal (Laravel) berhasil dihapus.");
    }
  }
}
