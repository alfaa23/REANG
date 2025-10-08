import 'dart:convert';
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

  Future<void> setUser(UserModel user, String token) async {
    _currentUser = user;
    _token = token;
    _role = 'user';
    await _storage.write(key: 'user_token', value: token);
    await _storage.write(key: 'user_role', value: 'user');
    await _storage.write(key: 'user_data', value: json.encode(user.toMap()));
    notifyListeners();
  }

  Future<void> setAdmin(AdminModel admin, String token) async {
    _currentUser = admin;
    _token = token;
    _role = admin.role;
    await _storage.write(key: 'user_token', value: token);
    await _storage.write(key: 'user_role', value: admin.role);
    await _storage.write(key: 'user_data', value: json.encode(admin.toMap()));
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'user_token');
    final storedRole = await _storage.read(key: 'user_role');
    final userDataString = await _storage.read(key: 'user_data');

    if (storedToken == null || storedRole == null || userDataString == null) {
      // Jika data sesi tidak lengkap, pastikan semuanya bersih.
      await logout();
      return;
    }

    final bool tokenIsValid = await _apiService.isTokenValid(storedToken);

    if (tokenIsValid) {
      final userDataMap = json.decode(userDataString);
      if (storedRole == 'dokter') {
        _currentUser = AdminModel.fromMap(userDataMap);
      } else {
        // Asumsikan selain itu adalah 'user'
        _currentUser = UserModel.fromMap(userDataMap);
      }
      _role = storedRole;
      _token = storedToken;
    } else {
      // Jika token tidak valid, bersihkan sesi.
      await logout();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _role = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
