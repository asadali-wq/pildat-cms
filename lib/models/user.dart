class User {
  final int userId;
  final String fullName;
  final int adminTypeId;
  final String adminTypeName;

  User({
    required this.userId,
    required this.fullName,
    required this.adminTypeId,
    required this.adminTypeName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String,
      adminTypeId: json['admin_type_id'] as int,
      adminTypeName: json['admin_type_name'] as String,
    );
  }
}