import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // Mode Demo untuk testing tanpa backend
  final bool _useDemoMode = true;

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      if (_useDemoMode) {
        await Future.delayed(const Duration(seconds: 1)); // Simulasi network delay
        return {
          'token': 'demo_token_123',
          'user': {
            'id': 1,
            'username': identifier,
            'email': '$identifier@example.com',
            'full_name': 'Nama Mahasiswa',
            'campus': 'Universitas Studiv',
            'semester': 4,
            'profile_picture': null,
          }
        };
      }

      final response = await _apiClient.dio.post('/login', data: {
        'login': identifier,
        'password': password,
      });
      return response.data;
    } catch (e) {
      if (_useDemoMode) {
        return login(identifier, password); // Fallback ke demo
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      if (_useDemoMode) {
        await Future.delayed(const Duration(seconds: 1));
        return {
          'token': 'demo_token_123',
          'user': {
            'id': 1,
            'username': username,
            'email': email,
            'full_name': null,
            'campus': null,
            'semester': null,
            'profile_picture': null,
          }
        };
      }

      final response = await _apiClient.dio.post('/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getProfile() async {
    try {
      if (_useDemoMode) {
        return UserModel(
          id: 1,
          username: 'demo_user',
          email: 'demo@example.com',
          fullName: 'Nama Mahasiswa',
          campus: 'Universitas Studiv',
          semester: 4,
        );
      }
      final response = await _apiClient.dio.get('/profile');
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      if (_useDemoMode) {
        return UserModel.fromJson({...data, 'id': 1, 'username': 'demo_user', 'email': 'demo@example.com'});
      }
      final response = await _apiClient.dio.put('/profile/update', data: data);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
