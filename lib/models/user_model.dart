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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      noKtp: json['no_ktp'] ?? '',
    );
  }
}
