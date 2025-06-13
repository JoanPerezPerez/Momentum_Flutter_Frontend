import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:momentum/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:momentum/models/amistat_model.dart';

class NotificationsPushService {
  static Dio get dio => ApiService.dio;
  static final String baseUrl = ApiService.baseUrl;
  static final String usersUrl = "$baseUrl/users";

  static Future<String?> _getToken() async {
    final token = await ApiService.secureStorage.read(key: 'access_token');
    return token;
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
  static Future<List<AmistatModel>> getFriendRequests(String userId) async {
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
      return requests.map((json) => AmistatModel.fromJson(json)).toList();
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
  static Future<List<AmistatModel>> searchUsersByEmail(String query) async {
    final token = await _getToken();
    final response = await dio.post(
      "$usersUrl/search-by-email",
      data: {"q": query}, 
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> users = response.data['users'];
      return users.map((u) => AmistatModel.fromJson(u)).toList();
    } else {
      throw Exception("Failed to search users");
    }
  }
  static Future<void> denyFriendRequest(String toUserId, String fromUserId) async {
    final token = await _getToken();
    final response = await dio.post(
      "$usersUrl/$toUserId/deny-friend",
      data: {"fromId": fromUserId},
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error en rebutjar la sol·licitud");
    }
  }
  static Future<List<AmistatModel>> getFriends(String userId) async {
    final token = await _getToken();
    final response = await dio.get(
      "$usersUrl/$userId/friends",
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> friends = response.data['friends'];
      return friends.map((u) => AmistatModel.fromJson(u)).toList();
    } else {
      throw Exception("Failed to fetch friends");
    }
  }
  static Future<void> removeFriend(String userId, String friendId) async {
    final token = await _getToken();

    final response = await dio.delete(
      "$usersUrl/friends/$userId/remove/$friendId",
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error eliminant amic');
    }
  }
}
