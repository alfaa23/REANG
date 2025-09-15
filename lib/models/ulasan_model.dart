class UlasanModel {
  final int id;
  final int infoPlesirId;
  final int userId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String userName;

  UlasanModel({
    required this.id,
    required this.infoPlesirId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.userName,
  });

  factory UlasanModel.fromJson(Map<String, dynamic> json) {
    return UlasanModel(
      id: json['id'] ?? 0,
      infoPlesirId: json['info_plesir_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: (json['rating'] is int)
          ? json['rating']
          : (json['rating'] as num).toInt(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      userName: json['user']?['name'] ?? 'Pengunjung',
    );
  }
}
