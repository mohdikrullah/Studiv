import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../services/local_db_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  /// Attempt auto-login using the saved session
  Future<bool> tryAutoLogin() async {
    final sessionUsername = await _sessionService.getSessionUsername();
    if (sessionUsername == null) return false;

    try {
      // Retrieve user directly from Hive database
      final dbUser = _authService.getUserDirectly(sessionUsername);
      if (dbUser == null) {
        // User truly does not exist in the database. Clear invalid session.
        await logout();
        return false;
      }

      // Initialize user-specific databases (Schedules, etc.)
      await LocalDbService.initUser(dbUser.username);
      _user = dbUser;
      notifyListeners();
      return true;
    } catch (e) {
      // Session Recovery: If there is an unexpected error (like database lock or delay),
      // DO NOT clear the session. Return false so the app shows login page or retries,
      // but the session data is preserved.
      return false;
    }
  }

  /// Perform login and initialize user session
  Future<void> login(String loginUser, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(loginUser, password);
      final token = response['token'] as String;
      final userData = response['user'] as UserModel;
      
      // Save session separately
      await _sessionService.saveSession(userData.username);
      
      await LocalDbService.initUser(userData.username);
      _user = userData;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user and login
  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.register(username, email, password);
      final token = response['token'] as String;
      final userData = response['user'] as UserModel;
      
      // Save session separately
      await _sessionService.saveSession(userData.username);
      
      await LocalDbService.initUser(userData.username);
      _user = userData;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch user profile from database
  Future<void> fetchProfile() async {
    try {
      _user = await _authService.getProfile();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String fullName,
    required String campus,
    required int semester,
    String? imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final Map<String, dynamic> data = {
        'full_name': fullName,
        'campus': campus,
        'semester': semester,
        'profile_picture': imagePath,
      };
      
      _user = await _authService.updateProfile(data);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout current user (clears session, leaves account data intact)
  Future<void> logout() async {
    await _sessionService.clearSession();
    await LocalDbService.closeUser();
    _user = null;
    notifyListeners();
  }

  /// Verify user combination for password reset
  Future<bool> verifyUserForReset(String username, String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _authService.verifyUserForReset(username, email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset user password
  Future<void> resetPassword(String username, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.resetPassword(username, newPassword);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
