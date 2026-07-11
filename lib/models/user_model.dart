import 'package:hive/hive.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String? passwordHash;
  final String? fullName;
  final String? campus;
  final int? semester;
  final String? profilePicture;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.passwordHash,
    this.fullName,
    this.campus,
    this.semester,
    this.profilePicture,
  });

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? passwordHash,
    String? fullName,
    String? campus,
    int? semester,
    String? profilePicture,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      campus: campus ?? this.campus,
      semester: semester ?? this.semester,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      passwordHash: json['password_hash'],
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
      'password_hash': passwordHash,
      'full_name': fullName,
      'campus': campus,
      'semester': semester,
      'profile_picture': profilePicture,
    };
  }
}

// Manual Hive TypeAdapter to avoid build_runner dependency
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as int,
      username: fields[1] as String,
      email: fields[2] as String,
      passwordHash: fields[3] as String?,
      fullName: fields[4] as String?,
      campus: fields[5] as String?,
      semester: fields[6] as int?,
      profilePicture: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.passwordHash)
      ..writeByte(4)
      ..write(obj.fullName)
      ..writeByte(5)
      ..write(obj.campus)
      ..writeByte(6)
      ..write(obj.semester)
      ..writeByte(7)
      ..write(obj.profilePicture);
  }
}
