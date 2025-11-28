class UserModel {
  final String uid;
  final String email;
  final DateTime joinDate;

  UserModel({
    required this.uid,
    required this.email,
    required this.joinDate,
  });

  // JSON(Map)에서 데이터를 가져올 때
  // Firestore가 아닌 일반 API나 로컬 DB에서도 쓸 수 있는 표준 형태
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      // 문자열로 저장된 날짜를 DateTime으로 변환
      joinDate: DateTime.parse(json['joinDate'] as String),
    );
  }

  // 데이터를 저장할 때 (표준 포맷인 String으로 변환)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'joinDate': joinDate.toIso8601String(),
    };
  }
}
