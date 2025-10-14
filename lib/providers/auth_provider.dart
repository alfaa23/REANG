import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // <-- 1. Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reang_app/models/admin_model.dart';
import 'package:reang_app/models/user_model.dart';
import 'package:reang_app/services/api_service.dart';

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

  /// Fungsi login gabungan untuk User dan Admin
  Future<void> login(Object userObject, String laravelToken) async {
    _currentUser = userObject;
    _token = laravelToken;

    // Tentukan role dan simpan data ke storage
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

    // --- BAGIAN BARU: LOGIN KE FIREBASE ---
    try {
      final firebaseToken = await _apiService.getFirebaseToken(laravelToken);
      await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
      debugPrint("Login ke Firebase berhasil!");
    } catch (e) {
      debugPrint("Gagal login ke Firebase: $e");
      // Jika gagal login ke firebase, kita batalkan login dari laravel juga agar konsisten
      await logout();
      throw Exception("Gagal otentikasi dengan Firebase.");
    }
    // -------------------------------------

    notifyListeners();
  }

  /// Memeriksa sesi saat aplikasi dibuka
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

      // --- BAGIAN BARU: LOGIN KE FIREBASE SAAT AUTO-LOGIN ---
      try {
        final firebaseToken = await _apiService.getFirebaseToken(storedToken);
        await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
        debugPrint("Auto-login ke Firebase berhasil!");
      } catch (e) {
        debugPrint("Gagal auto-login ke Firebase: $e");
        await logout(); // Jika gagal, logout dari semua sistem
      }
      // ----------------------------------------------------
    } else {
      await logout();
    }
    notifyListeners();
  }

  /// Membersihkan sesi dari Laravel dan Firebase
  Future<void> logout() async {
    // Logout dari Firebase Auth
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
      debugPrint("Berhasil logout dari Firebase.");
    }

    // Hapus state dan data lokal
    _currentUser = null;
    _token = null;
    _role = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
