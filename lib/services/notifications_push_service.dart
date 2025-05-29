import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:momentum/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPushService {
  static Dio get dio => ApiService.dio;
  static final String baseUrl = ApiService.baseUrl;
  static final String usersUrl = "$baseUrl/users";

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Envia una sol·licitud d'amistat a un usuari
  static Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    final token = await _getToken();
    final response = await dio.post(
      "$usersUrl/$fromUserId/friend-request",
      data: {"toId": toUserId},
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to send friend request");
    }
  }

  /// Accepta una sol·licitud d’amistat d’un usuari
  static Future<void> acceptFriendRequest(String toUserId, String fromUserId) async {
    final token = await _getToken();
    final response = await dio.post(
      "$usersUrl/$toUserId/accept-friend",
      data: {"fromId": fromUserId},
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to accept friend request");
    }
  }

  /// Obté les sol·licituds d’amistat pendents
  static Future<List<Map<String, dynamic>>> getFriendRequests(String userId) async {
    final token = await _getToken();
    final response = await dio.get(
      "$usersUrl/$userId/friend-requests",
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> requests = response.data['requests'];
      return List<Map<String, dynamic>>.from(requests);
    } else {
      throw Exception("Failed to fetch friend requests");
    }
  }

  /// Obté tots els usuaris disponibles (excloent l'actual)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final token = await _getToken();
    final response = await dio.get(
      "$usersUrl/all",
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      throw Exception("Failed to fetch users");
    }
  }
}
