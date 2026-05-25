import '../models/user_model.dart';
import 'local_db_service.dart';

class AuthService {
  // Helper method to find user even if there's a trailing space mismatch
  Map<dynamic, dynamic>? _getUserData(String username) {
    final cleanUsername = username.trim();
    dynamic userData = LocalDbService.usersBox.get(cleanUsername);
    if (userData == null) {
      final keys = LocalDbService.usersBox.keys;
      for (var key in keys) {
        if (key is String && key.trim() == cleanUsername) {
          return LocalDbService.usersBox.get(key);
        }
      }
    }
    return userData;
  }

  // Helper method to find the EXACT key used in Hive to update it
  String? _getUserKey(String username) {
    final cleanUsername = username.trim();
    if (LocalDbService.usersBox.containsKey(cleanUsername)) {
      return cleanUsername;
    }
    final keys = LocalDbService.usersBox.keys;
    for (var key in keys) {
      if (key is String && key.trim() == cleanUsername) {
        return key;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final userData = _getUserData(identifier);
    if (userData == null) {
      final availableKeys = LocalDbService.usersBox.keys.toList();
      throw Exception('Username tidak ditemukan. Keys in DB: $availableKeys');
    }

    final storedPassword = userData['password'] as String;
    if (storedPassword != password && storedPassword.trim() != password.trim()) {
      throw Exception('Password salah');
    }

    return {
      'token': 'local_token_$identifier',
      'user': Map<String, dynamic>.from(userData['user'])
    };
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final cleanUsername = username.trim();
    if (_getUserKey(cleanUsername) != null) {
      throw Exception('Username sudah digunakan');
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch,
      username: cleanUsername,
      email: email.trim(),
    );

    await LocalDbService.usersBox.put(cleanUsername, {
      'password': password.trim(),
      'user': newUser.toJson(),
    });

    return {
      'token': 'local_token_$cleanUsername',
      'user': newUser.toJson(),
    };
  }

  Future<UserModel> getProfile() async {
    final username = LocalDbService.currentUser;
    if (username == null) throw Exception('Tidak ada user yang sedang login');

    final userData = _getUserData(username);
    if (userData == null) {
      throw Exception('User tidak ditemukan');
    }
    return UserModel.fromJson(Map<String, dynamic>.from(userData['user']));
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final username = LocalDbService.currentUser;
    if (username == null) throw Exception('Tidak ada user yang sedang login');

    final userKey = _getUserKey(username);
    if (userKey == null) {
      throw Exception('User tidak ditemukan');
    }
    
    final userData = LocalDbService.usersBox.get(userKey);

    final existingUserMap = Map<String, dynamic>.from(userData['user']);
    existingUserMap.addAll(data);
    
    // Save back
    final updatedData = {
      'password': userData['password'],
      'user': existingUserMap,
    };
    await LocalDbService.usersBox.put(userKey, updatedData);

    return UserModel.fromJson(existingUserMap);
  }

  Future<bool> verifyUserForReset(String username, String email) async {
    final userData = _getUserData(username);
    if (userData == null) {
      throw Exception('Username tidak ditemukan');
    }

    final userEmail = userData['user']['email'] as String;
    if (userEmail.trim() != email.trim()) {
      throw Exception('Email tidak cocok dengan akun tersebut');
    }

    return true;
  }

  Future<void> resetPassword(String username, String newPassword) async {
    final userKey = _getUserKey(username);
    if (userKey == null) {
      throw Exception('Username tidak ditemukan');
    }
    
    final userData = LocalDbService.usersBox.get(userKey);

    final updatedData = {
      'password': newPassword.trim(),
      'user': userData['user'],
    };
    await LocalDbService.usersBox.put(userKey, updatedData);
  }
}
