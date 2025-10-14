import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String noKtp;
  final String role; // <-- 1. TAMBAHKAN PROPERTI

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.noKtp,
    required this.role, // <-- 2. TAMBAHKAN DI CONSTRUCTOR
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'no_ktp': noKtp,
      'role': role, // <-- 3. TAMBAHKAN DI SINI
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      noKtp: map['no_ktp'] ?? '',
      role: map['role'] ?? 'user', // <-- 4. TAMBAHKAN DI SINI
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
