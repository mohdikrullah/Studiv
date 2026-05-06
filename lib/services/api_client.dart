import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  // Jika di Web pakai localhost, jika di Android Emulator pakai 10.0.2.2
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/api';
    } else {
      return 'http://10.0.2.2/api';
    }
  }
  
  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5), // Set timeout agar tidak menunggu terlalu lama
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  ApiClient() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }
}
