import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reang_app/models/admin_model.dart';
import 'package:reang_app/models/puskesmas_model.dart';
import 'package:reang_app/models/user_model.dart';
import 'package:reang_app/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Kita gabungkan UserSecureService ke sini agar rapi
// (Anda bisa hapus file user_secure_service.dart jika mau)
class _AuthStorageService {
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'user_token';
  static const String _roleKey = 'user_role';
  static const String _userKey = 'user_data';
  static const String _puskesmasKey = 'puskesmas_data';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveRole(String role) =>
      _storage.write(key: _roleKey, value: role);
  Future<String?> readRole() => _storage.read(key: _roleKey);

  Future<void> savePuskesmas(PuskesmasModel puskesmas) => _storage.write(
    key: _puskesmasKey,
    value: json.encode(puskesmas.toJson()),
  );
  Future<PuskesmasModel?> readPuskesmas() async {
    final data = await _storage.read(key: _puskesmasKey);
    return data != null ? PuskesmasModel.fromJson(json.decode(data)) : null;
  }

  // --- FUNGSI INI SEKARANG MENDUKUNG 'UserModel' & 'AdminModel' ---
  Future<void> saveUser(Object userObject) {
    String? data;
    if (userObject is UserModel) {
      data = json.encode(userObject.toMap());
    } else if (userObject is AdminModel) {
      data = json.encode(userObject.toMap());
    }
    return _storage.write(key: _userKey, value: data);
  }

  // --- FUNGSI INI MEMBACA DATA BERDASARKAN ROLE ---
  Future<Object?> readUser(String role) async {
    final dataString = await _storage.read(key: _userKey);
    if (dataString == null) return null;
    final dataMap = json.decode(dataString);

    if (role == 'user' || role == 'umkm') {
      return UserModel.fromMap(dataMap);
    } else {
      // Asumsi selain itu adalah AdminModel
      return AdminModel.fromMap(dataMap);
    }
  }

  Future<void> deleteAll() => _storage.deleteAll();
}
// --- Akhir Service Internal ---

class AuthProvider with ChangeNotifier {
  final _storage = _AuthStorageService(); // Gunakan service internal
  final _apiService = ApiService();

  Object? _currentUser;
  String? _token;
  String? _role; // Role utama (user, umkm, puskesmas)
  PuskesmasModel? _puskesmas;

  // --- GETTER (Tidak berubah) ---
  bool get isLoggedIn => _token != null;
  String? get role => _role;
  UserModel? get user =>
      (_currentUser is UserModel) ? _currentUser as UserModel : null;
  AdminModel? get admin =>
      (_currentUser is AdminModel) ? _currentUser as AdminModel : null;
  String? get token => _token;
  PuskesmasModel? get puskesmas => _puskesmas;

  // --- GETTER BARU DARI USERPROVIDER ---
  bool get isUmkm {
    // Cek dari state saat ini
    if (_role == 'umkm') return true;
    // Cek mendalam jika _role masih 'user' (untuk kasus multi-role)
    if (_currentUser is UserModel) {
      return (_currentUser as UserModel).role.any((r) => r.name == 'umkm');
    }
    return false;
  }
  // ------------------------------------

  // --- FUNGSI LOGIN (Sama seperti kode Anda, tapi di-refactor) ---
  Future<void> login(
    Object userObject,
    String laravelToken, {
    PuskesmasModel? puskesmas,
  }) async {
    _currentUser = userObject;
    _token = laravelToken;
    _puskesmas = null; // Reset

    // --- LOGIKA PENENTUAN ROLE ---
    if (userObject is UserModel) {
      // Logika cerdas untuk memilih role
      _role = _getPrimaryRoleFromList(userObject.role);
    } else if (userObject is AdminModel) {
      _role = userObject.role;
    }
    // ----------------------------

    // Simpan data ke storage
    await _storage.saveUser(userObject);
    await _storage.saveToken(laravelToken);
    await _storage.saveRole(_role!);

    if (_role == 'puskesmas' && puskesmas != null) {
      _puskesmas = puskesmas;
      await _storage.savePuskesmas(puskesmas);
      await _loginToFirebase(laravelToken);
    }

    notifyListeners();
    await _registerFcmToken();
  }

  // --- FUNGSI TRYAUTOLOGIN (DIPERBARUI TOTAL) ---
  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.readToken();
    final storedRole = await _storage.readRole();

    if (storedToken == null || storedRole == null) {
      await logout();
      return;
    }

    // Cek validitas token
    final bool tokenIsValid = await _apiService.isTokenValid(storedToken);

    if (tokenIsValid) {
      // Load data user/admin berdasarkan role
      _currentUser = await _storage.readUser(storedRole);

      if (_currentUser == null) {
        // Data user tidak ada, paksa logout
        await logout();
        return;
      }

      // Load data puskesmas jika ada
      if (storedRole == 'puskesmas') {
        _puskesmas = await _storage.readPuskesmas();
      }

      _role = storedRole;
      _token = storedToken;

      // Sinkronkan login Firebase
      if (storedRole == 'puskesmas' &&
          FirebaseAuth.instance.currentUser == null) {
        await _loginToFirebase(storedToken);
      }

      await _registerFcmToken();
    } else {
      await logout();
    }

    notifyListeners();
  }
  // ------------------------------------

  // --- FUNGSI LOGOUT (Sama seperti kode Anda) ---
  Future<void> logout() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
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
    }
  }

  // --- FUNGSI BARU DARI USERPROVIDER ---
  Future<void> upgradeToUmkm() async {
    if (_currentUser is UserModel && !isUmkm) {
      final user = _currentUser as UserModel;

      // 1. Buat data role 'umkm' baru
      final newRole = RoleModel(
        id: 2, // Asumsi ID 2
        name: 'umkm',
        pivot: PivotModel(userId: user.id, roleId: 2),
      );

      // 2. Tambahkan role baru ke list di state
      user.role.add(newRole);

      // 3. Update role utama di provider
      _role = 'umkm';

      // 4. Simpan ulang semua data
      await _storage.saveUser(user);
      await _storage.saveRole(_role!);

      // 5. Beri tahu aplikasi
      notifyListeners();
      debugPrint("AuthProvider: Role user di-upgrade ke UMKM!");
    }
  }
  // ------------------------------------

  // --- FUNGSI HELPER (Internal) ---

  // Helper untuk memilih 1 role utama
  String _getPrimaryRoleFromList(List<RoleModel> roles) {
    if (roles.any((r) => r.name == 'puskesmas')) return 'puskesmas';
    if (roles.any((r) => r.name == 'umkm')) return 'umkm';
    if (roles.any((r) => r.name == 'user')) return 'user';
    return roles.isNotEmpty ? roles.first.name : 'user'; // Cadangan
  }

  // Helper login ke Firebase
  Future<void> _loginToFirebase(String laravelToken) async {
    try {
      final firebaseToken = await _apiService.getFirebaseToken(laravelToken);
      await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
      debugPrint("Login Firebase berhasil!");
    } catch (e) {
      debugPrint("Gagal otentikasi dengan Firebase: $e");
      // Tidak melempar error agar login utama tidak gagal
    }
  }

  // Helper FCM (Sama seperti kode Anda)
  Future<void> _registerFcmToken() async {
    if (_role != 'puskesmas') return;
    try {
      await FirebaseMessaging.instance.requestPermission();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || _token == null) return;
      await _apiService.sendFcmToken(fcmToken, _token!);
    } catch (e) {
      debugPrint("Gagal mengirim FCM Token Admin: $e");
    }
  }

  // Fungsi updateLocalUser (Sama seperti kode Anda)
  Future<void> updateLocalUser(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await _storage.saveUser(updatedUser);
    notifyListeners();
  }
}
