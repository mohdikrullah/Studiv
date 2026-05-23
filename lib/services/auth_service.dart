import '../models/user_model.dart';
import 'local_db_service.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final userData = LocalDbService.usersBox.get(identifier);
    if (userData == null) {
      throw Exception('Username tidak ditemukan');
    }

    if (userData['password'] != password) {
      throw Exception('Password salah');
    }

    return {
      'token': 'local_token_$identifier',
      'user': Map<String, dynamic>.from(userData['user'])
    };
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    if (LocalDbService.usersBox.containsKey(username)) {
      throw Exception('Username sudah digunakan');
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch,
      username: username,
      email: email,
    );

    await LocalDbService.usersBox.put(username, {
      'password': password,
      'user': newUser.toJson(),
    });

    return {
      'token': 'local_token_$username',
      'user': newUser.toJson(),
    };
  }

  Future<UserModel> getProfile() async {
    final username = LocalDbService.currentUser;
    if (username == null) throw Exception('Tidak ada user yang sedang login');

    final userData = LocalDbService.usersBox.get(username);
    if (userData == null) {
      throw Exception('User tidak ditemukan');
    }
    return UserModel.fromJson(Map<String, dynamic>.from(userData['user']));
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final username = LocalDbService.currentUser;
    if (username == null) throw Exception('Tidak ada user yang sedang login');

    final userData = LocalDbService.usersBox.get(username);
    if (userData == null) {
      throw Exception('User tidak ditemukan');
    }

    final existingUserMap = Map<String, dynamic>.from(userData['user']);
    existingUserMap.addAll(data);
    
    // Save back
    final updatedData = {
      'password': userData['password'],
      'user': existingUserMap,
    };
    await LocalDbService.usersBox.put(username, updatedData);

    return UserModel.fromJson(existingUserMap);
  }
}
