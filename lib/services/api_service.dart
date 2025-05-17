import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:momentum/interceptor/token_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8080";

  static const String usersUrl = "$baseUrl/users";
  static const String authUrl = "$baseUrl/auth";
  static late final Dio dio;
  static final FlutterSecureStorage secureStorage =
      const FlutterSecureStorage();

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(TokenInterceptor());
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        "$authUrl/login",
        data: {"name_or_mail": email, "password": password},
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
        ),
      );
      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        final user = response.data['user'] ;
        if (accessToken != null) {
          await secureStorage.delete(key: 'access_token');
          await secureStorage.write(key: 'access_token', value: accessToken);
        }

        if (user != null && user['_id'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user['_id']);
        }
        return user as Map<String, dynamic>;
      } else {
        throw Exception("Login failed with status ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  static Future<int> register(
    String name,
    String email,
    String password,
    int age,
  ) async {
    try {
      final response = await dio.post(
        "$usersUrl",
        data: {"name": name, "mail": email, "password": password, "age": age},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        return 1;
      } else {
        throw Exception(
          "Registration failed with status ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Registration failed: ${e.toString()}");
    }
  }

  static Future<String> refreshToken() async {
    try {
      final response = await dio.post(
        "$authUrl/refresh",
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
        ),
      );

      if (response.statusCode != 401 && response.statusCode != 403) {
        final newAccessToken = response.data['accessToken'] as String;
        if (newAccessToken != "") {
          return newAccessToken;
        } else {
          throw Exception("No access token in response");
        }
      } else {
        throw Exception(
          "Failed to refresh token, status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Failed to refresh token: $e");
    }
  }
}
