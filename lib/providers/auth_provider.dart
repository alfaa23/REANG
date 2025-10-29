import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reang_app/models/admin_model.dart';
import 'package:reang_app/models/puskesmas_model.dart'; // <-- Pastikan import ini ada
import 'package:reang_app/models/user_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService();

  Object? _currentUser;
  String? _token;
  String? _role;
  PuskesmasModel? _puskesmas; // <-- Properti untuk menyimpan data Puskesmas

  bool get isLoggedIn => _token != null;
  String? get role => _role;
  UserModel? get user =>
      (_currentUser is UserModel) ? _currentUser as UserModel : null;
  AdminModel? get admin =>
      (_currentUser is AdminModel) ? _currentUser as AdminModel : null;
  String? get token => _token;
  PuskesmasModel? get puskesmas => _puskesmas; // <-- Getter untuk Puskesmas

  // --- FUNGSI LOGIN YANG BENAR ---
  // Parameter 'puskesmas' sudah ditambahkan di sini
  Future<void> login(
    Object userObject,
    String laravelToken, {
    PuskesmasModel? puskesmas,
  }) async {
    _currentUser = userObject;
    _token = laravelToken;
    _puskesmas = null; // Reset

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

      // --- PERBAIKAN DI SINI ---
      if (_role == 'puskesmas') {
        _puskesmas = puskesmas; // Simpan ke state
        if (puskesmas != null) {
          // Simpan ke storage
          await _storage.write(
            key: 'puskesmas_data',
            value: json.encode(puskesmas.toJson()),
          );
        }

        // Login Firebase HANYA untuk puskesmas
        try {
          final firebaseToken = await _apiService.getFirebaseToken(
            laravelToken,
          );
          await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
          debugPrint("Login Firebase untuk Admin Puskesmas berhasil!");
        } catch (e) {
          await logout();
          throw Exception("Gagal otentikasi dengan Firebase.");
        }
      }
      // (Role admin lain seperti 'umkm' tidak perlu data puskesmas atau login Firebase)
    }

    await _storage.write(key: 'user_token', value: laravelToken);
    await _storage.write(key: 'user_role', value: _role);

    notifyListeners();

    // Daftarkan FCM token (hanya jika 'puskesmas')
    await _registerFcmToken();
  }

  // --- FUNGSI TRYAUTOLOGIN YANG BENAR ---
  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'user_token');
    final storedRole = await _storage.read(key: 'user_role');
    final userDataString = await _storage.read(key: 'user_data');

    // --- TAMBAHKAN BARIS INI ---
    final puskesmasDataString = await _storage.read(key: 'puskesmas_data');

    if (storedToken == null || storedRole == null || userDataString == null) {
      await logout();
      return;
    }

    final bool tokenIsValid = await _apiService.isTokenValid(storedToken);

    if (tokenIsValid) {
      final userDataMap = json.decode(userDataString);

      if (storedRole != 'user') {
        // Benar, ini untuk semua admin
        _currentUser = AdminModel.fromMap(userDataMap);

        // --- PERBAIKI BLOK INI ---
        if (storedRole == 'puskesmas' && puskesmasDataString != null) {
          _puskesmas = PuskesmasModel.fromJson(
            json.decode(puskesmasDataString),
          );
        }
        // ... (logika untuk 'umkm' bisa ditambahkan di sini jika perlu)
      } else {
        _currentUser = UserModel.fromMap(userDataMap);
      }

      _role = storedRole;
      _token = storedToken;

      if (storedRole == 'puskesmas' &&
          FirebaseAuth.instance.currentUser == null) {
        try {
          final firebaseToken = await _apiService.getFirebaseToken(storedToken);
          await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
          debugPrint("Auto-login proaktif ke Firebase berhasil!");
        } catch (e) {
          debugPrint("Gagal auto-login proaktif ke Firebase: $e");
          await logout();
        }
      }

      await _registerFcmToken();
    } else {
      await logout();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
        debugPrint("Berhasil logout dari Firebase.");
      }
    } catch (e) {
      debugPrint("Error saat logout dari Firebase: $e");
    } finally {
      _currentUser = null;
      _token = null;
      _role = null;
      _puskesmas = null; // Hapus data puskesmas dari state
      await _storage.deleteAll();
      notifyListeners();
      debugPrint("Sesi lokal (Laravel) berhasil dihapus.");
    }
  }

  // --- FUNGSI FCM TOKEN (Hanya untuk Admin Puskesmas) ---
  Future<void> _registerFcmToken() async {
    if (_role != 'puskesmas') return;

    try {
      await FirebaseMessaging.instance.requestPermission();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || _token == null) return;

      await _apiService.sendFcmToken(fcmToken, _token!);
      debugPrint("FCM Token Admin Puskesmas berhasil dikirim ke Laravel.");
    } catch (e) {
      debugPrint("Gagal mengirim FCM Token Admin: $e");
    }
  }

  /// Memperbarui data pengguna secara lokal di provider dan storage
  Future<void> updateLocalUser(UserModel updatedUser) async {
    // 1. Perbarui data pengguna yang sedang aktif di state
    _currentUser = updatedUser;

    // 2. Simpan kembali data pengguna yang sudah baru ke secure storage
    await _storage.write(
      key: 'user_data',
      value: json.encode(updatedUser.toMap()),
    );

    // 3. Beri tahu semua widget yang mendengarkan bahwa data telah berubah
    notifyListeners();
  }
}
