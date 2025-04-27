import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:momentum/interceptor/token_interceptor.dart';

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
    print("Login attempt with email: $email and password: $password");

    try {
      final response = await dio.post(
        "$authUrl/login",
        data: {"name_or_mail": email, "password": password},
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
        ),
      );

      print("Login successful, response: ${response.data}");

      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        if (accessToken != null) {
          await secureStorage.write(key: 'access_token', value: accessToken);
        }
        return response.data;
      } else {
        throw Exception("Login failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("Login error: ${e.toString()}");
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  static Future<int> register(
    String name,
    String email,
    String password,
    int age,
  ) async {
    print(
      "Register attempt with name: $name, email: $email, password: $password, age: $age",
    );

    try {
      final response = await dio.post(
        "$usersUrl",
        data: {"name": name, "mail": email, "password": password, "age": age},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        print("Registration successful, response: ${response.data}");
        return 1;
      } else {
        throw Exception(
          "Registration failed with status ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Registration error: ${e.toString()}");
      throw Exception("Registration failed: ${e.toString()}");
    }
  }

  static Future<String> refreshToken() async {
    print("Refreshing access token");
    try {
      final response = await dio.post(
        "$authUrl/refresh",
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
        ),
      );

      print("Refresh response status: ${response.statusCode}");
      print("Refresh response headers: ${response.headers}");
      print("Refresh response body: ${response.data}");

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
      print("Error refreshing token: $e");
      throw Exception("Failed to refresh token: $e");
    }
  }
}
