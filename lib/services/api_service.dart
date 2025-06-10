import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:momentum/interceptor/token_interceptor.dart';
import 'package:momentum/models/worker_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static late String baseUrl;
  static late String usersUrl;
  static late String authUrl;
  static late String locationUrl;
  static late final Dio dio;
  static final FlutterSecureStorage secureStorage =
      const FlutterSecureStorage();

  static Future<void> init() async {
    baseUrl = dotenv.env['URL'] ?? "http://localhost:8080";
    authUrl = "$baseUrl/auth";
    usersUrl = "$baseUrl/users";
    locationUrl = "$baseUrl/location";
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(TokenInterceptor());
  }

  static Future<Map<String, dynamic>> userLogin(
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
        final user = response.data['user'];
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

  static Future<Map<String, dynamic>> workerLogin(
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        "$authUrl/loginWorker",
        data: {"name_or_mail": email, "password": password},
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
        ),
      );
      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        final worker = response.data['worker'];
        if (accessToken != null) {
          await secureStorage.delete(key: 'access_token');
          await secureStorage.write(key: 'access_token', value: accessToken);
        }

        if (worker != null && worker['_id'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('workerId', worker['_id']);
        }
        return worker as Map<String, dynamic>;
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

  static Future<Map<String, dynamic>> sendHola() async {
    try {
      final response = await dio.get(
        "$authUrl/validateLogin",
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
        ),
      );
      if (response.statusCode == 200) {
        final type = response.data["type"];
        final data = response.data["data"] as Map<String, dynamic>;
        return {"type": type, "data": data};
      } else {
        throw Exception("Not logged in");
      }
    } catch (e) {
      throw Exception("Hola failed: ${e.toString()}");
    }
  }

  static Future<int> logout() async {
    try {
      final response = await dio.post(
        "$authUrl/logout",
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
        ),
      );
      if (response.statusCode == 200) {
        return 0;
      } else {
        return 1;
      }
    } catch (e) {
      throw Exception("Hola failed: ${e.toString()}");
    }
  }

  static Future<int> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await dio.put(
        "$usersUrl/$userId/password",
        data: {"currentPassword": currentPassword, "newPassword": newPassword},
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
          validateStatus: (status) {
            return status != null &&
                (status == 200 ||
                    status == 402 ||
                    status == 404 ||
                    status == 422);
          },
        ),
      );
      if (response.statusCode == 200) {
        return 0;
      } else {
        throw Exception("Bad request: ${response.data['error']}");
      }
    } catch (e) {
      throw Exception("Request failed: ${e.toString()}");
    }
  }

  static Future<Worker> registerBusiness(
    String name,
    String businessName,
    int age,
    String mail,
    String password,
  ) async {
    try {
      final response = await dio.post(
        "$authUrl/registerBusiness",
        data: {
          "name": name,
          "mail": mail,
          "password": password,
          "age": age,
          "businessName": businessName,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 201) {
        final adminJson = response.data["admin"];
        return Worker.fromJson(adminJson);
      } else {
        throw Exception(response.data["error"]);
      }
    } catch (e) {
      throw Exception("Registration failed: ${e.toString()}");
    }
  }

  static Future<String> getBusinessIdFromLocationId(String locationId) async {
    try {
      final response = await dio.get(
        "$locationUrl/$locationId/business",
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
        ),
      );
      if (response.statusCode == 200) {
        return response.data as String;
      } else {
        throw Exception("Not found in");
      }
    } catch (e) {
      throw Exception("Business id getter failed: ${e.toString()}");
    }
  }
}
