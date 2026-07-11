import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyLoggedUsername = 'logged_in_username';
  static const String _keyAuthToken = 'auth_token';

  /// Save session for a given username
  Future<void> saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLoggedUsername, username);
    await prefs.setString(_keyAuthToken, 'local_token_$username');
  }

  /// Get current session username, if exists
  Future<String?> getSessionUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedUsername);
  }

  /// Clear the active user session
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedUsername);
    await prefs.remove(_keyAuthToken);
  }

  /// Check if a session exists
  Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyLoggedUsername);
  }
}
