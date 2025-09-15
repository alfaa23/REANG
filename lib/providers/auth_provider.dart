import 'package:flutter/material.dart';
import 'package:reang_app/models/user_model.dart'; // Import model pengguna

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _user != null;

  void setUser(UserModel user, String token) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}
