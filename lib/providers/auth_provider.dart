import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/local_db_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token') || !prefs.containsKey('logged_in_username')) return false;

    final username = prefs.getString('logged_in_username')!;
    try {
      await LocalDbService.initUser(username);
      _user = await _authService.getProfile();
      notifyListeners();
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> login(String loginUser, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(loginUser, password);
      final token = response['token'];
      final userData = response['user'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('logged_in_username', userData['username']);
      
      await LocalDbService.initUser(userData['username']);
      _user = UserModel.fromJson(userData);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.register(username, email, password);
      final token = response['token'];
      final userData = response['user'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('logged_in_username', userData['username']);
      
      await LocalDbService.initUser(userData['username']);
      _user = UserModel.fromJson(userData);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    try {
      _user = await _authService.getProfile();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('logged_in_username');
    await LocalDbService.closeUser();
    _user = null;
    notifyListeners();
  }
}
