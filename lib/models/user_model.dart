class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String noKtp;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.noKtp,
  });

  // --- FUNGSI BARU: Mengubah objek User menjadi Map ---
  // Ini diperlukan oleh AuthProvider untuk menyimpan data ke SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'no_ktp': noKtp,
    };
  }

  // --- PERBAIKAN: Mengganti nama 'fromJson' menjadi 'fromMap' agar sesuai dengan AuthProvider ---
  // Fungsi ini digunakan untuk membuat objek User dari data yang disimpan
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      noKtp: map['no_ktp'] ?? '',
    );
  }
}
