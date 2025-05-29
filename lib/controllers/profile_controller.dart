import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:momentum/services/notifications_push_service.dart';

class ProfileController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  var selectedIndex = 2.obs;
  var allUsers = <Map<String, dynamic>>[].obs;
  var pendingRequests = <Map<String, dynamic>>[].obs;
  String? userId;

  final dio = Dio();
  final baseUrl = "http://localhost:8080"; // Canvia si cal

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    await fetchAllUsers();
    await fetchFriendRequests();
  }

  Future<void> fetchAllUsers() async {
    final token = await _getToken();
    final res = await dio.get(
      "$baseUrl/users/all",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    allUsers.value = List<Map<String, dynamic>>.from(res.data);
  }

  Future<void> fetchFriendRequests() async {
    final token = await _getToken();
    final res = await dio.get(
      "$baseUrl/users/$userId/friend-requests",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    pendingRequests.value = List<Map<String, dynamic>>.from(res.data['requests']);
  }

  Future<void> sendRequest(String toId) async {
    final token = await _getToken();
    await dio.post(
      "$baseUrl/users/$userId/friend-request",
      data: {"toId": toId},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    Get.snackbar('Sol·licitud enviada', 'S\'ha enviat correctament');
  }

  Future<void> acceptRequest(String fromId) async {
    final token = await _getToken();
    await dio.post(
      "$baseUrl/users/$userId/accept-friend",
      data: {"fromId": fromId},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    Get.snackbar('Amistat acceptada', 'Ara sou amics!');
    await fetchFriendRequests();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
