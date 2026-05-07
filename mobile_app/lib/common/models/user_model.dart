class UserModel {
  final int? userId;
  final String? username;
  final String? email;
  final String? phone;
  final String? location;
  final String? image;
  final String? deviceToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.userId,
    this.username,
    this.email,
    this.phone,
    this.location,
    this.image,
    this.deviceToken,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => username ?? 'User';
  String get displayName => username ?? email ?? 'User';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      image: json['image'],
      deviceToken: json['device_token'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'location': location,
      'image': image,
      'device_token': deviceToken,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
