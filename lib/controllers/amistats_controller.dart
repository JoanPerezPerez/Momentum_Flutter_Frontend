  /*
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
*/
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:momentum/models/amistat_model.dart';
import 'package:momentum/services/notifications_push_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendController extends GetxController {
  var searchResults = <AmistatModel>[].obs;
  var friends = <AmistatModel>[].obs;
  var isLoading = false.obs;
  final emailController = TextEditingController();
  var friendsRequests = <AmistatModel>[].obs;
  var showRequestsVertical = false.obs;
  String? myUserId;


  @override
  void onInit() {
    super.onInit();
    loadUserIdAndRequestsAndFriends();
  }

  void loadUserIdAndRequestsAndFriends() async {
    final prefs = await SharedPreferences.getInstance();
    myUserId = prefs.getString('userId');
    if (myUserId != null) {
      await getAllFriendRequests();
      await getAllFriends(); 
    }
  }
  void clearSearchResults() {
    searchResults.clear();
  }

  void toggleRequestsView() {
    showRequestsVertical.value = !showRequestsVertical.value;
  }

  void searchUserByEmail(String email) async {
    isLoading.value = true;
    try {
      final results = await NotificationsPushService.searchUsersByEmail(email);
      searchResults.value = results; 
    } catch (e) {
      Get.snackbar("Error", "No s'ha pogut trobar l'usuari.");
    } finally {
      isLoading.value = false;
    }
  }

  void sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      await NotificationsPushService.sendFriendRequest(fromUserId, toUserId);
      searchResults.removeWhere((u) => u.id == toUserId);

    } catch (e) {
      Get.snackbar("Error", "No s'ha pogut enviar la sol·licitud.");
    }
  }
  Future<void> getAllFriendRequests() async {
    try {
      final data = await NotificationsPushService.getFriendRequests(myUserId!);
      friendsRequests.value = data;
    } catch (e) {
      Get.snackbar("Error", "No s'han pogut obtenir les sol·licituds.");
    }
  }
  Future<void> acceptFriendRequest(String fromUserId) async {
    if (myUserId == null) return;

    try {
      await NotificationsPushService.acceptFriendRequest(myUserId!, fromUserId);
      getAllFriendRequests();
      getAllFriends();
    } catch (e) {
      Get.snackbar("Error", "No s'ha pogut acceptar la sol·licitud.");
    }
  }
  Future<void> denyFriendRequest(String fromUserId) async {
    if (myUserId == null) return;

    try {
      await NotificationsPushService.denyFriendRequest(myUserId!, fromUserId);
      getAllFriendRequests();
    } catch (e) {
      Get.snackbar("Error", "No s'ha pogut rebutjar la sol·licitud.");
    }
  }
  Future<void> getAllFriends() async {
  try {
    final data = await NotificationsPushService.getFriends(myUserId!);
    friends.value = data;
  } catch (e) {
    Get.snackbar("Error", "No s'han pogut obtenir els amics.");
  }

  }
  Future<void> removeFriend(String friendId) async {
    if (myUserId == null) return;

    try {
      await NotificationsPushService.removeFriend(myUserId!, friendId);
      getAllFriends();
    } catch (e) {
      Get.snackbar("Error", "No s'ha pogut eliminar l'amic.");
    }
  }
}
