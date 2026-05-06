import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> login(String login, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(login, password);
      final token = response['token'];
      final userData = response['user'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _user = null;
    notifyListeners();
  }
}
