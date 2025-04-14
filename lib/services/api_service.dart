import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8080";

  static const String usersUrl = "$baseUrl/users";
  static const String authUrl = "$baseUrl/auth";
  static late final Dio dio;
  static late final CookieJar cookieJar;

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      cookieJar = PersistCookieJar(
        storage: FileStorage('${directory.path}/.cookies/'),
      );
      dio.interceptors.add(CookieManager(cookieJar));
    } else {
      cookieJar = CookieJar();
      print(
        "Flutter Web detected → Skipping getApplicationDocumentsDirectory and CookieManager",
      );
    }
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
        // Guardar access token si és necessari
        final accessToken = response.data['accessToken'];
        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
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
        "$usersUrl", // URL per registrar
        data: {"name": name, "mail": email, "password": password, "age": age},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        print("Registration successful, response: ${response.data}");
        return 1; // O pots retornar qualsevol altre valor que necessitis per al teu flux
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

  static Future<Map<String, dynamic>> refreshToken() async {
    print("Refreshing access token");

    try {
      final response = await dio.post(
        "$authUrl/refresh",
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true}, // Només per a refresh
        ),
      );

      print("Refresh response status: ${response.statusCode}");
      print("Refresh response headers: ${response.headers}");
      print("Refresh response body: ${response.data}");

      if (response.statusCode != 401 && response.statusCode != 403) {
        final newAccessToken = response.data['accessToken'];
        if (newAccessToken != null) {
          if (kIsWeb) {
            html.window.localStorage['access_token'] = newAccessToken;
          } else {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', newAccessToken);
          }
          return response.data;
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
