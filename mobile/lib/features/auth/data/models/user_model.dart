/// User domain model representing the authenticated athlete.
class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.createdAt,
  });

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? gender,
    double? heightCm,
    double? weightKg,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : (json['user_id'] is int ? json['user_id'] as int : 0),
      fullName: (json['full_name'] ?? json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
      gender: json['gender'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? (json['height'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? (json['weight'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
