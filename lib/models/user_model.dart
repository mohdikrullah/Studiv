class UserModel {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? campus;
  final int? semester;
  final String? profilePicture;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.campus,
    this.semester,
    this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      campus: json['campus'],
      semester: json['semester'],
      profilePicture: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'campus': campus,
      'semester': semester,
      'profile_picture': profilePicture,
    };
  }
}
