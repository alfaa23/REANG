import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
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
      _role = userObject.role; // Ini akan menjadi 'puskesmas'
      await _storage.write(
        key: 'user_data',
        value: json.encode(userObject.toMap()),
      );
    }

    await _storage.write(key: 'user_token', value: laravelToken);
    await _storage.write(key: 'user_role', value: _role);

    // --- PERBAIKAN: Login Firebase HANYA untuk ADMIN (Puskesmas) ---
    if (userObject is AdminModel) {
      try {
        final firebaseToken = await _apiService.getFirebaseToken(laravelToken);
        await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
        debugPrint(
          "Login proaktif ke Firebase untuk Admin Puskesmas berhasil!",
        );
      } catch (e) {
        debugPrint("Gagal login proaktif ke Firebase: $e");
        await logout();
        throw Exception("Gagal otentikasi dengan Firebase.");
      }
    }
    notifyListeners();
  }

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
      // --- PERBAIKAN: Cek untuk role 'puskesmas' ---
      if (storedRole == 'puskesmas') {
        _currentUser = AdminModel.fromMap(userDataMap);
      } else {
        _currentUser = UserModel.fromMap(userDataMap);
      }
      _role = storedRole;
      _token = storedToken;

      // --- PERBAIKAN: Auto-login Firebase HANYA untuk ADMIN (Puskesmas) ---
      if (storedRole == 'puskesmas' &&
          FirebaseAuth.instance.currentUser == null) {
        debugPrint("Sesi Firebase tidak ada, mencoba login ulang...");
        try {
          final firebaseToken = await _apiService.getFirebaseToken(storedToken);
          await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
          debugPrint("Auto-login proaktif ke Firebase berhasil!");
        } catch (e) {
          debugPrint("Gagal auto-login proaktif ke Firebase: $e");
          await logout();
        }
      }
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
      await _storage.deleteAll();
      notifyListeners();
      debugPrint("Sesi lokal (Laravel) berhasil dihapus.");
    }
  }
}
