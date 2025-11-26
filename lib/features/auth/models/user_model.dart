class UserModel {
  final String email;
  final String? name;
  final DateTime? joinDate;

  UserModel({
    required this.email,
    this.name,
    this.joinDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      name: json['name'] as String?,
      joinDate: json['joinDate'] != null 
          ? DateTime.parse(json['joinDate'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'joinDate': joinDate?.toIso8601String(),
    };
  }
}
