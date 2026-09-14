/// Customer user profile model.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String avatarUrl;
  final DateTime memberSince;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address = '',
    this.avatarUrl = '',
    required this.memberSince,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['mobile']?.toString() ?? json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? json['avatarUrl']?.toString() ?? '',
      memberSince: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['member_since'] != null
              ? DateTime.tryParse(json['member_since'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'mobile': phone,
      'address': address,
      'avatar_url': avatarUrl,
      'member_since': memberSince.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
    DateTime? memberSince,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
