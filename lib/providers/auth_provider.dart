import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reang_app/models/admin_model.dart';
import 'package:reang_app/models/puskesmas_model.dart';
import 'package:reang_app/models/user_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <-- 1. IMPORT KEMBALI

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService();

  Object? _currentUser;
  String? _token;
  String? _role;
  PuskesmasModel? _puskesmas;

  bool get isLoggedIn => _token != null;
  String? get role => _role;
  UserModel? get user =>
      (_currentUser is UserModel) ? _currentUser as UserModel : null;
  AdminModel? get admin =>
      (_currentUser is AdminModel) ? _currentUser as AdminModel : null;
  String? get token => _token;
  PuskesmasModel? get puskesmas => _puskesmas;

  // --- 2. TAMBAHKAN KEMBALI FUNGSI INI ---
  Future<void> _registerFcmToken() async {
    // --- PERBAIKAN LOGIKA: HANYA JALANKAN JIKA 'PUSKESMAS' ---
    // (User akan mendaftar via ProfileScreen)
    if (_role != 'puskesmas') return;

    try {
      // Minta izin
      await FirebaseMessaging.instance.requestPermission();
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null || _token == null) {
        debugPrint("Gagal mendapatkan FCM Token untuk Admin.");
        return;
      }

      // Kirim token ke API
      await _apiService.sendFcmToken(fcmToken, _token!);
      debugPrint("FCM Token Admin Puskesmas berhasil dikirim ke Laravel.");
    } catch (e) {
      debugPrint("Gagal mengirim FCM Token Admin: $e");
    }
  }

  Future<void> login(
    Object userObject,
    String laravelToken, {
    PuskesmasModel? puskesmas,
  }) async {
    _currentUser = userObject;
    _token = laravelToken;
    _puskesmas = null;

    if (userObject is UserModel) {
      _role = userObject.role;
      await _storage.write(
        key: 'user_data',
        value: json.encode(userObject.toMap()),
      );
    } else if (userObject is AdminModel) {
      _role = userObject.role;
      _puskesmas = puskesmas;
      await _storage.write(
        key: 'user_data',
        value: json.encode(userObject.toMap()),
      );
      if (puskesmas != null) {
        await _storage.write(
          key: 'puskesmas_data',
          value: json.encode(puskesmas.toJson()),
        );
      }
    }

    await _storage.write(key: 'user_token', value: laravelToken);
    await _storage.write(key: 'user_role', value: _role);

    if (userObject is AdminModel && userObject.role == 'puskesmas') {
      try {
        final firebaseToken = await _apiService.getFirebaseToken(laravelToken);
        await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
        debugPrint(
          "Login proaktif ke Firebase untuk Admin Puskesmas berhasil!",
        );
      } catch (e) {
        await logout();
        throw Exception("Gagal otentikasi dengan Firebase.");
      }
    }

    notifyListeners();

    // --- 3. PANGGIL FUNGSI REGISTRASI DI SINI ---
    await _registerFcmToken(); // Ini akan mendaftarkan token jika rolenya 'puskesmas'
  }

  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'user_token');
    final storedRole = await _storage.read(key: 'user_role');
    final userDataString = await _storage.read(key: 'user_data');
    final puskesmasDataString = await _storage.read(key: 'puskesmas_data');

    if (storedToken == null || storedRole == null || userDataString == null) {
      await logout();
      return;
    }

    final bool tokenIsValid = await _apiService.isTokenValid(storedToken);

    if (tokenIsValid) {
      final userDataMap = json.decode(userDataString);
      if (storedRole == 'puskesmas') {
        _currentUser = AdminModel.fromMap(userDataMap);
        if (puskesmasDataString != null) {
          _puskesmas = PuskesmasModel.fromJson(
            json.decode(puskesmasDataString),
          );
        }
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

      // --- 4. PANGGIL FUNGSI REGISTRASI DI SINI ---
      await _registerFcmToken(); // Ini akan mendaftarkan token jika rolenya 'puskesmas'
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
      _puskesmas = null;
      await _storage.deleteAll();
      notifyListeners();
      debugPrint("Sesi lokal (Laravel) berhasil dihapus.");
    }
  }
}
