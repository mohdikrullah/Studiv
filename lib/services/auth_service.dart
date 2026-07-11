import '../models/user_model.dart';
import 'local_db_service.dart';
import '../utils/crypto_utils.dart';

class AuthService {
  /// Helper method to find a user by username or email, case-insensitively
  UserModel? _getUserData(String identifier) {
    final cleanIdentifier = identifier.trim().toLowerCase();
    if (cleanIdentifier.isEmpty) return null;

    // First try matching key directly (username)
    final directData = LocalDbService.usersBox.get(cleanIdentifier);
    if (directData is UserModel) {
      return directData;
    }

    // Otherwise, iterate over all values to find a match by username or email case-insensitively
    for (var value in LocalDbService.usersBox.values) {
      if (value is UserModel) {
        if (value.username.trim().toLowerCase() == cleanIdentifier ||
            value.email.trim().toLowerCase() == cleanIdentifier) {
          return value;
        }
      }
    }
    return null;
  }

  /// Get user directly by username (used for auto-login checking)
  UserModel? getUserDirectly(String username) {
    return _getUserData(username);
  }

  /// Helper method to find the exact key in Hive
  String? _getUserKey(String username) {
    final cleanUsername = username.trim().toLowerCase();
    for (var key in LocalDbService.usersBox.keys) {
      if (key is String && key.trim().toLowerCase() == cleanUsername) {
        return key;
      }
    }
    return null;
  }

  /// Validate user credentials and login
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final cleanIdentifier = identifier.trim();
    final cleanPassword = password.trim();

    if (cleanIdentifier.isEmpty) {
      throw Exception('Username atau email tidak boleh kosong');
    }
    if (cleanPassword.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    final user = _getUserData(cleanIdentifier);
    if (user == null) {
      throw Exception('Akun tidak ditemukan');
    }

    final hashedInputPassword = CryptoUtils.sha256(cleanPassword);
    if (user.passwordHash != hashedInputPassword) {
      throw Exception('Password salah');
    }

    return {
      'token': 'local_token_${user.username}',
      'user': user,
    };
  }

  /// Register a new user with validation checks
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    // 1. Empty validations
    if (cleanUsername.isEmpty) {
      throw Exception('Username tidak boleh kosong');
    }
    if (cleanEmail.isEmpty) {
      throw Exception('Email tidak boleh kosong');
    }
    if (cleanPassword.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    // 2. Format / Length validation
    if (cleanPassword.length < 8) {
      throw Exception('Password harus minimal 8 karakter');
    }
    if (!cleanEmail.contains('@')) {
      throw Exception('Email tidak valid');
    }

    // 3. Uniqueness validations (case-insensitive)
    if (_getUserData(cleanUsername) != null) {
      throw Exception('Username sudah terdaftar');
    }
    if (_getUserData(cleanEmail) != null) {
      throw Exception('Email sudah terdaftar');
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch,
      username: cleanUsername,
      email: cleanEmail,
      passwordHash: CryptoUtils.sha256(cleanPassword),
    );

    // Save using clean lowercase username as the box key for normalized lookups
    await LocalDbService.usersBox.put(cleanUsername.toLowerCase(), newUser);

    return {
      'token': 'local_token_$cleanUsername',
      'user': newUser,
    };
  }

  /// Retrieve profile of current logged in user
  Future<UserModel> getProfile() async {
    final username = LocalDbService.currentUser;
    if (username == null) throw Exception('Tidak ada user yang sedang login');

    final user = _getUserData(username);
    if (user == null) {
      throw Exception('User tidak ditemukan');
    }
    return user;
  }

  /// Update profile info
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final username = LocalDbService.currentUser;
    if (username == null) throw Exception('Tidak ada user yang sedang login');

    final userKey = _getUserKey(username);
    if (userKey == null) {
      throw Exception('User tidak ditemukan');
    }
    
    final user = _getUserData(userKey);
    if (user == null) {
      throw Exception('User tidak ditemukan');
    }

    final updatedUser = user.copyWith(
      fullName: data['full_name'] ?? user.fullName,
      campus: data['campus'] ?? user.campus,
      semester: data['semester'] ?? user.semester,
      profilePicture: data['profile_picture'] ?? user.profilePicture,
    );

    await LocalDbService.usersBox.put(userKey, updatedUser);
    return updatedUser;
  }

  /// Verify combination of username and email for password recovery
  Future<bool> verifyUserForReset(String username, String email) async {
    final user = _getUserData(username);
    if (user == null) {
      throw Exception('Username tidak ditemukan');
    }

    if (user.email.trim().toLowerCase() != email.trim().toLowerCase()) {
      throw Exception('Email tidak cocok dengan akun tersebut');
    }

    return true;
  }

  /// Reset account password
  Future<void> resetPassword(String username, String newPassword) async {
    final userKey = _getUserKey(username);
    if (userKey == null) {
      throw Exception('Username tidak ditemukan');
    }
    
    final user = _getUserData(userKey);
    if (user == null) {
      throw Exception('User tidak ditemukan');
    }

    final updatedUser = user.copyWith(
      passwordHash: CryptoUtils.sha256(newPassword.trim()),
    );
    await LocalDbService.usersBox.put(userKey, updatedUser);
  }
}
